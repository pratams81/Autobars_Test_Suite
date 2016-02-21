XMLHttpRequest.register("GET", '*metadata/delivery/*/vod/editorials*', function(req) {
  this.intercept(req, function() {
    var response = JSON.parse(this.responseText);
    traverseAndCollect(response, "editorials.technicals.products.price").forEach(function(price) {
      if(price) {
        price["value"] = 0.0;
      }
    });
    this.json(response);
  });
});
