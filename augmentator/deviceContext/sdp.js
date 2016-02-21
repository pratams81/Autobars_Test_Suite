var http = require('http'),
	zlib = require('zlib'),
	fs = require('fs');

/**
 */
var initialise = function() {
	console.log("INITIALISING...SDP");
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
			"deviceType": ["PC","TABLET","PHONE"],
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
			"drmInstanceId": null
		},
		"requestId": 2097320221
	};
	res.send(json);
};

module.exports.getCurrentContext = getCurrentContext;
module.exports.initialise = initialise;
