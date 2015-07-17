var client = mqttClient.connect('192.168.42.1:1883');

client.subscribe("DSC");
console.log("This is Working")
client.on("message", function(topic, payload) {
  console.log(topic + " : " + payload);
  client.end();
});

client.publish("IMC", "hello world!");
