/*
 * Driver: Stewart Platt
 *  1969 XMLHttpRequest Interceptor 5.8 L Cleveland V8
 *
 *
 *                             ______________
 *                     __..=='|'   |         ``-._
 *        \=====_..--'/'''    |    |              ``-._
 *        |'''''      ```---..|____|_______________[)>.``-.._____
 *        |\_______.....__________|____________     ''  \      __````---.._
 *      ./'     /.-'_'_`-.\       |  ' '       ```````---|---/.-'_'_`=.-.__```-._
 *      |.__  .'/ /     \ \`.      \      XHRi           | .'/ /     \ \`. ```-- `.
 *       \  ``|| |   o   | ||-------\-------------------/--|| |   o   | ||--------|
 *        "`--' \ \ _ _ / / |______________________________| \ \ _ _ / / |..----```
 *               `-.....-'                                    `-.....-'
 */

/*
 * Performance optimizations
 */
window.accelerate = function accelerate() {
  console.log("Vr"+".".repeat(~~(Math.random()*8+4)).split('').map(function(x){return Math.random() > 0.5 ? "o" : "O";}).join('')+"m!");
};

/*
 * Interceptor for XMLHttpRequests, featuring basic routing (advanced routing soon)
 * This works by replacing the XMLHttpRequest method with a wrapper
 * The wrapper can have routes registered against it
 * New XHR instances are matched against routes and method calls/property accesses
 * are routed to the appropriate implementation (Wrapper or underlying XHR)
 *
 * Supports the following use cases:
 *  1) Non-routed XHRs should behave as normal
 *  2) XHRs can be responded to directly
 *  3) XHRs can be intercepted to modify the request
 *   a) Full access to the data, URL, request headers
 *  4) XHRs can be intercepted to modify the response
 *   b) Full access to the data response (this.responseText)
 *
 * Unsupported usecases:
 *  1) Non-standard method calls
 *  2) Unable to modify response headers for an intercepted response
 */
function XMLHttpRequestInterceptor(original) {
  var routes = {};

  var xhri = function() {
    this.xhr = new original();
    this.deferQueue = [];
    this._responseHeaders = [];

    /*
     * For methods called after 'send' (e.g. abort), we proxy the result
     * If the XHRi object has been marked as routable, handle
     * @param {Object} context context under which
     * @return {Function}
     */
    function proxy(context, method, newFunction) {
      return function() {
        if(this.routable) {
          return newFunction.apply(this, arguments);
        }
        return method.apply(context, arguments);
      };
    }

    /*
     * Wraps a method to defer a call
     * Stores the context, method and caller arguments in the provided array
     * @param {Array<Object>} deferQueue the array to store deferred method calls
     * @param {Object} context the required calling context
     * @param {Function} method the target method
     * @return {Function} a wrapped method
     */
    function deferrer(deferQueue, context, method) {
      return function() {
        deferQueue.push({
          context: context,
          method: method,
          arguments: arguments
        });
      };
    }

    /*
     * Check if a registered route matches
     * Return any captured variables and the route callback
     * Returns false if no route matches
     * @param {String} verb the HTTP verb to match against (GET|POST|DELETE|PUT)
     * @param {String} url the target URL to match
     */
    function matchRoute(pattern) {
      for(var k in routes) {
        var results = RegExp(k).exec(pattern);

        if(RegExp(k).test(pattern)) {
          // Return all capture groups, except the full text match
          return {
            captures: results.slice(1),
            route: routes[k]
          };
        }
      }
      return false;
    }

    /*
     * Defer method calls
     */
    this.setRequestHeader = deferrer(this.deferQueue, this.xhr, this.xhr.setRequestHeader);

    /*
     * Proxy methods
     */
    this.abort = proxy(this.xhr, this.xhr.abort, function() { /* Don't do anything */ });
    this.getAllResponseHeaders = proxy(this.xhr, this.xhr.getAllResponseHeaders, function() {
      // Return all faked response headers
      return this._responseHeaders;
    });
    this.getResponseHeader = proxy(this.xhr, this.xhr.getResponseHeader, function(header) {
      return this._responseHeaders[header];
    });

    /*
     * Proxies onreadystatechange
     * Allow interception of a genuine response
     */
    Object.defineProperty(this, "onreadystatechange", {
      set: function(v) {
        function responseInterceptor() {
          // If the response is complete, optionally pass through to a registered interceptor
          if(this.xhr.readyState === 4 && this.routable && this._interceptResponse) {
            // After intercepting, we'll pretend we are no longer routable
            // This will make all methods proxy to the original XHR
            // this.responseText = this.xhr.responseText;
            console.log("Intercepting request: " + this.route);
            this.routable = false;
            this._interceptResponse();
          } else {
            v.call(this);
          }
        }
        this.xhr.onreadystatechange = responseInterceptor.bind(this);
        this._onreadystatechange = v;
      },
      get: function() {
        if(this.routable) {
          return this._onreadystatechange;
        } else {
          return this.xhr.onreadystatechange;
        }
      }
    });

    /*
     * Proxies XMLHttpRequest.readyState
     */
    Object.defineProperty(this, "readyState", {
      get: function() {
        if(this.routable) {
          return this._readyState;
        } else {
          return this.xhr.readyState;
        }
      },
      set: function(v) {
        this._readyState = v;
      }
    });

    /*
     * Proxies XMLHttpRequest.status
     */
    Object.defineProperty(this, "status", {
      get: function() {
        if(this.routable) {
          return this._status;
        } else {
          return this.xhr.status;
        }
      },
      set: function(v) {
        this._status = v;
      }
    });

    /*
     * Proxies XMLHttpRequest.responseText
     */
    Object.defineProperty(this, "responseText", {
      get: function() {
        if(this.routable) {
          return this._responseText;
        } else {
          return this.xhr.responseText;
        }
      },
      set: function(v) {
        this._responseText = v;
      }
    });

    /*
     * Open the given method/url. Determine if we should route this call or not
     * If not, proxy to the original XHR.
     * Synchronous requests not supported (tested)
     * @param {String} method the HTTP verb
     * @param {String} url the HTTP endpoint
     * @param {Boolean} asynchronous is the XHR asynchrnous or not
     */
    this.open = function open(method, url, asynchronous) {
      // Defer this method, in case we decide to
      // proxy the request upstream with modifications
      deferrer(this.deferQueue, this.xhr, this.xhr.open)(method, url, asynchronous);

      this.route = method + ":" + url;

      if(matchRoute(this.route) && asynchronous) {
        // Method should be routed
        this.routable = true;
      } else {
        // Method should not be routed, proxy back to original XHR
        this.xhr.open.call(this.xhr, method, url, asynchronous);
      }
    };

    /*
     * If this XHR should be routed, execute the routed function
     * Otherwise, proxy everything upstream
     * @param {String} data the request body
     */
    this.send = function send(data) {
      if(this.routable) {
        var result = matchRoute(this.route);

        // Call the route handler next tick
        setTimeout(result.route.bind(this, data), 0);
      } else {
        this.proxy(data);
      }
    };

    /*
     * Used to call send on the original the method back upstream
     * Useful in two cases:
     *  1) The request body has been changed
     *  2) The URL has been changed
     * @param {String} data the request body
     */
    this.proxy = function proxy(data, reroute) {
      // We won't route, so execute deferred methods
      // and send on the original XHR
      this.deferQueue.forEach(function(x) {
        x.method.apply(x.context, x.arguments);
      });

      this.routable = this.routable && reroute;
      this.xhr.send(data);
    };

    /*
     * Proxy the request upstream and intercept the response
     * @param {String} data the request body
     * @param {Function} callback the response intereceptor callback
     */
    this.intercept = function intercept(data, callback) {
      this._interceptResponse = callback;
      this.proxy(data, true);
    };

    /*
     * Change the target URL
     * Use in conjunction with proxy (or intercept) to change the upstream target
     * @param {String} url the target url
     */
    this.setUrl = function setUrl(url) {
      // the deferred open call should be first in the queue
      if(this.deferQueue.length > 0 && this.deferQueue[0].method === this.xhr.open) {
        // Explicitly change the URL argument (open(method, url, ...))
        this.deferQueue[0].arguments[1] = url;
      } else {
        throw new Error("Assertion failed: 'open' was not first call");
      }
    };

    /*
     * Fetch the target URL
     * @return {String} the target url
     */
    this.getUrl = function getUrl() {
      if(this.deferQueue.length > 0 && this.deferQueue[0].method === this.xhr.open) {
        return this.deferQueue[0].arguments[1];
      } else {
        throw new Error("Assertion failed: 'open' was not first call");
      }
    };

    /*
     * Progress readyState from 1 through 3
     */
    this._fakeReadyStates = function _fakeReadyStates() {
      this.readyState = 1;
      this.onreadystatechange();
      this.readyState = 2;
      this.onreadystatechange();
      this.readyState = 3;
      this.onreadystatechange();
    };

    /*
     * Emulates a successful request
     * @param {String} data the response text
     * @param {Number} code the success code, defaults to 200
     */
    this.success = function success(data, code) {
      this.routable = true;
      this._fakeReadyStates();

      this.status = code || 200;
      this.responseText = data;
      this.readyState = 4;
      this.onreadystatechange();
    };

    /*
     * Emulates a successful JSON response
     * Stringifies the JS object and sets the correct content type
     * @param {Object} data the JS object response
     * @param {Number} code the success code, defaults to 200
     */
    this.json = function json(data, code) {
      this._responseHeaders["Content-Type"] = "application/json";
      this.success(JSON.stringify(data), code);
    };

    /*
     * Simulate a failure
     * Progress to readyState 4 and set status/responseText
     * @param {String} error The string error response
     * @param {Number} code numeric error code
     */
    this.failure = function failure(error, code) {
      this._fakeReadyStates();

      this.status = code;
      this.responseText = error;

      this.readyState = 4;
      this.onreadystatechange();
    };
  };

  /*
   * Register a route
   * @param {String} method the HTTP verb
   * @param {String} route the HTTP route (only exact matches currently supported)
   * @param {Function} f the route function handler
   */
  xhri.register = function register(method, url, f) {
    // Method + url
    var route = method + ":" + url;

    // Escape all regex characters, except *
    route = route.replace(/[-\/\\^$+?.()|[\]{}]/g, '\\$&');

    // Replace * with a simple non-greedy capture (.*)
    // Do not replace \*
    // route can never start with a * (always starts GET|POST|PUT|DELETE...)
    route = route.replace(/([^\\])\*/g, "$1(.*?)");

    routes[route] = f;
  };

  return xhri;
}

window.XMLHttpRequest = XMLHttpRequestInterceptor(window.XMLHttpRequest);
