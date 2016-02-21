/*
 * Adds the provided recommendations to the voditem products
 * @param [Object] response the response object containing editorials
 * @param [Array<String>] recommendations an array of recommendation/rank strings
 */
function addStaticRecommendations(response, recommendations) {
  window.traverseAndCollect(response, "editorials.technicals.products.voditems").forEach(function(vis) {
    vis.forEach(function(vi) {
      vi.RecommendedVodItemIds = recommendations;
    });
  });
}

XMLHttpRequest.register("GET", '*metadata/delivery/GLOBAL/vod/editorials?*', function(req) {
  this.intercept(req, function() {
    var response = JSON.parse(this.responseText);
    addStaticRecommendations(response, [
      "PRELOADED_23_VOD/12", // Top Gun
      "PRELOADED_20_VOD/14", // Sintel
      "PRELOADED_02_VOD/10"]); // Battlestar Galactica
    this.json(response);
  });
});
