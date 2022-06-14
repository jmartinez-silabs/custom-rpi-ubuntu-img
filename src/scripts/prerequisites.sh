#!/bin/bash

sudo apt autoremove -y
sudo apt update -y
#sudo apt upgrade -y

sudo apt install -y git gcc g++ python3 software-properties-common \
		    pkg-config libssl-dev libdbus-1-dev libglib2.0-dev \
		    libavahi-client-dev ninja-build python3-venv python3-dev \
     		    python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev

sudo apt install -y pi-bluetooth avahi-utils

python3 --version

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
./matterTool.sh buildCT

cd ~/
