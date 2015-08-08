#!/bin/bash

echo "Make sure to connect GPIO0 to GND and restart the ESP"
cd ~/Git/Home_Connect/ROMs
sudo python ../ESPtools/esptool.py -p /dev/ttyAMA0 write_flash 0x00 nodemcu-custom-float.bin
cd ..
echo "Flash complete. Disconnect GPIO0 from GND and reboot the ESP"
sleep 10
cd ~/Git/Home_Connect/LUA_src
sudo python ../ESPtools/nodemcu-uploader.py upload init.lua
sleep 2
sudo python ../ESPtools/nodemcu-uploader.py upload main.lua --compile

