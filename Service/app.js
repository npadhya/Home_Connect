'use strict';
global.request = require('request');
global.async = require('async');
var express = require('express');
var http = require('http');
global.querystring = require('querystring');
var espControl = require('./espControl.js');
var util = require('util');

//global.rooms = {"room1":"192.168.42.14", "room2" : "192.168.42.16"};
global.devices = {"Light1":"pin1", "Light2":"pin2"};

global.rooms = {
	"Room1" : {
		"ip" : "192.168.42.14",
		"devices" : {
			"Light1" : "pin1",
			"Light2" : "pin2"
		}
	},
	"Room2" : {
		"ip" : "192.168.42.14",
		"devices" : {
			"Light1" : "pin1",
			"Light2" : "pin2"
		}
	}
};

var app = express();

var httpServer = http.createServer(app).listen(8080, function(){
	console.log('Home_Control app started on port %d', 8080);
});

app.use(express.static(__dirname + '/public')); 
app.set('view engine', 'html');

// --------------------------------------------------------------
// Define route middleware that will happen on every request and log request activity
var router = express.Router();

router.use(function(req, res, next) {
	// log each request to the console
	res.setHeader("Content-Type", "application/json");
	res.setHeader("Access-Control-Allow-Origin","*");
	console.log(req.method, req.url);
	// continue doing what we were doing and go to the route
	next(); 
});
// --------------------------------------------------------------

app.use('/', router);

app.get('/', function(req,res){
	res.sendfile('index.html',{
		root: __dirname+'/public'
	});
});


app.get('/setDeviceStatus', function(req, res){
	var roomName = req.query.room;

	var deviceStatus = req.query;
	delete deviceStatus.room;
	console.log(roomName);
	console.log(deviceStatus);
	espControl.setControl(roomName, deviceStatus, function(response, error){
		if(error){
			res.send(error);
		}else{
			console.log('Device status changed');
			res.send(response);
		}
	});
});

app.get('/getHomeInfo', function(req, res){
	espControl.getHomeInfo(function(returnObj){
		//res.send(returnObj);
		res.send(JSON.stringify(returnObj));
		console.log(returnObj);
	});
});

app.get('/getDeviceStatus', function(req, res){

});

// This endpoint will be called by EPS to add them self in the Home_Connect app.
app.post('/addDeviceInfo', function(req, res){

});
