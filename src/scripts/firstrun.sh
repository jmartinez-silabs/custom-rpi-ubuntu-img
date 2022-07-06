#!/bin/bash

./setupOTBR.sh -if wlan0 -s &&
./setupOTBR.sh -i &&

sudo reboot now

#sudo systemctl status | grep otbr
#sudo systemctl status | grep avahi
#sudo ot-ctl state 
