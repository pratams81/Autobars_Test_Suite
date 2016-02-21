var express = require('express'),
	fs = require('fs'),
	http = require('http'),
	request = require('request'),
	bodyParser = require('body-parser'),
	cors = require('cors'),
	jsonParser = bodyParser.json(),
	urlencodedParser = bodyParser.urlencoded({ extended: false }),
	app = express(),
	//json file that describes routes and functions to map them to
	serverConfig = [],
	appendServerConfig,
	//root of the MDS server, defined in the serverConfig
	rootPath,
	//function defined by the serverConfig
	requiredFuncs; 

/**
 * Sets up a new set of functions to use and routes to listen to
 * If an initialise function is defined it will be run
 */
function setUp() {
	serverConfig.forEach(function(currConfig){
		if(currConfig.REQUIRED_FUNCS){
			var tmpFuncs = require(currConfig.REQUIRED_FUNCS);
			if(tmpFuncs.initialise){
				tmpFuncs.initialise();
			}

			if(requiredFuncs){
				Object.keys(tmpFuncs).forEach(function(key) {
					requiredFuncs[key] = tmpFuncs[key];
				});
			} else {
				requiredFuncs = tmpFuncs;
			}
			//console.log(requiredFuncs);
		}
	});
	addRoutes();
}

/**
 * Reads a JSON file and sends the JSON into the callback
 * @param  {Sring}   fileName	path to the JSON file
 * @param  {Function} callback	function that uses the JSON
 */
function readJsonFile(fileName, callback) {
	var json;
	fs.readFile(fileName, 'utf8', function(err, data){
		if(err) throw err;
		json = JSON.parse(data);
		callback(json);
	});
}

/**
 * Adds a route to listen out for
 * @param {String} url		the url to listen out for
 * @param {String} fileName	(optional) if sending JSON from a file back the
 * @param {String} func		(optional - if using fileName) function used to send back response (needs to be exposed by the js file in module.exports)
 * @param {String} useRoot	(optional) if there is a ROOT in the JSON config prepends to the url
 * @param {String} method 	request method (GET|POST|PUT|DELETE|OPTION)
 * @param {String} extras	extra function to use (can be any of cors,jsonParser,ulencodedParser)
 */
function addRoute(url, fileName, func, useRoot, method, extras){
	var readFile = function(req, res){
			readJsonFile(fileName, function(data){
				if(func && requiredFuncs[func]){
					requiredFuncs[func](data, res);
				} else {
					console.log("Sending file data: " +JSON.stringify(data));
					res.send(data);	
				}				
			});
		};

	var useFunc,
		funcList = [];

	if(useRoot === "true"){
		url = rootPath + url;
	}

	if(fileName){
		useFunc = readFile;
	}else if(requiredFuncs[func]){
		useFunc = requiredFuncs[func];
	}

	if(extras){
		if(extras.indexOf("cors") > -1){
			funcList.push(cors());
		}
		if(extras.indexOf("jsonParser") > -1){
			funcList.push(jsonParser);
		}
		if(extras.indexOf("urlencodedParser") > -1){
			funcList.push(urlencodedParser);
		}
	}

	funcList.push(useFunc);

	if(useFunc){
		switch(method) {
			case "POST":
				app.post(url, funcList);
				break;
			case "PUT":
				app.put(url, funcList);
				break;
			case "DELETE":
				app.delete(url, funcList);
				break;
			case "OPTIONS":
				app.options(url, funcList);
				break;
			default : //GET
				app.get(url, funcList);
				method = "GET";
		}

		if(func){
			if(fileName){
				console.log("ADDED (" + method + ")\t" + url + " -> " + fileName + " -> " + func);
			} else {
				console.log("ADDED (" + method + ")\t" + url + " -> " + func);
			}
		} else {
			console.log("ADDED (" + method + ")\t" + url + " -> " + fileName);
		}
	} else {
		console.log("ERROR ADDING: " + url);
		console.log("     NO FUNC: " + func);
	}
}

/**
 * Adds all the routes defined in the JSON config file, then the catch-all route
 */
function addRoutes() {
	var i,
		len = serverConfig.length,
		currConfig;

	for(i = len-1; i > -1; i--){
		currConfig = serverConfig[i];
		rootPath = currConfig.ROOT;
		if(currConfig.ROUTES){
			currConfig.ROUTES.forEach(
				function(curr){
					addRoute(curr.route, curr.file, curr.function, curr.useRoot, curr.method, curr.extras);
				}
			);
		}
	}
	
	
	app.all("/*", function(req, res) {
		console.log("piping ("+ req.method + "): "+req.originalUrl);
		req.pipe(request(req.originalUrl)).on('error', function(e){
			console.log(e); 
			res.statusCode = 500; 
			res.send();
		}).pipe(res);
	});
	console.log("Number of Routes: "+app._router.stack.length);	
}

/**
 * Removes a single route
 * @param  {String} url    url of the route to remove
 * @param  {String} method request method of route (get|post|put|delete|option)
 */
function removeRoute(url, method) {
	for (var i = app._router.stack.length - 1; i >= 0; i--) {
		if(app._router.stack[i].route){
			if(app._router.stack[i].route.path === url && app._router.stack[i].route.methods[method]){
				app._router.stack.splice(i, 1);
				i = 0;
				console.log("REMOVED: (" + method.toUpperCase() + ")\t" + url);
			}
		}
	}
}

/**
 * Goes through the existing serverConfig and removes all the routes defined in it
 */
function clearRoutes() {
	var url,
		method;
	removeRoute("/*", "get");

	serverConfig.forEach(function(currConfig){
		if(currConfig.ROUTES){
			rootPath = currConfig.ROOT;
			currConfig.ROUTES.forEach(
				function(curr){
					url = curr.route;
					if(curr.useRoot === "true"){
						url = rootPath + url;
					}
					if(curr.method){
						method = curr.method.toLowerCase();
					} else {
						method = "get";
					}
					removeRoute(url, method);
				}
			);
		}
	});
}

/**
 * Clears all routes and functions from the existing server config
 */
function tearDown() {
	clearRoutes();

	//get rid of the required Functions that have been used:
	serverConfig.forEach(function(currConfig){
		if(currConfig.REQUIRED_FUNCS){
			delete require.cache[require.resolve(currConfig.REQUIRED_FUNCS)];
		}
	});
	
	requiredFuncs = null;
}

/**
 * Headers sent back
 */
app.use("/*", function(req, res, next) {
	res.setHeader("X-Powered-By", "Augmentator");
	res.setHeader("Access-Control-Allow-Origin", "*");
	res.setHeader("Access-Control-Allow-Origin", "*");
	res.setHeader("Access-Control-Allow-Credentials", "true");
	res.setHeader("Access-Control-Allow-Headers", "X-Custom-Header, Content-type");
	res.setHeader("Access-Control-Allow-Methods", "POST,PUT,GET,OPTIONS,DELETE");
	res.setHeader("Keep-Alive", "timeout=15, max=98");
	res.setHeader("Connection", "Keep-Alive");
	next(); //!important
});

/**
 * Adds a new serverConfig to the Augmentator
 * @param {Request} req    original request passed through
 * @param {Response} res   original response passed through
 * @param {Boolean} append true is keeping the existing serverConfig(s)
 */
function addNewConfig(req, res, append){
	var orig = decodeURI(req.originalUrl),
		fileName = "./" + orig.substring(orig.indexOf("=")+1);
	
	console.log(fileName);

	tearDown();

	readJsonFile(fileName, function(data){
		if (!append) {
			serverConfig = [];
		}
		serverConfig.push(data);
		setUp();
		res.send("new config: " + JSON.stringify(serverConfig));
	});
}

/**
 *	Route used to listen to get a new server config
 */
app.get('/fileconfig=*', function(req, res){
	addNewConfig(req, res, false);
});


/**
 * Route used to append a new server config to the existing routes
 */
app.get('/appendfileconfig=*', function(req, res){
	addNewConfig(req, res, true);
});


/**
 *	Route used to listen to clear imported routes
 */
app.get('/clearroutes', function(req, res){
	tearDown();
	serverConfig = [];
	setUp();
	res.send("All routes cleared");
});

/**
 * Route used to stop errors from favicon.ico
 */
app.get('/favicon.ico', function(req, res){
	res.send("");
});

app.get('/', function(req, res){
	res.send("Working");
});
setUp();

var server = app.listen(process.argv[2] || 3000, function () {
	var host = server.address().address,
		port = server.address().port;

	console.log('augmentator listening at http://%s:%s', host, port);
});