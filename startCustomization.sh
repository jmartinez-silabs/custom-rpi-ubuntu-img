#!/bin/bash

echo "START CUSTOMIZATION THE IMAGE"
if sudo grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
	echo "Do nothing"
else
	sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

rm -f /home/$(whoami)/.cache/tools/images/* /tmp/raspbian-ubuntu/*

echo "===================================="
echo "1. Update submoddules"
echo "===================================="
git submodule update --init --recursive
echo "===================================="
cp -f ./script/expand.sh ./docker-rpi-emu/scripts/
echo "2. Run bootstrap for Qemu"
echo "===================================="
sudo ./script/bootstrap.sh
echo "===================================="
echo "3. Start building"
echo "===================================="
./build.sh

echo "Customization is done."
