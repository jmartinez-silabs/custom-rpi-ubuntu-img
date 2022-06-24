#!/bin/bash

sudo dpkg --configure -a

sudo add-apt-repository ppa:deadsnakes/ppa -y

sudo apt-get install -y python3.9 -y
sudo unlink /usr/bin/python3
sudo ln -s /usr/bin/python3.9 /usr/bin/python3
sudo ln -s /usr/bin/python3 /usr/bin/python

#su ubuntu
sudo apt install -y git gcc g++ python2-minimal python2 dh-python 2to3 python-is-python3 \
						pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build \
						python3.9-lib2to3 python3.9-venv python3.9-dev python3.9-tk python3-pip \
						unzip libgirepository1.0-dev libcairo2-dev libreadline-dev

#sudo /run/init.d/bus start
sudo apt install -y pi-bluetooth avahi-utils
#su ubuntu
#sudo /sbin/reboot

#sudo shutdown -r now

#sudo telinit 6

#sudo sysctl --value kernel.panic
#sudo sysctl kernel.reboot=1

cd ~/
export MATTER_ROOT=$HOME/connectedhomeip
export CHIPTOOL_PATH=$HOME/connectedhomeip/out/standalone/chip-tool
export NODE_ID=31354
export THREAD_DATA_SET
export PINCODE=20202021
export DISCRIMINATOR=3840
export SSID
export lastNodeId=0

cd scripts &&

./setupOTBR.sh -if wlan0 -s &&
./setupOTBR.sh -i &&
./matterTool.sh buildCT &&

sudo apt autoremove

sudo apt --fix-missing update
sudo apt update
sudo apt install -f
sudo apt clean

cd ~/
