XMLHttpRequest.register("GET", "*/metadata/delivery/GLOBAL/vod/editorials?*", function(req) {
	this.intercept(req, function() {
		// Your trickery goes here

		var response = JSON.parse(this.responseText);

		response.editorials.forEach(function(editorial) {
			editorial.technicals.forEach(function(technical) {
				technical.products.forEach(function(product) {
					product.promotions = [2,3];
				});
			});
		});

		this.json(response);
	});
});

XMLHttpRequest.register("GET", "*/metadata/delivery/GLOBAL/offers/promotions", function(req) {
	this.intercept(req, function() {

		var interceptedResponse = {
			"total_records": 2,
			"promotions":[{
				"description" : "Desc_2",
				"billingPeriods" : 2,
				"serviceProvider" : "GLOBAL",
				"title" : "Promo_2",
				"enabled" : true,
				"id" : "2",
				"discountType" : "finalPrice",
				"startAvailability" : 1289337299,
				"discountValue" : 1.00,
				"scope" : {
					"contentScope" : {
						"productType" : "single",
						"criterias" : [{
							"criteria" : [{
								"key" : "editorial_title",
								"value" : ["A Few Good Men"]
							}]
						}]
					}
				},
				"endAvailability" : 1489870878
			}, {
				"description" : "Desc_2",
				"billingPeriods" : 2,
				"serviceProvider" : "GLOBAL",
				"title" : "PromoTopGun",
				"enabled" : true,
				"id" : "3",
				"discountType" : "finalPrice",
				"startAvailability" : 1289337299,
				"discountValue" : 1.50,
				"scope" : {
					"contentScope" : {
						"productType" : "single",
						"criterias" : [{
							"criteria" : [{
								"key" : "editorial_title",
								"value" : ["Top Gun"]
							}]
						}]
					}
				},
				"endAvailability" : 1489870878
			}]
		};
		var response = interceptedResponse;
		this.json(response);
	});
});
