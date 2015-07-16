BROKER = "192.168.42.1"
BRPORT = 1883
CLIENTID = "ESP82661"
topics = {"RUT"}

pub_sem = 0
current_topic  = 1
topicsub_delay = 50

gpioMap = {[0]=3,[2]=4}

switch0 = gpioMap[0]
switch2 = gpioMap[2]

gpio.mode(switch0, gpio.INT)
gpio.mode(switch2, gpio.OUTPUT)

m = mqtt.Client( CLIENTID, 120, "", "")
m:connect( BROKER , BRPORT, 0, function(conn)
	mqtt_sub()
end)

function mqtt_sub()
	if table.getn(topics) < current_topic then
		run_main_prog()
	else
		m:subscribe(topics[current_topic] , 0, function(conn)
		end)
		current_topic = current_topic + 1  -- Goto next topic
		tmr.alarm(5, topicsub_delay, 0, mqtt_sub )
	end
end

function publish_device_status_change(pin, newStatus)
	if pub_sem == 0 then
		pub_sem = 1
		m:publish("DSC",pin.."-"..newStatus,0,0, function(conn)
			pub_sem = 0 
		end)
	end
end

function switch0Callback(level)
	publish_device_status_change("pin0",level)
	print("Level changed : "..level)
	gpio.write(switch2,level)
end

gpio.trig(switch0,"both",switch0Callback)

function run_main_prog()
	m:publish("IMC", wifi.sta.getip(), 0, 0 , function() end)
	m:on("message", function(conn, topic, data)
		if (data ~= nil ) then
		end
	end )
	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
		conn:on("receive", function(client,request)
			local buf = "";
			local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
			if(method == nil)then
				_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
			end
			local _GET = {}
			if (vars ~= nil)then
			for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
				_GET[k] = v
			end
    end
		local _on,_off = "",""
		if(_GET.switch0 == "ON")then
			buf="{'Switch0':'ON'}"
			gpio.write(switch0, gpio.HIGH);
		elseif(_GET.switch0 == "OFF")then
			buf="{'Switch0':'OFF'}"
			gpio.write(switch0, gpio.LOW);
		end
		client:send(buf);
		client:close();
		collectgarbage();
		end)
	end)
end
