-- Configuration to connect to the MQTT broker.
BROKER = "192.168.42.1"   -- Ip/hostname of MQTT broker
BRPORT = 1883             -- MQTT broker port
--BRUSER = ""           -- If MQTT authenitcation is used then define the user
--BRPWD  = ""            -- The above user password
CLIENTID = "ESP82661"     -- The MQTT ID. Change to something you like

-- Control variables.
pub_sem = 0         -- MQTT Publish semaphore. Stops the publishing, if the previous hasn't ended
current_topic  = 1  -- variable for one currently being subscribed to

-- connect to the broker
print("Connecting to MQTT broker. Please wait...")
m = mqtt.Client( CLIENTID, 120, "", "")
m:connect( BROKER , BRPORT, 0, function(conn)
	print("Connected to MQTT:" .. BROKER .. ":" .. BRPORT .." as " .. CLIENTID )
	run_main_prog()
end)

function mqtt_sub()
	m:subscribe("RUT" , 1, function(conn)
		print("Subscribed topic : RUT")
	end)
end

--main program to run after the subscriptions are done
function run_main_prog()
  mqtt_sub() --run the subscription function
	m:on("message", function(conn, topic, data)
		print(topic .. " : " )
		if (data ~= nil ) then
			print ( data )
		end
		current_topic = current_topic + 1
	  m:publish("DSC", current_topic,1,0, function(conn)
	    print(current_topic)
	  end)
	end)
end
