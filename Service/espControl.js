var espControl = {
	setControl : function(roomName, listOfDevice, setControlCallback){
		console.log("Setting Device ");

		var finalCommand="";

		for(var device in listOfDevice){
			// console.log(device);
			//console.log(listOfDevice[device]);
			var listInNode  =rooms[roomName].devices;
			//console.log(listInNode[device]);
			finalCommand += listInNode[device] + "=" + listOfDevice[device] + "&";
		}
		

		var url = "http://"+rooms[roomName].ip + "/?" + finalCommand;
		console.log(url);
		request({uri: url, timeout: 10000},function (error, response,body) {
			if (body) {
				setControlCallback("OK", undefined);
			}else{
				setControlCallback(undefined, {"Error" : "Endpoint Not reachable", "ErrorCode" : "100"});
			}
		});
	},
	getHomeInfo : function(getHomeInfoCallback){
		// This method is to maintain the logical layering of the application
		// plus this method can be used in future to massage deviceStatus DAO
		getHomeInfoCallback(deviceStatus);
	},
	getConnectedDevices : function(getConnectedDevicesCallback){
		// This method is to maintain the logical layering of the application
		// plus this method can be used in future to massage deviceStatus DAO
		getConnectedDevicesCallback(deviceList);
	}
}

module.exports = espControl;
