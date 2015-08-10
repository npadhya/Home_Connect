#!/bin/bash

echo "******************************************************************************"
echo "*                                                                            *"
echo "*   Welcome to ESP Prepairation kit, This Script will prepair your ESP       *"
echo "*       STEPS:                                                               *"
echo "*             1.  Connect GPIO0 to GND                                       *"
echo "*                 This script will Flash ESP with nodemcu loader             *"
echo "*             2. Wait for the Flashing to finish                             *"
echo "*             3. During the 10 Sec wait, remove GPIO0 and GND connection     *"
echo "*             4. It will load init.lua and main.lua(compiled)  on the ESP    *"
echo "*                                                                            *"
echo "*                                                                            *"
echo "******************************************************************************"

cd ~/Git/Home_Connect/ROMs
sudo python ../ESPtools/esptool.py -p /dev/ttyAMA0 write_flash 0x00 latest-nodemcu-custom-integer.bin
cd ..
echo "******************************************************************************"
echo "*                                                                            *"
echo "*       Flash complete. Disconnect GPIO0 from GND and reboot the ESP         *"
echo "*                                                                            *"
echo "******************************************************************************"
echo "Flash complete. Disconnect GPIO0 from GND and reboot the ESP"
sleep 10
cd ~/Git/Home_Connect/LUA_src
sudo python ../ESPtools/nodemcu-uploader.py upload init.lua
echo "******************************************************************************"
echo "*                                                                            *"
echo "*       init.lua loaded, main.lua will be compiled and load on ESP           *"
echo "*                                                                            *"
echo "******************************************************************************"
sleep 2
sudo python ../ESPtools/nodemcu-uploader.py upload main.lua --compile
echo "******************************************************************************"
echo "*                                                                            *"
echo "*                                 ALL DONE!!!                                *"
echo "*                                                                            *"
echo "******************************************************************************"

