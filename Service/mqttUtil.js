var client = mqttClient.connect('mqtt://192.168.42.1');

client.subscribe("DSC");
client.subscribe("IMC");


client.on("message", function(topic, payload) {
  if(topic === 'IMC'){
    console.log("IMC");
    console.log(payload);
  } else if ( topic === 'DSC'){
    console.log("DSC");
    console.log(payload);
  }
});

client.publish("IMC", "hello world!");
