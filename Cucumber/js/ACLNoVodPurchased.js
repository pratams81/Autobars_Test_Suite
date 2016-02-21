XMLHttpRequest.register("GET", "http://ott.nagra.com/stable/adaptor/hue-gateway/gateway/http/js/acquiredContentListService/getByAccountUID?*", function(req) {
	this.intercept(req, function() {
		//return nothing from acl so no purchased VOD
		this.json({result: [],
			resultCode: "0",
			token: null,
			requestId: null
		});
	});
});