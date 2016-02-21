XMLHttpRequest.register("POST", "*/qsp/gateway/http/js/bocPurchaseService/purchasePolicy", function(req) {

  var parsed = deconstructPostBody(req);
  var expected = '{"polgrpOriginKey":"PRELOADED_05_PROD","polgrpOriginId":1,"offerId":"2"}';

  if (parsed && parsed.arg1 && parsed.arg1 === expected) {
    $N.test.promoPurchaseSuccess = true;
  }

  this.json({});
});

