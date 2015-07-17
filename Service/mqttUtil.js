var client = mqttClient.createClient();

client.subscribe("IMC");

client.on("message", function(topic, payload) {
  console.log(topic + " : " + payload);
  client.end();
});

client.publish("mqtt/demo", "hello world!");
