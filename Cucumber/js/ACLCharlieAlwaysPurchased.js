XMLHttpRequest.register("GET", "*/adaptor/hue-gateway/gateway/http/js/acquiredContentListService/getByAccountUID?*", function(req) {
	this.intercept(req, function() {
		//return nothing from acl so no purchased VOD
		this.json({
			result : [{
				// Desktop Charlie and Chocolate factory
				"alcStatus" : null,
				"viewingNumber" : null,
				"accountUID" : 1,
				"uid" : 35074,
				"offer" : {
					"offerValidFrom" : null,
					"aclUID" : 35074,
					"discountValue" : null,
					"discountType" : null,
					"billingPeriod" : null,
					"title" : null,
					"billingCount" : null,
					"offerId" : null,
					"offerValidTo" : null
				},
				"modifiedDate" : null,
				"creationDate" : 1435227488000,
				"consumptionWindowSecs" : null,
				"copyProtections" : null,
				"frequencyType" : "IMP",
				"originKey" : null,
				"smartcard" : null,
				"parentAclUID" : null,
				"casInstanceId" : "Noop",
				"casId" : null,
				"lastBilledDate" : null,
				"purchasedItemOriginKey" : "PRELOADED_05_PROD",
				"serviceProviderID" : 2,
				"deviceUID" : 57531,
				"productType" : null,
				"alcType" : "0",
				"status" : "S",
				"purchasedItemUID" : 65,
				"purchasedItemType" : "PLG",
				"exportID" : null,
				"expiryDate" : 2539768824,
				"licenseExpiryDurationSecs" : 86400,
				"validFrom" : 1435227488000,
				"profileUID" : null,
				"policyGroupUID" : 65,
				"originID" : null,
				"userUID" : 1,
				"alcExpiryDate" : null,
				"purchaseType" : "IMPULSE"
			}],
			resultCode : "0",
			token : null,
			requestId : null
		});
	});
});
