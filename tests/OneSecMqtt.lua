BROKER = "192.168.42.1"
BRPORT = 1883
CLIENTID = "ESP82661"

pub_sem = 0
current_topic  = 1

m = mqtt.Client( CLIENTID, 120, "", "")
m:connect( BROKER , BRPORT, 0, function(conn)
  run_main_prog()
end)

function mqtt_pub()
 current_topic = current_topic + 1
	m:publish("DSC", current_topic,0,0, function(conn)
	  print(current_topic)
	end)
end

function run_main_prog()
    tmr.alarm(5, 1000, 1, mqtt_pub )
end
