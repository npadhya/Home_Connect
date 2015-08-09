var fileSystem = require('fs');
var client = mqttClient.connect('mqtt://192.168.42.1');

client.subscribe("DSC");
client.subscribe("IMC");

client.on("message", function(topic, payload) {
	if(topic === 'IMC'){
		console.log("IMC");
		
		var strPayload = payload.toString('utf8');
		var deviceDetail = strPayload.split('-');
		var deviceID = deviceDetail[0];
		var deviceIP = deviceDetail[1];

		var chipObject = {};
		chipObject["RoomName"] = "Default Room";
		chipObject["ipAddress"] = deviceIP;

		deviceList[deviceID] = chipObject;

		fileSystem.writeFile('deviceList.json', JSON.stringify(deviceList), function (err) {
			if (err) throw err;
			console.log('The DeviceList updated on disk!');
		});
	} else if ( topic === 'DSC'){
		console.log("DSC");
		
		var strPayload = payload.toString('utf8');
		var deviceStatusDetail = strPayload.split('-');

		var deviceIP = deviceStatusDetail[0];
		var gpioPin = deviceStatusDetail[1];
		var newStatus = deviceStatusDetail[2];

		var gpioDetail = {};
		gpioDetail["DeviceName"] = "Default Light";
		gpioDetail["Status"] = newStatus;

		var devices = deviceStatus[deviceIP];
		if (devices === undefined){
			var tempDevice = {};
			tempDevice[gpioPin] = gpioDetail;
			deviceStatus[deviceIP] = tempDevice;
		} else {
			deviceStatus[deviceIP][gpioPin] = gpioDetail;
		}
		//devices[gpioPin] = gpioDetail;
		//deviceStatus[deviceIP] = devices;

		fileSystem.writeFile('deviceStatus.json', JSON.stringify(deviceStatus), function (err) {
			if (err) throw err;
			console.log('The DeviceList updated on disk!');
		});
	}
});

client.publish("IMC", "hello world!");
