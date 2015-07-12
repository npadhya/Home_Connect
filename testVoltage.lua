-- New GPIO mapping table for NodeMCU
gpioMap = {[0]=3,[2]=4}

switch0 = gpioMap[0]
switch2 = gpioMap[2]

gpio.mode(switch0, gpio.OUTPUT)
gpio.mode(switch2, gpio.OUTPUT)
gpio.write(switch2,gpio.LOW)
--tmr.alarm(0, 1000, 0, function() gpio.write(switch2,gpio.HIGH) end)

SSID    = "Home_Connect"
APPWD   = "nopassword4me"
--CMDFILE = "mqtt.lua"   -- File that is executed after connection

-- Some control variables
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 50    -- Maximum number of WIFI Testings while waiting for connection

function tglfn()
	conn = net.createConnection(net.TCP, false)
	conn:connect(8080,"192.168.42.1")
	conn:send("GET /getMCUInfo HTTP/1.0\r\nHOST: iol.esp\r\nConnection: close\r\nAccept:/\r\n\r\n")
	conn:on("receive", function(conn,pl)
		i,j = string.find(pl,'\r\n\r\n')
		script = string.sub(pl,j+1,-1)
		print(script)
		file.open("test.lua","w")
		file.write(script)
		file.close()
		--node.compile("test.lua")
		--dofile("test.lua")
		--dofile("test.lc")
	end)
end

-- Change the code of this function that it calls your code.
function launch()
	print("Connected to WIFI!")
	print("IP Address : " .. wifi.sta.getip())
	-- Call our command file
	gpio.write(switch2,gpio.HIGH)
	tmr.alarm(2, 2000, 0, tglfn) --call tglfn only once
end

function checkWIFI() 
	if ( wifiTrys > NUMWIFITRYS ) then
		print("Sorry. Not able to connect")
	else
		ipAddr = wifi.sta.getip()
		if ( ( ipAddr ~= nil ) and  ( ipAddr ~= "0.0.0.0" ) )then
			-- lauch()        -- Cannot call directly the function from here the timer... NodeMcu crashes...
			tmr.alarm( 1 , 500 , 0 , launch )
		else
			-- Reset alarm again
			tmr.alarm( 0 , 1000 , 0 , checkWIFI)
			print("Checking WIFI... " .. wifiTrys)
			wifiTrys = wifiTrys + 1
		end 
	end 
end

print("-- Starting up! ")

-- Lets see if we are already connected by getting the IP
ipAddr = wifi.sta.getip()
if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
	-- We aren't connected, so let's connect
	print("Configuring WIFI....")
	wifi.setmode( wifi.STATION )
	wifi.sta.config( SSID , APPWD)
	print("Waiting for connection")
	tmr.alarm( 0 , 1000 , 0 , checkWIFI )  -- Call checkWIFI 1S in the future.
else
	-- We are connected, so just run the launch code.
	launch()
end
-- Drop through here to let NodeMcu run
