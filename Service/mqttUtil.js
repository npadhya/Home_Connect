var client = mqttClient.connect('192.168.42.1:1883');

client.subscribe("IMC");

client.on("message", function(topic, payload) {
  console.log(topic + " : " + payload);
  client.end();
});

client.publish("mqtt/demo", "hello world!");
