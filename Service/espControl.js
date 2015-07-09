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
		var returnObj = {};
		var keys = Object.keys(rooms);
		for(var key in keys ){
			var room = keys[key];
			//console.log(room);
			//returnObj.push(room);

			var deviceList = rooms[room].devices;
			var deviceKeys = Object.keys(deviceList);

			returnObj[room] = deviceKeys;
		}
		getHomeInfoCallback(returnObj);
	}
}

module.exports = espControl;
