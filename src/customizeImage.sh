#! /bin/bash

echo "Run customize scripts here"
UBUNTUUSER="ubuntu"

useradd -s /bin/bash -d /home/"$UBUNTUUSER" -m -G sudo "$UBUNTUUSER"
usermod -p $(echo "$UBUNTUUSER" | openssl passwd -1 -stdin) "$UBUNTUUSER"
echo "$UBUNTUUSER ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

echo "$(hostname -I | cut -d\  -f1) $(hostname)" | tee -a /etc/hosts

ls -lh /etc/resolv.conf
unlink /etc/resolv.conf
#echo "nameserver 127.0.0.53" | tee /etc/resolv.conf
echo "nameserver 8.8.8.8" | tee /etc/resolv.conf

#mv /etc/apt/apt.conf.d/70debconf /etc/apt/apt.conf.d/70debconf.bak
ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
dpkg-reconfigure debconf -f noninteractive -p critical

apt purge -y needrestart
apt autoremove -y

apt install -y git

cp -vr /repo/src/scripts /home/"$UBUNTUUSER"

chown -hR "$UBUNTUUSER":"$UBUNTUUSER" /home/"$UBUNTUUSER"/*
chmod a+x /home/"$UBUNTUUSER"/scripts/*

# Clone repo connectedhomeip and update submodule
echo "---------------------------------------------------------"
echo "3.1 Clone repo connectedhomeip and update submodule"
echo "---------------------------------------------------------"

runuser -l "$UBUNTUUSER" -c   'cd /home/ubuntu &&
				git clone https://github.com/project-chip/connectedhomeip.git &&
			     	cd /home/ubuntu/connectedhomeip &&
			     	git checkout 4d50b1084 &&
				git submodule update --init --recursive'
				
# Clone repo ot-br-posix and update submodule
echo "---------------------------------------------------------"
echo "3.2 Clone repo ot-br-posix and update submodule"
echo "---------------------------------------------------------"
runuser -l "$UBUNTUUSER" -c    'cd /home/ubuntu &&
				git clone https://github.com/openthread/ot-br-posix.git &&
			      	cd /home/ubuntu/ot-br-posix &&
			     	git checkout f0bd216 &&
				git submodule update --init --recursive'

# Add aliases for matterTool.sh and setupOTBR.sh
echo "---------------------------------------------------------"
echo "3.3 Add aliases for matterTool.sh and setupOTBR.sh"
echo "---------------------------------------------------------"
echo '# Matter related alias' | tee -a /home/$UBUNTUUSER/.bashrc
echo "alias mattertool='source /home/ubuntu/scripts/matterTool.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "alias otbrsetup='source /home/ubuntu/scripts/setupOTBR.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "alias prerequisites='source /home/ubuntu/scripts/prerequisites.sh'" | tee -a /home/"$UBUNTUUSER"/.bashrc
echo "alias python='source /usr/bin/python3'" | tee -a /home/"$UBUNTUUSER"/.bashrc

# Prerequisites installation
echo "---------------------------------------------------------"
echo "3.4 Install prerequisites"
echo "---------------------------------------------------------"
runuser -l "$UBUNTUUSER"  -c   'export LANGUAGE=en_US.UTF-8
				export LC_ALL=en_US.UTF-8
				cd /home/ubuntu/scripts &&
				./prerequisites.sh'
				
# Customization clean-up
echo "---------------------------------------------------------"
echo "3.5 Clean up customization"
echo "---------------------------------------------------------"

#apt-get update -y
apt install -y needrestart python3-apt
#mv /etc/apt/apt.conf.d/70debconf.bak /etc/apt/apt.conf.d/70debconf
rm -f /etc/resolv.conf
ln -s ../run/systemd/resolve/resolv.conf /etc/resolv.conf
grep -v "echo $(hostname -I | cut -d\  -f1) $(hostname)" /etc/hosts > tmpfile && mv tmpfile /etc/hosts
grep -v "echo $UBUNTUUSER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers > tmpsudoers && mv tmpsudoers /etc/sudoers
