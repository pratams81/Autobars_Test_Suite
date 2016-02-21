//see https://atlassian.hq.k.grp/confluence/display/NL/Recording+request+JSON+object for the recording Object def (which is not up-to-date!!)
var http = require('http'),
	zlib = require('zlib'),
	fs = require('fs'),
	recordingId = 0,
	recordingLookup = {},
	recordingRequestsArray = [],
	QUOTA_EXCEEDED = 401,
	QUOTA_MESSAGE = "Requested recording would exceed quota",
	USE_LOCAL_EPG = true,
	localEpgLookUp = {},
	localEpgSeriesLookUp = {},
	localEpg,
	accountQuota;

/**
 * Creates a local epg, used when the labs are borked
 * @param  {String} data epg data, ready to be sent to a JSON object
 */
function createLocalEpgStructure(data) {
	localEpg = JSON.parse(data);
	localEpg.programmes.forEach(function(curr) {
		localEpgLookUp[curr.id] = curr;
		if (curr.editorial && curr.editorial.seriesRef) {
			if (!localEpgSeriesLookUp[curr.editorial.seriesRef]) {
				localEpgSeriesLookUp[curr.editorial.seriesRef] = [];
			}
			localEpgSeriesLookUp[curr.editorial.seriesRef].push(curr.id);
		}
	});
}

/**
 * Initialises the static Recordings (if any) and local epg (if required)
 * @return {[type]} [description]
 */
var initialise = function() {
	console.log("INITIALISING...");
	recordingRequestsArray.forEach(function(curr) {
		recordingLookup[curr.id] = curr;
	});

	if (USE_LOCAL_EPG) {
		fs.readFile('.\\npvrLocker\\epg_data.json', 'utf8', function(err, data) {
			if (err) throw err;
			createLocalEpgStructure(data);
		});
	}
};


// ********* HELPER FUNCTIONS *********)
/**
 * Subtracts some time from the accountQuota, if the quota is exceeded then 401 error is returned, otherwise 200
 * @param  {Number} duration time, in seconds to add to the currentUsage
 * @return {Number}	401 if exceeds the total usage, otherwise 200
 */
function subtractQuota(duration){
	var errorCode = QUOTA_EXCEEDED;
	if(accountQuota && (accountQuota.quotausage.currentUsage + duration < accountQuota.quotausage.quotaTotal)){
		accountQuota.quotausage.currentUsage += duration;
		errorCode = 200;
		console.log("currUse: "+accountQuota.quotausage.currentUsage+" + duration: " + duration + " total:" + accountQuota.quotausage.quotaTotal);
	}
	return errorCode;
}

/**
 * Adds some time to the accountUsage
 * @param {Number} duration time, in seconds, to subtract from the currentUsage
 */
function addQuota(duration){
	accountQuota.quotausage.currentUsage -= duration;
	if(accountQuota.quotausage.currentUsage < 0) {
		accountQuota.quotausage.currentUsage = 0;
	}
	console.log("currUse: "+accountQuota.quotausage.currentUsage+" - duration: " + duration + " total:" + accountQuota.quotausage.quotaTotal);
}

/**
 * Creates a recording for a specific programme
 * @param  {String}   programmeId   id of the programme to be recorded
 * @param  {String}   accountNumber account identifier
 * @param  {Function} callback      function to send info back to, parameters: recording=the created recording, errorCode=code to specify any errors
 */
function createRecordingRequest(programmeId, accountNumber, callback) {
	var createRecording = function(dataObj) {
		var recording = null,
			errorCode = 200;

		if (dataObj.programmes && dataObj.programmes.length > 0) {
			errorCode = subtractQuota(dataObj.programmes[0].period.duration);
			if(errorCode !== QUOTA_EXCEEDED){
				recording = {
					"id": recordingId + "abc",
					"protected": false,
					"accountNumber": accountNumber,
					"programmeId": programmeId,
					"created": new Date(),
					"modified": new Date(),
					"availabilityEndDate": new Date(),
					"serviceProviderName": "AUGMENTATOR",
					"status": "NEW",
					"programmeMetaData": dataObj.programmes[0],
					"uri": "TEST URL"
				};
				recordingId++;
			}
		}
		callback(recording, errorCode);
	};

	if (USE_LOCAL_EPG) {
		createRecording({programmes: [localEpgLookUp[programmeId]]});
	} else {
		var requestUrl = 'http://ott.nagra.com/stable/metadata/delivery/B1/btv/programmes?filter={%22id%22:%22' + programmeId + '%22,%22locale%22:%22en_GB%22}&limit=9999&fields=[]&sort=[]';
		http.get(requestUrl, function(res2) {
			var data = "";
			res2.on("data", function(chunk) {
				data += chunk;
			});
			res2.on("end", function() {
				var respond = function(response) {
					res.send(response);
				};

				createRecording(JSON.parse(data));
			});
		});
	}
}

/**
 * Creates a recording for each item within a series (only for local data ATM)
 * @param  {String}   seriesId      the id of the series
 * @param  {String}   accountNumber account identifier
 * @param  {Function} callback      function to return data with, parameters: seriesRecording=Array of recordings for the series, errorCode=any error generated when creating recordings
 * @return {[type]}                 [description]
 */
function createSeriesRecordingRequest(seriesId, accountNumber, callback) {
	var seriesRecordings = [],
		errorCode = 200;
	localEpgSeriesLookUp[seriesId].forEach(function(curr){
		createRecordingRequest(curr, accountNumber, function(rec, error){
			if(error === QUOTA_EXCEEDED){
				errorCode = error;
			} else if(rec){
				rec.seriesId = seriesId;
				seriesRecordings.push(rec);
			}
		});
	});
	callback(seriesRecordings, errorCode);
}

/**
 * Deletes items from the locker depending on the seriesId and status
 * @param  {String}   seriesId the id of the series used to remove items
 * @param  {String}   status   the status to use when removing items (if undefined or null will remove all items for the series)
 * @param  {Function} callback function to send back error code, 500 - nothing was deleted, 204 deleted at least one item
 */
function deleteFromSeriesRecordings(seriesId, status, callback) {
	var allRecordings = convertToArray(recordingLookup),
		code = 500;

	allRecordings.forEach(function(curr){
		if(curr.seriesId === seriesId && (!status || curr.status === status)) {
			console.log("Deleting object " + curr.id);
			addQuota(recordingLookup[curr.id].programmeMetaData.period.duration);
			delete recordingLookup[curr.id];
			code = 204;
		}
	});

	callback(code);
}

/**
 * Converts a lookUp object into an Array of items
 * @param  {Object} object the lookUp object to convert
 * @return {Array}         the converted Array
 */
function convertToArray(object) {
	var returnArray = [];
	for (var key in object) {
		if (object.hasOwnProperty(key)) {
			returnArray.push(object[key]);
		}
	}
	return returnArray;
}

// ********* REQUESTS *********
/**
 * Gets a single recording, using the recordingId specified in the route
 */
var getSingleRecording = function(req, res) {
	//console.log(req.params);
	var recordingId = req.params.recordingId,
		recording = recordingLookup[recordingId];

	if (recording) {
		res.set({
			'Content-Type': 'application/json',
		});
		res.send(recording);
	} else {
		res.send("no recording with id: " + recordingId);
	}
};


/**
 * Gets all the recordings
 */
var getAllRecordings = function(req, res) {
	//this should also accept sort and filter in the query?
	//console.log(req.query);
	res.set({
		'Content-Type': 'application/json',
	});
	res.send({
		results: {
			recordingrequests: convertToArray(recordingLookup)
		}
	});
};

/**
 * Creates a single recording, using the programmeId specified in the request body
 */
var createRecording = function(req, res) {
	//console.log(req.body);
	//console.log(req.query);
	var sendResponse = function(newRecording, error) {
		var code = error,
			message;

		if (newRecording) {
			code = 204;
			recordingLookup[newRecording.id] = newRecording;
		} else if(code === QUOTA_EXCEEDED) {
			message = QUOTA_MESSAGE;
		}
		res.statusCode = code;
		if(message){
			res.send(message);
		} else {
			res.send();
		}
	};
	if(req.query.seriesLinking){
		createSeriesRecording(req, res);
	} else {
		createRecordingRequest(req.body.programmeId, req.body.accountNumber, sendResponse);		
	}

};

/**
 * sends back the correct header to allow the POST,PUT,GETOPTIONS,DELETE requests
 */
var sendOptionsHeader = function(req, res) {
	//console.log("OPTIONS request");
	res.set({
		'X-Powered-By': 'Augmentator',
		'Access-Control-Allow-Origin': '*',
		'Access-Control-Allow-Credentials': 'true',
		'Access-Control-Allow-Headers': 'X-Custom-Header, Content-type',
		'Access-Control-Allow-Methods': 'POST,PUT,GET,OPTIONS,DELETE',
		'Keep-Alive': 'timeout=15, max=98',
		'Connection': 'Keep-Alive'
	});
	res.statusCode = 204;
	res.send();
};

/**
 * Deletes a single recording, using the recordingId in the route
 */
var deleteSingleRecording = function(req, res) {
	//console.log(req.params);
	var recordingId = req.params.recordingId,
		code = 500;
	if (recordingLookup[recordingId]) {
		console.log("Deleting object " + recordingId);
		addQuota(recordingLookup[recordingId].programmeMetaData.period.duration);
		delete recordingLookup[recordingId];
		code = 204;
	}
	res.statusCode = code;
	res.send();
};

/**
 * Protects a single recording, using the recordingId in the route
 */
var protectSingleRecording = function(req, res) {
	//console.log(req.query.filter);
	var filter = JSON.parse(req.query.filter),
		recordingId = filter.id,
		code = 500;
	if (recordingLookup[recordingId]) {
		console.log("Updating object " + recordingId);
		recordingLookup[recordingId].isprotected = req.body.isprotected;
		code = 204;
	}
	res.statusCode = code;
	res.send();
};

/**
 * Sends back the accountQuota for an account, for the first request this is initialised (all numbers are in seconds)
 */
var getQuota = function(req, res) {
	res.set({
		'Content-Type': 'application/json',
	});

	if(!accountQuota){
		if (req.query.accountNumber === "nmp.00001") {
			accountQuota = {
					quotausage: {
						"accountNumber": "nmp.00001",
						"currentUsage": 2,
						"quotaTotal": 5,
						"currentUsageUnit": "HH",
						"quotaTotalUnit": "HH"
					}
				};
		} else if (req.query.accountNumber === "102") {
			accountQuota = {
					quotausage: {
						"accountNumber": "102",
						"currentUsage": 0,
						"quotaTotal": 43200,
						"currentUsageUnit": "HH",
						"quotaTotalUnit": "HH"
					}
				};
		} else if (req.query.accountNumber === "himalaya") {
			accountQuota = {
					quotausage: {
						"accountNumber": "himalaya",
						"currentUsage": 2,
						"quotaTotal": 24,
						"currentUsageUnit": "HH",
						"quotaTotalUnit": "HH"
					}
				};	
		}
	}
	if(accountQuota) {
		res.send(accountQuota);
	} else {
		res.send("Need accountNumber parameter in url");
	}
};

/**
 * Sends back all the recordings for a specific series, as specified in the route
 */
var getAllSeriesRecordings = function(req, res) {
	var seriesId = req.query.seriesId,
		allRecordings = convertToArray(recordingLookup);
		recordings = [];

	allRecordings.forEach(function(curr){
		if(curr.seriesId === seriesId){
			recordings.push(curr);
		}
	});

	res.set({
		'Content-Type': 'application/json',
	});
	res.send({
		SeriesRecordingRequest: {
			id : seriesId,
			recordingrequests: recordings
		}
	});

};

/**
 * Creates a Series of recordings based on the seriesId in the body of the request
 */
var createSeriesRecording = function(req, res) {
	//console.log(req.body);

	var sendResponse = function(newSeries, error){
		var code = error,
			message;
		if (newSeries.length) {
			code = 204;
			newSeries.forEach(function(curr){
				recordingLookup[curr.id] = curr;
			});
		} else if(error === QUOTA_EXCEEDED){
			message = QUOTA_MESSAGE;
		}
		res.statusCode = code;
		if(message){
			res.send(message);
		} else {
			res.send();
		}
	};

	createSeriesRecordingRequest(req.body.seriesId, req.body.accountNumber, sendResponse);
};

/**
 * Deletes all the items in the series that has has the status "NEW".
 * Uses the seriesId from the route
 */
var cancelSeriesRecording = function(req, res) {
	//console.log(req.params);
	var sendResponse = function(code){
		res.statusCode = code;
		res.send();
	};

	deleteFromSeriesRecordings(req.params.seriesId, "NEW", sendResponse);
};


/**
 * Deletes all the items in the series that has has the status "RECORDED".
 * Uses the seriesId from the route
 */
var deleteRecordedSeriesRecording = function(req, res) {
	//console.log(req.params);
	var sendResponse = function(code){
		res.statusCode = code;
		res.send();
	};

	deleteFromSeriesRecordings(req.params.seriesId, "RECORDED", sendResponse);
};

/**
 * Deletes all the items in the series.
 * Uses the seriesId from the route
 */
var deleteAllSeriesRecording = function(req, res) {
	//console.log(req.params);
	var sendResponse = function(code){
		res.statusCode = code;
		res.send();
	};

	deleteFromSeriesRecordings(req.params.seriesId, null, sendResponse);
};

/**
 * coverts the JSON object to a url params string
 * e.g. 	{"arg1":"val1", "arg2":"val2"}
 * 	to 		arg1=val1&arg2=val2
 */
function parseBody(body) {
	return Object.keys(body).map(function(k) {
		if(k===""){
			return "";
		}
		return encodeURIComponent(k) + '=' + encodeURIComponent(body[k]);
	}).join('&');
}

/**
 * Takes a POST request does the actual request, fiddle the response data (using the callback) and sends back the fiddled data
 * @param  {[type]}   req      request from the calling function
 * @param  {[type]}   res      response from the calling function
 * @param  {Function} callback function that does the data fiddling, parameters: data = the response data from the http request
 */
function fiddlePostResponse(req, res, callback) {
	var body = parseBody(req.body);

	var options = {
		host: req._parsedUrl.host,
		port: req._parsedUrl.port,
		path: req._parsedUrl.path,
		method: 'POST',
		headers: req.headers
	};

	// Setup the request
	var hreq = http.request(options, function(res2) {
		var data = "",
			gzip = zlib.createGunzip();

		res2.pipe(gzip);

		gzip.on("data", function(chunk) {
			data += chunk.toString();
		});
		gzip.on("end", function() {
			var respond = function(data) {
				res.send(data);
			};
			//console.log(data);
			callback(data, respond);
		});
	});

	hreq.on('error', function(e) {
		res.statusCode = 500;
		res.send(e.message);
	});

	hreq.write(body);
	hreq.end();
}

/**
 * Changes the npvrProfile of an SDP account
 * @param  {String}   data     the account details to change
 * @param  {Function} callback function to send back the changed data to
 */
function _changeNpvrProfile(data, callback) {
	var dataObj = JSON.parse(data);
	if (dataObj.result && dataObj.result.npvrProfile) {
		dataObj.result.npvrProfile = "NPVR_SMALL";
	}
	callback(dataObj);
}

/**
 * Route function to change the npvrProfile of an SDP account
 */
var changeNpvrProfile = function(req, res) {
	fiddlePostResponse(req, res, _changeNpvrProfile);
};

/**
 * Changes the npvrStatus of an account, currently used to hardcode the account to enabled, but could change the status by uncommenting out the code below
 * @param  {String}   data     the account details to change
 * @param  {Function} callback function to send back the changed data to
 */
function _changeVisitor(data, callback) {
	var dataObj = JSON.parse(data);
	var newResult = [{
		"name": "NPVR_STATUS",
		"value": "ENABLED"
	}];

	dataObj.result = newResult;

	// if(dataObj.result){
	// 	dataObj.result.forEach(function(curr){
	// 		if(curr.name === "NPVR_STATUS"){
	// 			curr.value = "DISABLED";
	// 		}
	// 	});
	// }
	callback(dataObj);
}

/**
 * Route function to change the NPVR status of an account
 */
var changeVisitor = function(req, res) {
	fiddlePostResponse(req, res, _changeVisitor);
};

/**
 * Does a http get request and sends back the response through the callback function
 * @param  {[type]}   req      request from the calling function
 * @param  {[type]}   res      response from the calling function
 * @param  {Function} callback function that does the data fiddling, parameters: data = the response data from the http request
 */
function fiddleGetResponse(req, res, callback) {
	http.get(req.originalUrl, function(res2) {
		var data = "";
		res2.on("data", function(chunk) {
			data += chunk;
		});
		res2.on("end", function() {
			var respond = function(response) {
				res.send(response);
			};

			callback(data, respond);
		});
	});
}

/**
 * Enables each service to be able to record their programmes
 * @param  {String}   data     string containing the JSON of the services to enable
 * @param  {Function} callback accepts the changed JSON code
 */
function _enableServices(data, callback) {
	var dataObj = JSON.parse(data);
	if (dataObj.services) {
		dataObj.services.forEach(function(curr) {
			curr.editorial.nPvrSupport = true;
			curr.technical.nPvrSupport = true;
		});
	}
	callback(dataObj);
}

/**
 * Route function used to enable the services of a platform to use NPVR
 */
var enableServices = function(req, res) {
	fiddleGetResponse(req, res, _enableServices);
};

/**
 * Enables each programme to be able to record
 * @param  {String}   data     string containing the JSON of the programmes to enable
 * @param  {Function} callback accepts the changed JSON code
 */
function _enableProgrammes(data, callback) {
	var dataObj = JSON.parse(data);
	if (dataObj.programmes) {
		dataObj.programmes.forEach(function(curr) {
			curr.isnPvr = true;
		});
	}
	callback(dataObj);
}

/**
 * Route function used to enable the services of a platform to use NPVR
 * If there in no EPG data on the server then a local JSON file can be used to get the EPG data
 */
var enableProgrammes = function(req, res) {
	var filter = JSON.parse(req.query.filter);
	var startDate = new Date(filter['period.end'].$gt * 1000);
	var changeDates = function(dataObj) {
		dataObj.programmes.forEach(function(curr) {
			var start = new Date(curr.period.start * 1000),
				newStart = startDate;

			if (start.getHours() > startDate.getHours()) {
				start.setDate(startDate.getDate());
				start.setMonth(startDate.getMonth());
				start.setFullYear(startDate.getFullYear());
			} else {
				start.setDate(startDate.getDate() + 1);
				if (start.getDate() === 1) {
					start.setMonth(startDate.getMonth() + 1);
				} else {
					start.setMonth(startDate.getMonth());
				}
				if (start.getMonth() === 1) {
					start.setFullYear(startDate.getFullYear() + 1);
				} else {
					start.setFullYear(startDate.getFullYear());
				}
			}
			curr.period.start = start.getTime() / 1000;
			curr.period.end = curr.period.start + curr.period.duration;
		});
		res.send(dataObj);
	};

	if (USE_LOCAL_EPG) {
		changeDates(localEpg);
	} else {
		fiddleGetResponse(req, res, _enableProgrammes);
	}

};

/**
 * Changes a specified recording to have the status specified in the requesting url
 */
var changeState = function(req, res) {
	var message = "";
	if (recordingLookup[req.query.recordingId]) {
		recordingLookup[req.query.recordingId].status = req.query.status;
		res.statusCode = 200;
		//message = "Status Changed";
		message = recordingLookup[req.query.recordingId];
	} else {
		message = "Invalid recordingId";
		res.statusCode = 500;
	}
	res.send(message);
};

/**
 * Clears all the recordings
 */
var clearAllRecordings = function(req, res) {
	recordingLookup = {};
	res.statusCode = 200;
	res.send();
};

/**
 * Writes the current set of recordings to a json file, the file is specified in the url query using '?file=<myFilename>' query
 * Gets written to testdata folder
 */
var writeCurrentRecordingsToJson = function(req, res) {
	var msg,
		jsonFile = req.query.file ? req.query.file : "recordings.json",
		recordings;

	fs.writeFile(".\\npvrLocker\\testdata\\"+jsonFile, JSON.stringify(recordingLookup), function (err) {
		if (err) {
			msg = "Error: " + err;
		} else {
			msg = "Success: " + JSON.stringify(recordingLookup) + " /nWritten to: npvrLocker/testdata/" + jsonFile;
		}
		res.send(msg);
	});
};

/**
 * Reads a new set of recordings from a json file, the file is specified in the url query using '?file=<myFilename>' query
 * Gets read from testdata folder
 */
var readRecordingsFromJson = function(req, res) {
	var msg,
		jsonFile = req.query.file ? req.query.file : "recordings.json";

	fs.readFile(".\\npvrLocker\\testdata\\"+jsonFile, 'utf8', function(err, data) {
		if (err) {
			msg = "Error: " + err;
		} else {
			msg = "Success: " + data + " /nRead from: npvrLocker/testdata/" + jsonFile;
			recordingLookup = JSON.parse(data);
		}
		console.log(msg);
		res.send(msg);
	});
};

module.exports.getSingleRecording = getSingleRecording;
module.exports.getAllRecordings = getAllRecordings;
module.exports.createRecording = createRecording;
module.exports.sendOptionsHeader = sendOptionsHeader;
module.exports.deleteSingleRecording = deleteSingleRecording;
module.exports.protectSingleRecording = protectSingleRecording;
module.exports.getAllSeriesRecordings = getAllSeriesRecordings;
module.exports.cancelSeriesRecording = cancelSeriesRecording;
module.exports.deleteRecordedSeriesRecording = deleteRecordedSeriesRecording;
module.exports.deleteAllSeriesRecording = deleteAllSeriesRecording;
module.exports.getQuota = getQuota;
module.exports.changeNpvrProfile = changeNpvrProfile;
module.exports.changeVisitor = changeVisitor;
module.exports.enableServices = enableServices;
module.exports.enableProgrammes = enableProgrammes;
module.exports.changeState = changeState;
module.exports.clearAllRecordings = clearAllRecordings;
module.exports.writeCurrentRecordingsToJson = writeCurrentRecordingsToJson;
module.exports.readRecordingsFromJson = readRecordingsFromJson;
module.exports.initialise = initialise;