var	fs = require('fs');
var DEVICE_TYPE = [];
var DEVICE_TYPE_LIST = [];
var DUMMY_MDS_RESPONSE = null;

var initialise = function() {
	var msg;
	console.log("INITIALISING...deviceContext configuration");
};

var setDeviceType = function (arrayStr) {
	DEVICE_TYPE = arrayStr;
};

var getDeviceType = function () {
	return DEVICE_TYPE;
};

var setDeviceTypeList = function (arrayStr) {
	DEVICE_TYPE_LIST = arrayStr;
};

var getDeviceTypeList = function () {
	return DEVICE_TYPE_LIST;
};

/**
 * Route function to return stuff for the getCurrentContext request
 */
var getCurrentContext = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": {
			"deviceProfileUid": null,
			"deviceUid": 0,
			"deviceOriginKey": null,
			"deviceOriginId": null,
			"casn": null,
			"mediaPlayerId": null,
			"deviceType": DEVICE_TYPE,
			"accountUid": 1,
			"accountNumber": "102",
			"accountOriginKey": null,
			"accountOriginId": null,
			"userUid": 1,
			"accessPointUid": 1,
			"featureUidList": null,
			"featureNameList": null,
			"globalSpid": 1,
			"spid": 2,
			"locale": "en_gb",
			"nlsSort": null,
			"smartcardId": null,
			"challengeId": null,
			"drmInstanceId": null,
			"deviceTypeList": (DEVICE_TYPE_LIST) ? DEVICE_TYPE_LIST : {'VOD': ['OTT','BTV'],'BTV': ['OTT','DVBNOTT'],'nPVR': ['OTT', 'DVBNOTT']}
		},
		"requestId": 2097320221
	};
	res.send(json);
};

var getVodEditorials = function(req, res) {
	var filter = JSON.parse(req.query.filter);
	var jsonFile = (filter['technical.deviceType']) ? "technical.deviceType.json" : "deviceType.json";
	if (!DUMMY_MDS_RESPONSE) {
		fs.readFile("deviceContext\\testdata\\"+jsonFile, 'utf8', function(err, data) {
			if (err) {
				msg = "Error: " + err;
			} else {
				msg = "***** Success: Read from: " + jsonFile;
				DUMMY_MDS_RESPONSE = JSON.parse(data);
				res.send(DUMMY_MDS_RESPONSE);
			}
			console.log(msg);
		});
	} else {
		res.send(DUMMY_MDS_RESPONSE);
	}

	
}

module.exports.setDeviceType = setDeviceType;
module.exports.getDeviceType = getDeviceType;
module.exports.setDeviceTypeList = setDeviceTypeList;
module.exports.getDeviceTypeList = getDeviceTypeList;
module.exports.getVodEditorials = getVodEditorials;
module.exports.getCurrentContext = getCurrentContext;
module.exports.initialise = initialise;
