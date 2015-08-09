--START
BROKER = "192.168.42.1"
BRPORT = 1883
CLIENTID = "ESP"..node.chipid()
topics = {"RUT"}

pub_sem = 0
current_topic  = 1
topicsub_delay = 50

swtch = { 
	   switch1 = { interrupt = 3, output = 4},
	   switch2 = { interrupt = 5, output = 6},
	   switch3 = { interrupt = 7, output = 8},
	   switch4 = { interrupt = 9, output = 10}
		}

for i in pairs(swtch) do
    print(swtch[i].interrupt .. ' '.. swtch[i].output)
    gpio.mode(swtch[i].interrupt, gpio.INT)
	gpio.mode(swtch[i].output, gpio.OUTPUT)
end

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
		m:publish("DSC",wifi.sta.getip().."-"..pin.."-"..newStatus,0,0, function(conn)
			pub_sem = 0 
		end)
	end
end

function switchCallback(level, s)
	publish_device_status_change("pin0",level)
	print(s)
	print("Level changed : "..level)
	gpio.write(swtch['switch1'].output,level)
end

gpio.trig(swtch['switch1'].interrupt,"both",switchCallback(1))

function run_main_prog()
	m:publish("IMC", node.chipid()..'-'..wifi.sta.getip(), 0, 0 , function() end)
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
			local buf = ""
			if (vars ~= nil)then
				for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
					if(string.lower(v) == "on")then
						gpio.write(swtch[k].interrupt, gpio.HIGH);
						buf = buf .. "{'" .. k .. "':'" .. v .. "'}"  
					else
						gpio.write(swtch[k].interrupt, gpio.LOW);
						buf = buf .. "{'" .. k .. "':'" .. v .. "'}"
					end
				end
    		end
			client:send(buf);
			client:close();
			collectgarbage();
		end)
	end)
end
