#! /bin/bash

echo "Run customize scripts here"
UBUNTUUSER="ubuntu"
PASSWORD="ubuntu"

useradd -s /bin/bash -d /home/"$UBUNTUUSER" -m -G sudo "$UBUNTUUSER"
usermod -p $(echo "$PASSWORD" | openssl passwd -1 -stdin) "$UBUNTUUSER"
echo "$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

echo "$(hostname -I | cut -d\  -f1) $(hostname)" | tee -a /etc/hosts

ls -lh /etc/resolv.conf
unlink /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf

mv /etc/apt/apt.conf.d/70debconf /etc/apt/apt.conf.d/70debconf.bak
ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
dpkg-reconfigure debconf -f noninteractive -p critical

apt install -y git

cp -vr /repo/src/scripts /home/"$UBUNTUUSER"
mv -v /home/"$UBUNTUUSER"/scripts/README.md /home/"$UBUNTUUSER"
mv -v /home/"$UBUNTUUSER"/scripts/Versions.txt /home/"$UBUNTUUSER"

chown -hR "$UBUNTUUSER":"$UBUNTUUSER" /home/"$UBUNTUUSER"/*
chmod a+x /home/"$UBUNTUUSER"/scripts/*

# Clone repo connectedhomeip and update submodule
echo "---------------------------------------------------------"
echo "3.1 Clone repo connectedhomeip and update submodule"
echo "---------------------------------------------------------"

runuser -l "$UBUNTUUSER" -c   'cd /home/ubuntu &&
			       git clone https://github.com/project-chip/connectedhomeip.git &&
			       cd /home/ubuntu/connectedhomeip
			       git fetch &&
                               git checkout "80ee243109c" &&
			       ./scripts/checkout_submodules.py --shallow --platform linux'
				
# Clone repo ot-br-posix and update submodule
echo "---------------------------------------------------------"
echo "3.2 Clone repo ot-br-posix and update submodule"
echo "---------------------------------------------------------"
runuser -l "$UBUNTUUSER" -c   'cd /home/ubuntu
			       git clone https://github.com/openthread/ot-br-posix.git &&
			       cd /home/ubuntu/ot-br-posix
			       git fetch &&
                               git checkout "d9103922af7" &&
                               git submodule update --init --recursive'

# Add aliases for matterTool.sh and setupOTBR.sh
echo "---------------------------------------------------------"
echo "3.3 Add aliases for matterTool.sh and setupOTBR.sh"
echo "---------------------------------------------------------"
echo '# Matter related alias' | tee -a /home/$UBUNTUUSER/.bashrc
echo "alias mattertool='source /home/ubuntu/scripts/matterTool.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "alias otbrsetup='source /home/ubuntu/scripts/setupOTBR.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "alias updatetool='source /home/ubuntu/scripts/updateTool.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "export ZAP_DEVELOPMENT_PATH=/home/ubuntu/zap" | tee -a /home/"$UBUNTUUSER"/.bashrc

# Prerequisites installation
echo "---------------------------------------------------------"
echo "3.4 Install prerequisites"
echo "---------------------------------------------------------"
runuser -l "$UBUNTUUSER"  -c  'export LANGUAGE=en_US.UTF-8
			       export LC_ALL=en_US.UTF-8
			       cd /home/ubuntu/scripts
			       ./prerequisite.sh
			       rm -f prerequisite.sh'
				
# Customization clean-up
echo "---------------------------------------------------------"
echo "3.5 Clean up customization"
echo "---------------------------------------------------------"

chmod a-x /home/"$UBUNTUUSER"/scripts/matterTool.sh
mv /etc/apt/apt.conf.d/70debconf.bak /etc/apt/apt.conf.d/70debconf
rm -f /etc/resolv.conf
ln -s ../run/systemd/resolve/resolv.conf /etc/resolv.conf
#sed -i "/$(hostname -I | cut -d\  -f1) $(hostname)/d" /etc/hosts
echo "127.0.1.1 $UBUNTUUSER" | tee -a /etc/hosts
#sed -i "/$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL/d" /etc/sudoers
