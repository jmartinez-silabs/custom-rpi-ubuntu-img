#!/bin/bash
if grep "$(whoami) ALL=(ALL) NOPASSWD:ALL" /etc/sudoers
then
    echo
else
    sudo echo "$(whoami) ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
fi

./setupOTBR.sh -if wlan0 -s &&
./setupOTBR.sh -i &&

sed -i "/$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers

sudo reboot now
