function _traverseAndCollect(item, properties, anchor) {
  var prop = properties.shift(),
      results = [],
      anchored = false;

  if(prop.indexOf('$') === 0) {
    anchored = true;
    prop = prop.substr(1);
  }

  if(properties.length > 0) {
    if(item[prop] instanceof Array) {
      item[prop].forEach(function(x, i) {
        if(anchored) {
          anchor = item[prop][i];
        }
        results = results.concat(_traverseAndCollect(x, properties.slice(0), anchor));
      });
    } else {
        if(anchored) {
          anchor = item[prop];
        }
      results.push(_traverseAndCollect(item[prop], properties.slice(0), anchor));
    }
  } else {
    results.push({anchor: anchor, result: item[prop]});
  }

  return results;
}

function _removeAnchors(array) {
  return array.map(function(e) {
    return e.result;
  });
}

/*
 * Repeatedly iterate over arrays nested in objects,
 * collating the results in a new array
 * query format is:
 *   propname.subpropname.$anchorpoint.targetvalue
 * anchors provide context with the returned item:
 * [{anchor: {}, result: {}}, {anchor: {}, result: Number]
 * @param {Object} item the object to search
 * @param {Array<String>} query a list of . separated array property names, e.g. editorials.technicals.products.price
 * @return An array of matching values, array value may be undefined/null
 */
function traverseAndCollect(item, query) {
  var results = _traverseAndCollect(item, query.split("."), null);
  return query.indexOf("$") > -1 ? results : _removeAnchors(results);
}

window.traverseAndCollect = traverseAndCollect;


/*
 * Return an object representing the params for a URL
 * e.g. test?a=3&b={x:4} ->
 *   {a: 3, b: {x: 4}}
 * @param {String} url The URL to deconstruct
 * @return {Object} an object representation of the URL params
 */
function deconstructJsonUrlParams(url) {
  var queryString = url.split('?').slice(1).join('?');

  var result = {};

  queryString.split('&').forEach(function(kvp) {
    var key = kvp.split('=')[0],
        value = kvp.split('=').slice(1).join('=');
    result[key] = JSON.parse(value);
  });

  return result;
}

/*
 * Return an object representing the params for a POST body
 * e.g. test?a=3&b={x:4} ->
 *   {a: 3, b: {x: 4}}
 * @param {String} body POST body to de-construct
 * @return {Object} an object representation of the POST bod
 */
function deconstructPostBody(body) {
  var result = {};

  body.split('&').forEach(function(kvp) {
    var key = kvp.split('=')[0],
        value = kvp.split('=')[1];
    result[key] = decodeURIComponent(value);
  });

  return result;
}

window.deconstructPostBody = deconstructPostBody;

/*
 * Constructs a new URL with queryparams based on an existing URL
 * and a supplied object of
 * @param {String} url the original URL (with original query params)
 * @param {Object} newParams the new parameters to add to the URL
 * @return {String} the new URL with query params
 */
function constructStringUrlParams(url, newParams) {
  var url = url.split('?')[0] + "?";
  var queryParts = [];


  for(var k in newParams) {
    var param = k + "=";
    param += JSON.stringify(newParams[k]);
    queryParts.push(param);
  }

  url += queryParts.join('&');

  return url;
}
