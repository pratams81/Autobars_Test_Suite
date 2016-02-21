var http = require('http'),
	querystring = require('querystring'),
	zlib = require('zlib');

function _augmentTitleResponse (data, callback) {
	var jsonTemplate = data, i,
		length = jsonTemplate.programmes.length;
	console.log("changing title for BTV Events: " + length);
	for (i = 0; i < length; i++){
		jsonTemplate.programmes[i].Title = "Meh " + jsonTemplate.programmes[i].Title;
	}

	callback(data);
}

var getProgrammes = function(req, res) {
	console.log(req.originalUrl);
	http.get(req.originalUrl, function(res2) {
		var programmes = "";
		res2.on("data", function(chunk) {
			programmes += chunk;
		});
		res2.on("end", function(){
			var respond = function(data) {
					programmes = data;
					res.send(programmes);
				}, 
				programmesObj = JSON.parse(programmes);
				_augmentTitleResponse(programmesObj, respond);
		});
	});
};

var amendSession = function(data, res) {
	data.resultCode = "1";
	console.log("Sending file data: " +JSON.stringify(data));
	res.send(data);
};

function _augmentLogon(data, callback) {
	data = {"token":null,"resultCode":"0","result":{"status":"PLAYER_UPGRADE_RECOMMENDED","masterVersion":"NagraQA.2.11.0","downloadURL":"http://ott.nagra.com/players/NagraQA.2.11.0/NagraQA_plugin.exe","response":"ARoRFoEBAYIBBoUBAIMBAoQCX5eGBFUJdyESAAKBgJ0Flk16pVZZyXazlwpJTuh7FNkS4bDEceuL\r\n+d7SbHQCgKpWnXHHkFx/g4M22Ln/+5Xm56UuGXT8w5+t8+Y1IJmAh+xLJbHcvF3Kig5unczKf0QE\r\nsabQAYRHkhCE+ohBqJdIF2wulDoPOAXVAMgPU/ZUVdw5cCemjE4Dac2/HcedA3AZflEU3x4rmBwU\r\nFi2mCGQ6iMQ5pAzeNFK7Gfsz/Ep6+unPSiRXl84mNw5SK0lPdklWqTsYu9A9jyefDPWnq+6DHeX0\r\ngx6QgWF5fYbhVZ1T28oo+6yvKk1SL41KRPPNMisigujx1AhCbDzZgmZTCwH0BIGAPy8Fc/wuRigO\r\ngA2uwMYQFHJazNfn2kM/i/fLb5roQcGfk4D8arqVKYZTF/w/hzxnLrRYufG3nhjpSPWN0IVkYQiB\r\nmgo4Za7UpcyHEquCanGBzP0KxJmM4mkURlahqfQBj8iTtv+gqUPR7qkEMcaZ2C/F9iyb4CwsCZkK\r\nPh3w3F0=\r\n"},"requestId":1061613147};
	//data.result.status="AUTHENTICATION_ERROR";
	callback(data);
}

var forceLogon = function(req, res) {
	var postData = querystring.stringify(req.body);
	var options = {
		host : req._parsedUrl.host,
		path : req._parsedUrl.path,
		method : "POST",
		headers : req.headers
	};
	var req2 = http.request(options, function(res2) {
		var data = "",
			gzip = zlib.createGunzip();
		
		res2.pipe(gzip);

		gzip.on("data", function(chunk) {
			console.log("getting data");
			data += chunk.toString();
		});
		gzip.on("end", function(){
			console.log("ending: "+ data);
			var respond = function(data) {
					res.send(data);
				}, 
				dataObj = JSON.parse(data);
				_augmentLogon(dataObj, respond);
		});
	});
	req2.on('error', function(e){
		console.log("Error occurred: "+ e.message);
	});
	req2.write(postData);
	req2.end();
};

var showMeh = function(req, res) {
	res.send("meh");
};

module.exports.getProgrammes  = getProgrammes;
module.exports.amendSession = amendSession;
module.exports.forceLogon = forceLogon;
module.exports.showMeh = showMeh;
