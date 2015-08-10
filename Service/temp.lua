--START
pub_sem = 0
swtch = { 
	   switch1 = { interrupt = 3, output = 4},
	   switch2 = { interrupt = 5, output = 6},
	   switch3 = { interrupt = 7, output = 8},
	   switch4 = { interrupt = 1, output = 2}
		}
m = mqtt.Client( "ESP"..node.chipid(), 120, "", "")
m:connect( "192.168.42.1", 1883, 0, function(conn)
	m:subscribe("RUT", 0, function(conn)
	end)
	m:subscribe("REBOOT", 0, function(conn)
	end)
end)
function publish_device_status_change(pin, newStatus) 
	if pub_sem == 0 then
		pub_sem = 1
		m:publish("DSC", node.chipid().."-"..pin.."-"..newStatus,0,0, function(conn)
			pub_sem = 0 
		end)
	end
end
for i in pairs(swtch) do
    print(swtch[i].interrupt .. ' '.. swtch[i].output)
    gpio.mode(swtch[i].interrupt, gpio.INT)
	gpio.mode(swtch[i].output, gpio.OUTPUT)
	gpio.trig(swtch[i].interrupt,"both",function(level)
		publish_device_status_change(swtch[i].output,level)
		gpio.write(swtch[i].output,level))
end
function run_main_prog()
	m:publish("IMC", node.chipid()..'-'..wifi.sta.getip(), 0, 0 , function() end)
	m:on("message", function(conn, topic, data)
		if(topic == "REBOOT")then
			node.restart()
		end
	end )
	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
		conn:on("receive", function(client,request)
			local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
			if(method == nil)then
				_, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
			end
			if (vars ~= nil)then
				for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
					if(string.lower(v) == "on")then
						gpio.write(swtch[k].interrupt, gpio.HIGH); 
					else
						gpio.write(swtch[k].interrupt, gpio.LOW);
					end
				end
    		end
			client:send("done");
			client:close();
			collectgarbage();
		end)
	end)
	print(node.heap())
end
