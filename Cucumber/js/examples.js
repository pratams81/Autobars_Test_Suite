/*
 * Dumping ground for examples
 */

var url = 'http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?filter={"isVisible":true,"technical.deviceType":{"$in":["PC"]},"locale":"en_GB","voditem.publishToEndUserDevices":false}&limit=50&sort=[["editorial.title",1]]&pretty=true';
var success = url === constructStringUrlParams(url, deconstructJsonUrlParams(url));
console.log(success);


/*
 * Change all product prices in the response, using the supplied callback
 */
function changePrices(response, priceFunction) {
  traverseAndCollect(response, "editorials.technicals.products.price").forEach(function(price) {
    price.value = priceFunction();
  });
}

/*
 * Adds the provided recommendations to the voditem products
 * @param [Object] response the response object containing editorials
 * @param [Array<String>] recommendations an array of recommendation/rank strings
 */
function addStaticRecommendations(response, recommendations) {
  traverseAndCollect(response, "editorials.technicals.products.voditems").forEach(function(vis) {
    vis.forEach(function(vi) {
      vi.RecommendedVodItemIds = recommendations;
    });
  });
}

/*
 * Assign a locality to all products
 */
function makeMultiprice(response, locality) {
  traverseAndCollect(response, "editorials.technicals.products.price").forEach(function(price) {
    price.locality = locality;
  });
}



XMLHttpRequest.register("GET", "http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?*", function(req) {
  this.intercept(req, function() {
    // Your trickery goes here
  });
});









/*
 * Mutli pricing
 */

/*
 * Set a pricing category on the account
 */
XMLHttpRequest.register("POST", 'http://ott.nagra.com/stable/qsp/gateway/http/js/accountService/getByAccountNumber', function(req) {
  this.intercept(req, function() {
    var response = JSON.parse(this.responseText);
    response.result.locality = "PREMIUM";
    this.json(response);
  });
});







/*
 * Set a fake 'premium' price for all products when the correct filter and fields are supplied
 */
XMLHttpRequest.register("GET", 'http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?filter=*"$or":[{"product.ProfileName":"PREMIUM"},{"product.type":"subscription"}]*', function(req) {
  // Proxy the request, but strip the multipricing filter
  var url = this.getUrl();
  this.setUrl(url.replace(',"$or":[{"product.ProfileName":"PREMIUM"},{"product.type":"subscription"}]', ""));

  // Modify the response with fake prices for identification
  this.intercept(req, function(x) {
    var response = JSON.parse(this.responseText);
    traverseAndCollect(response, "$editorials.technicals.products.price").forEach(function(p) {
      if(p.result) {
        //p.result.locality = "PREMIUM";
        p.result.value = p.anchor.title.length;
      }
      if(p) {
        p.value = 50;
      }
    });
    this.json(response);
  });
});



/*
 * Static recommendations
 */
XMLHttpRequest.register("GET", 'http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?*', function(req) {
  this.intercept(req, function() {
    var response = JSON.parse(this.responseText);
    addStaticRecommendations(response, [
      "AFEWGOODMEN_VOD_1/12",
      "B1_CALIFORNIADREAMIN_VOD_1/14",
      "BATTLESTAR_VOD_1/10"]);
    this.json(response);
  });
});

/*
 * Random pricing
 */
XMLHttpRequest.register("GET", 'http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?*',
  function(req) {
    this.intercept(req, function() {
      var response = JSON.parse(this.responseText)
      changePrices(response, function(e) { return ~~(4 + Math.random()*10)});
      this.json(response);
    });
});


















/*
 * Example usage
 */

/*
 * Return a fake JSON object
 */
XMLHttpRequest.register("POST", "http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentContext", function(reqData) {
  this.json({"token":null,"resultCode":"0","result":{"deviceProfileUid":null,"deviceUid":69,"deviceOriginKey":null,"deviceOriginId":null,"casn":null,"mediaPlayerId":null,"deviceType":null,"accountUid":1,"accountNumber":"102","accountOriginKey":null,"accountOriginId":null,"userUid":1,"accessPointUid":1,"featureUidList":null,"featureNameList":null,"globalSpid":1,"spid":22,"locale":"en_gb","nlsSort":null,"smartcardId":null,"challengeId":null,"drmInstanceId":null},"requestId":1341457553});
});

/*
 * Augment JSON from a web service call
 */
XMLHttpRequest.register("POST", "http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentContext", function(reqData) {
  this.intercept(data, function() {
    var response = JSON.parse(this.responseText);
    response.result.deviceProfileUid = 152;
    this.json(response);
  });
});

/*
 * Modify the request body of an outgoing request
 */
XMLHttpRequest.register("POST", "http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentContext", function(reqData) {
  this.proxy(reqData.replace("tokne", "token"));
});


var locker = {
  record: function(id) {

  }
  getAllRecordings: function() {
    return [];
  }
}

XMLHttpRequest.register("GET", "*npvrlocker/getAllRecordings", function(reqData) {
  this.json(locker.getAllRecordings());
});


/*
 * Modify the URL endpoint or request headers of an outgoing request
 */
XMLHttpRequest.register("POST", "http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentContext", function(reqData) {
  this.setUrl("http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentcontext2");
  //this.setRequestHeader("Content-Type", "application/json");
  this.proxy(reqData);
});

/*
 * Leave an uninteresting request alone
 */
XMLHttpRequest.register("POST", "http://ott.nagra.com/stable/qsp/gateway/http/js/contextService/getCurrentContext", function(reqData) {
  if(reqData.indexOf("token=") > -1) {
    this.proxy(reqData);
  } else {
    this.proxy(reqData.replace("tokne", "token"));
  }
});


//////////////////////////////////////////


window.XMLHttpRequest.register("GET", "pretty=true&limit=1", function(data) {
  this.setUrl("http://ott.nagra.com/stable/metadata/delivery/B1/vod/editorials?pretty=true&limit=0");
  this.proxy(data);
});
