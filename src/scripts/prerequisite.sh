#!/bin/bash

sudo apt purge -y needrestart
sudo apt autoremove -y

sudo apt update
sudo apt install -y gcc g++ pkg-config libssl-dev libdbus-1-dev net-tools openssh-server \
     libglib2.0-dev libavahi-client-dev ninja-build python3.10-venv python3-dev \
     python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev curl

sudo apt install -y pi-bluetooth avahi-utils

cd ~/
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
#sudo dpkg -i --force-overwrite /var/cache/apt/archives/nodejs_16.19.0-deb-1nodesource1_arm64.deb
sudo apt -y install nodejs

cd ~/
git clone https://github.com/project-chip/zap.git
cd zap
git checkout "4f2a3d6cc1bf51"

sudo apt install -y --fix-missing libpixman-1-dev libcairo-dev libsdl-pango-dev libjpeg-dev libgif-dev

npm ci

cd ~/
export ZAP_DEVELOPMENT_PATH="$HOME/zap"
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

cd scripts
# Smaller footprint bootstrap (prepare the minimal environment for chipt-tool)
$HOME/connectedhomeip/scripts/build/gn_bootstrap.sh
# Clean build of chip-tool
./matterTool.sh buildCT

# Build and install otbr
./setupOTBR.sh -if wlan0 -s
./setupOTBR.sh -i

sudo ufw allow 22/tcp
sudo apt install -y needrestart
sudo apt --fix-missing update -y
sudo apt install -f -y

cd ~/
