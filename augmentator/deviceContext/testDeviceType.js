var deviceContext = require('./deviceContext.js');
var arrayStr = ["Test","Two","Three"];

//mock request / response object
var res = {
	send: function(obj) {
		console.dir(obj);
	}
};

var req = {
	query : {
		file: "deviceType.json"
	}
};

deviceContext.setDeviceType(arrayStr);
console.log('Device Types persisted as:');
console.log(deviceContext.getDeviceType());
deviceContext.setDeviceTypeList(arrayStr);
console.log('Device Type List persisted as:');
console.log(deviceContext.getDeviceTypeList());

console.log('getCurrentContext augmentor response should now return:');
console.log(deviceContext.getCurrentContext(null,res));

