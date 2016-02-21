/*
 * Set a fake premium pricing category on the account
 */
XMLHttpRequest.register("POST", '*qsp/gateway/http/js/accountService/getByAccountNumber', function(req) {
  this.intercept(req, function() {
    var response = JSON.parse(this.responseText);
    response.result.locality = "PREMIUM";
    this.json(response);
  });
});

/*
 * Set a fake 'premium' price for all products when the correct filter and fields are supplied
 */
XMLHttpRequest.register("GET", '*metadata/delivery/GLOBAL/vod/editorials?filter=*' + encodeURIComponent('"$or":[{"product.ProfileName":"PREMIUM"},{"product.type":"subscription"}]') + '*', function(req) {
  // Proxy the request, but strip the multipricing filter
  var url = this.getUrl();
  this.setUrl(url.replace(encodeURIComponent(',"$or":[{"product.ProfileName":"PREMIUM"},{"product.type":"subscription"}]'), ""));

  // Modify the response with fake prices for verification in the UI
  this.intercept(req, function(x) {
    var response = JSON.parse(this.responseText);
    traverseAndCollect(response, "$editorials.technicals.products.price").forEach(function(context) {
      // A simple way of verifying the route has been caught
      if(context.anchor.Title && context.anchor.Title.indexOf("multipriced") === -1) {
        context.anchor.Title += " (multipriced)";
      }
      if(context.result && context.result.value && context.result.value != 0) {
        context.result.value = 50.0;
      }
    });
    this.json(response);
  });
});
