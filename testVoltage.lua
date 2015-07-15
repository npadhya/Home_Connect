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

local header = ''
local isTruncated = false

function save(filename, response)
	print('--------')
	print(response)
	print('--------')
	if isTruncated then
		file.write(response)
		return
	end
	header = header..response
	local i, j = string.find(header, '\r\n\r\n')
	if i == nil or j == nil then
		return
	end
	prefixBody = string.sub(header, j+1, -1)
	file.write(prefixBody)
	header = ''
	isTruncated = true
	return
end

function tglfn()
	conn = net.createConnection(net.TCP, false)
	conn:on('receive', function(sck, response)
		save("test.lua", response)
        end)
	conn:connect(8080,"192.168.42.1")
	conn:send("GET /getMCUInfo HTTP/1.1\r\nHOST: iol.esp\r\nConnection: close\r\nAccept:/\r\n\r\n")
	conn:on('disconnection', function(sck, response)
		function reset()
			header = ''
			isTruncated = false
			file.close()
			tmr.stop(0)
			print('test.lua.. saved')
		end
		tmr.alarm(0, 2000, 1, reset)
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
