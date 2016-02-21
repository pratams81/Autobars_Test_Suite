var fs = require('fs');

/**
 * Initialises the static Recordings (if any) and local epg (if required)
 * @return {[type]} [description]
 */
var initialise = function() {
	console.log("INITIALISING... MDS");


};

/**
 * Gets the VOD Editorial data, always empty in this case
 */
var getVodEditorials = function(req, res) {
	var json = {
		"total_records": 0,
		"version": "20150408065041",
		"editorials": []
	};
	res.send(json);
};

/**
 * Gets the VOD Node data, always empty in this case
 */
var getVodNodes = function(req, res) {
	var json = {
		"total_records": 52,
		"nodes": [{
			"Rating": {
				"code": "12",
				"precedence": 12,
				"Title": "Under 15"
			},
			"id": "B1_HOTPICKS",
			"parent": null,
			"Title": "Hot Picks"
		}],
		"version": "20150408070047"
	};
	res.send(json);
};

/**
 * Gets the VOD Series data, always empty in this case
 */
var getVodSeries = function(req, res) {
	var json = {
		"total_records": 0,
		"series": [],
		"version": "20150408065041"
	};
	res.send(json);
};

/**
 * Route function used to enable the services of a platform to use NPVR
 */
var getBtvServices = function(req, res) {
	res.send();
};

/**
 * A local JSON file is used to get the EPG data (loaded in initialise)
 */
var getBtvProgrammes = function(req, res) {
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

	fs.readFile('.\\npvrLocker\\epg_data.json', 'utf8', function(err, data) {
		if (err) throw err;
		changeDates(JSON.parse(data));
	});



};

module.exports.getVodEditorials = getVodEditorials;
module.exports.getVodNodes = getVodNodes;
module.exports.getVodSeries = getVodSeries;
module.exports.getBtvServices = getBtvServices;
module.exports.getBtvProgrammes = getBtvProgrammes;
module.exports.initialise = initialise;