#!/bin/bash

sudo apt purge -y needrestart
sudo apt autoremove -y

sudo apt update
sudo apt install -y gcc g++ pkg-config libssl-dev libdbus-1-dev \
     libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
     python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev

sudo apt install -y pi-bluetooth avahi-utils

cd ~/
export MATTER_ROOT="$HOME/connectedhomeip"
export CHIPTOOL_PATH="$MATTER_ROOT/out/standalone/chip-tool"
export PINCODE=20202021
export DISCRIMINATOR=3840
export ENDPOINT=1
export NODE_ID=$((1 + $RANDOM % 100000))
export lastNodeId=0
export THREAD_DATA_SET=0
export lastNodeId=0
export SSID

cd scripts &&

./matterTool.sh buildCT &&
./setupOTBR.sh -if wlan0 -s &&
./setupOTBR.sh -i

sudo apt install -y needrestart
sudo apt --fix-missing update -y
sudo apt install -f -y

cd ~/
