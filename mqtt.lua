-- Configuration to connect to the MQTT broker.
BROKER = "192.168.42.1"   -- Ip/hostname of MQTT broker
BRPORT = 1883             -- MQTT broker port
BRUSER = ""           -- If MQTT authenitcation is used then define the user
BRPWD  = ""            -- The above user password
CLIENTID = "ESP82661"     -- The MQTT ID. Change to something you like

-- MQTT topics to subscribe
topics = {"RUT"} -- Add/remove topics to the array

-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing, if the previous hasn't ended
current_topic  = 1  -- variable for one currently being subscribed to
topicsub_delay = 50 -- microseconds between subscription attempts, worked for me (local network) down to 5...YMMV
id1 = 0
id2 = 0

-- New GPIO mapping table for NodeMCU
gpioMap = {[0]=3,[1]=10,[2]=4,[3]=9,[4]=1,[5]=2,[10]=12,[12]=6,[14]=5,[15]=8,[16]=0}

switch0 = gpioMap[0]
switch1 = gpioMap[1]
switch2 = gpioMap[2]
switch3 = gpioMap[3]
switch4 = gpioMap[4]

gpio.mode(switch0, gpio.INT)
gpio.mode(switch2, gpio.OUTPUT)

-- connect to the broker
print "Connecting to MQTT broker. Please wait..."
m = mqtt.Client( CLIENTID, 120, BRUSER, BRPWD)
m:connect( BROKER , BRPORT, 0, function(conn)
	print("Connected to MQTT:" .. BROKER .. ":" .. BRPORT .." as " .. CLIENTID )
	
	mqtt_sub() --run the subscription function
end)

function mqtt_sub()
	if table.getn(topics) < current_topic then
		-- if we have subscribed to all topics in the array, run the main prog
		run_main_prog()
	else
		--subscribe to the topic
		m:subscribe(topics[current_topic] , 0, function(conn)
			print("Subscribing topic: " .. topics[current_topic - 1] )
		end)
		current_topic = current_topic + 1  -- Goto next topic
		--set the timer to rerun the loop as long there is topics to subscribe
		tmr.alarm(5, topicsub_delay, 0, mqtt_sub )
	end
end

-- publish_device_status_change functions:
-- Int GPIO pin will call this function with GPIO,newStatus
-- This function use a simple semaphor locking for multiple events (Does this required ??)
function publish_device_status_change(pin, newStatus)
	-- If semaphor is locked, We need to think about queue for the coming events
	if pub_sem == 0 then  -- Is the semaphore set?
		pub_sem = 1       -- Nop. Let's block it
		m:publish("DSC",pin..newStatus,0,0, function(conn) 
			-- Callback function. We've sent the data
			print("Sent DSC : "..pin.." - "..newStatus)
			pub_sem = 0  -- Unblock the semaphore
		end)
	-- else
	--		publish_device_status_change(pin,newStatus) -- Recursively call the method to see semaphor unlocked
	end  
end

function switch0Callback(level)
	publish_device_status_change("pin0",level)
	print("Level changed : "..level)
	gpio.write(switch2,level)
end

gpio.trig(switch0,"both",switch0Callback)

--main program to run after the subscriptions are done
function run_main_prog()
	print("Main program")
	--m:publish("IMC", wifi.sta.getip(), 0, 0 , function(conn) end)
	--tmr.alarm(2, 5000, 1, publish_data1 )
	--tmr.alarm(3, 6000, 1, publish_data2 )
	-- Callback to receive the subscribed topic messages. 
	m:on("message", function(conn, topic, data)
		print(topic .. " : " )
		if (data ~= nil ) then
			print ( data )
		end
	end )
end
