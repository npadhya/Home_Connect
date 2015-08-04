-- This file should be uploaded as main.lc i.e. should be compiled and uploaded
-- using uplode '--compile' option

SSID    = "Home_Connect"
APPWD   = "nopassword4me"

-- Some control variables
wifiTrys     = 0      -- Counter of trys to connect to wifi
NUMWIFITRYS  = 50    -- Maximum number of WIFI Testings while waiting for connection

function tglfn()
	local buf =""
	conn = net.createConnection(net.TCP, false)
	conn:connect(8080,"192.168.42.1")
	conn:send("GET /getCodeFromServer HTTP/1.1\r\nHOST: iol.esp\r\nConnection: close\r\nAccept:/\r\n\r\n")
	conn:on("connection", function(conn, pl)
		print("Connected. Now creating file temp.lua")
		file.open("temp.lua","w")
	end)
	conn:on("receive", function(conn,pl)
		--print(pl)
		if(pl ~= nil) then
			--file.write(pl)
			buf = buf..pl
		else
			print("Cant understand Payload")
		end
	end)
	conn:on('disconnection', function(sck, response)
		print("Connection closed from server")
		local function reset()
			header = ''
			--print(buf)
			local i,j = string.find(buf, "--START")
			print('i : '..i)
			print('j : '..j)
			file.write(string.sub(buf,j+1))
			file.close()
			dofile("test.lua")
			tmr.stop(0)
		end
		tmr.alarm(0, 2000, 1, reset)
	end)
end

-- Change the code of this function that it calls your code.
function launch()
	print("Connected to WIFI!")
	print("IP Address : " .. wifi.sta.getip())
	-- Call our command file
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
