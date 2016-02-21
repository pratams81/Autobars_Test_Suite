var http = require('http'),
	zlib = require('zlib'),
	fs = require('fs');

/**
 */
var initialise = function() {
	console.log("INITIALISING...SDP");
};


/**
 * Route function to return stuff for the  signOnByUser request
 */
var signOnByUser = function(req, res) {
	var json = {
		"token": "AAABTJQX/QCyZrG81plRjm2ahO4aJvE2YziHfLYvTQ2kRO6H3ZKmhDUI36Hu9hnYYPt/sQbl7d!xRaWT!dA1Ow==",
		"resultCode": "0",
		"result": null,
		"requestId": 1087525840
	};
	res.send(json);
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
			"deviceType": null,
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

/**
 * Route function to return stuff for the getByUID request
 */
var getByUID = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": {
			"status": "ACTIVE",
			"statusCode": "A",
			"statusAsEnum": "ACTIVE",
			"firstName": "FirstName",
			"title": "nmp@nagra.com standard account",
			"lastName": "LastName",
			"address1": "address 1",
			"address2": "address 2",
			"locality": "Locality",
			"city": "City",
			"county": "county",
			"postCode": "12345",
			"country": "Country",
			"creditLimit": null,
			"creditSpent": 5660.209,
			"creditSpentRst": "T",
			"accessPointUID": 1,
			"accountNumber": "102",
			"ppvStatus": true,
			"rolloutProfileUid": 1,
			"maxMPDeviceAllowed": 100000,
			"maxUserAllowed": 100000,
			"npvrProfile": "NPVR_MEDIUM",
			"accountProfileUID": null,
			"uid": 1,
			"modifiedDate": 1428413040000,
			"creationDate": 1396869395000,
			"exportID": null,
			"originID": 1,
			"originKey": "102",
			"serviceProviderID": 2
		},
		"requestId": 360551554
	};
	res.send(json);
};

/**
 * Route function to change the NPVR status of an account
 */
var getVisitor = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": [{
			"name": "NPVR_STATUS",
			"value": "ENABLED"
		}],
		"requestId": 322897166
	};
	res.send(json);
};

/**
 * Route function to get the pref service information
 */
var prefService = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": [],
		"requestId": 1563752993
	};
	res.send(json);
};

/**
 * Route function to get the rating service information
 */
var ratingService = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": [{
			"ratingCode": "0",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_1",
			"description": null,
			"modifiedDateML": null,
			"uid": 1,
			"modifiedDate": null,
			"creationDate": 1396617764000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "1",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_2",
			"description": null,
			"modifiedDateML": null,
			"uid": 2,
			"modifiedDate": null,
			"creationDate": 1396617764000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "2",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_3",
			"description": null,
			"modifiedDateML": null,
			"uid": 3,
			"modifiedDate": null,
			"creationDate": 1396617785000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "3",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_4",
			"description": null,
			"modifiedDateML": null,
			"uid": 4,
			"modifiedDate": null,
			"creationDate": 1396618165000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "4",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_5",
			"description": null,
			"modifiedDateML": null,
			"uid": 5,
			"modifiedDate": null,
			"creationDate": 1396618169000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "5",
			"precedenceValue": 0,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_6",
			"description": null,
			"modifiedDateML": null,
			"uid": 6,
			"modifiedDate": null,
			"creationDate": 1396618172000,
			"exportID": null,
			"originID": 0,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "6",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_7",
			"description": null,
			"modifiedDateML": null,
			"uid": 7,
			"modifiedDate": null,
			"creationDate": 1396618175000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "7",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_8",
			"description": null,
			"modifiedDateML": null,
			"uid": 8,
			"modifiedDate": null,
			"creationDate": 1396618182000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "8",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_9",
			"description": null,
			"modifiedDateML": null,
			"uid": 9,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "9",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_10",
			"description": null,
			"modifiedDateML": null,
			"uid": 10,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "10",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_11",
			"description": null,
			"modifiedDateML": null,
			"uid": 11,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "11",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_12",
			"description": null,
			"modifiedDateML": null,
			"uid": 12,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "12",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_13",
			"description": null,
			"modifiedDateML": null,
			"uid": 13,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "13",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_14",
			"description": null,
			"modifiedDateML": null,
			"uid": 14,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "14",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_15",
			"description": null,
			"modifiedDateML": null,
			"uid": 15,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}, {
			"ratingCode": "15",
			"precedenceValue": null,
			"tvRating": null,
			"mpaaRating": null,
			"locale": "en_gb",
			"name": "EPG_DAT_Parental_Rating_16",
			"description": null,
			"modifiedDateML": null,
			"uid": 16,
			"modifiedDate": null,
			"creationDate": 1396618193000,
			"exportID": null,
			"originID": null,
			"originKey": null,
			"serviceProviderID": 1
		}],
		"requestId": 993276849
	};
	res.send(json);
};

/**
 * Route function to get the acl
 */
var getACL = function(req, res) {
	var json = {
		"result": [{
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25308,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25308,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159675000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "MUL",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS000384981",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 665,
			"purchasedItemType": "PLG",
			"exportID": null,
			"expiryDate": 1455695675000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159675000,
			"profileUID": null,
			"policyGroupUID": 665,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}, {
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25303,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25303,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159442000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS000060661",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 22,
			"purchasedItemType": "PKG",
			"exportID": null,
			"expiryDate": 1478044800000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159442000,
			"profileUID": null,
			"policyGroupUID": 670,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}, {
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25304,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25304,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159442000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS001268033",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 63,
			"purchasedItemType": "PKG",
			"exportID": null,
			"expiryDate": 1745971200000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159442000,
			"profileUID": null,
			"policyGroupUID": 3709,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}, {
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 1952,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 1952,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1399539340000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS000384980",
			"serviceProviderID": 2,
			"deviceUID": 43,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 664,
			"purchasedItemType": "PLG",
			"exportID": null,
			"expiryDate": 1578735914000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1399539340000,
			"profileUID": null,
			"policyGroupUID": 664,
			"originID": null,
			"userUID": 1,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}, {
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25305,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25305,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159675000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS000195370",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 663,
			"purchasedItemType": "PLG",
			"exportID": null,
			"expiryDate": 2114377200000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159675000,
			"profileUID": null,
			"policyGroupUID": 663,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}],
		"resultCode": "0",
		"token": null,
		"requestId": 2099796800
	};
	res.send(json);
};

/**
 * Route function to get the acl
 */
var getACLByType = function(req, res) {
	var json = {
		"result": [{
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25304,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25304,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159442000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS001268033",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 63,
			"purchasedItemType": "PKG",
			"exportID": null,
			"expiryDate": 1745971200000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159442000,
			"profileUID": null,
			"policyGroupUID": 3709,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}, {
			"alcStatus": null,
			"viewingNumber": null,
			"accountUID": 1,
			"uid": 25303,
			"offer": {
				"offerValidFrom": null,
				"aclUID": 25303,
				"discountValue": null,
				"discountType": null,
				"billingPeriod": null,
				"title": null,
				"billingCount": null,
				"offerId": null,
				"offerValidTo": null
			},
			"modifiedDate": null,
			"creationDate": 1424159442000,
			"consumptionWindowSecs": null,
			"copyProtections": null,
			"frequencyType": "REC",
			"originKey": null,
			"smartcard": null,
			"parentAclUID": null,
			"casInstanceId": "Noop",
			"casId": null,
			"lastBilledDate": null,
			"purchasedItemOriginKey": "LYS000060661",
			"serviceProviderID": 2,
			"deviceUID": null,
			"productType": null,
			"alcType": "0",
			"status": "S",
			"purchasedItemUID": 22,
			"purchasedItemType": "PKG",
			"exportID": null,
			"expiryDate": 1478044800000,
			"licenseExpiryDurationSecs": 86400,
			"validFrom": 1424159442000,
			"profileUID": null,
			"policyGroupUID": 670,
			"originID": null,
			"userUID": null,
			"alcExpiryDate": null,
			"purchaseType": "SUBSCRIPTION"
		}],
		"resultCode": "0",
		"token": null,
		"requestId": 850131481
	};
	res.send(json);
};

/**
 * Route function to get the pref service information
 */
var getBookmark = function(req, res) {
	var json = {
		"token": null,
		"resultCode": "0",
		"result": [],
		"requestId": 1563752993
	};
	res.send(json);
};

module.exports.signOnByUser = signOnByUser;
module.exports.getCurrentContext = getCurrentContext;
module.exports.getByUID = getByUID;
module.exports.getVisitor = getVisitor;
module.exports.prefService = prefService;
module.exports.ratingService = ratingService;
module.exports.getACL = getACL;
module.exports.getACLByType = getACLByType;
module.exports.getBookmark = getBookmark;
module.exports.initialise = initialise;
