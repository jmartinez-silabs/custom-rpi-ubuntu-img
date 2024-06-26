#!/bin/bash
# Expand partition 2 of an ISO image the specified amount

if [ "$#" -ne 2 ]; then 
    echo "Usage: $0 IMAGE SIZE"
    echo "IMAGE - raspberry pi .img file"
    echo "SIZE - size in mb to expand image"
    exit
fi

echo "Starting Expansion" && echo

fdisk -lu $1

# Attach loopback device
LOOP_BASE=`losetup -f --show $1`

echo && echo "Attached base loopback at: $LOOP_BASE"

BLOCK_SIZE=512

# Fetch and parse partition info
P1_INFO=($`fdisk -l $LOOP_BASE | grep ${LOOP_BASE}p1`)
P2_INFO=($`fdisk -l $LOOP_BASE | grep ${LOOP_BASE}p2`)

# Locate partition 2 start address

P2_START=${P2_INFO[1]}

echo "Located partition 2 at $P2_START"

# Attach second loopback device
LOOP_P2=`losetup -f --show -o $(($P2_START*$BLOCK_SIZE)) $1`

echo "Attached p2 at $LOOP_P2" && echo

parted $LOOP_BASE print

PARTITION_INFO=($`parted $LOOP_BASE print -m`)

RESIZE_END=`echo ${PARTITION_INFO[1]} | grep -oP "(?<=${LOOP_BASE}:)[0-9]+[.,]+[0-9]+[A-Z]+"`
RESIZE_START=`echo ${PARTITION_INFO[5]} | grep -oP "(?<=2:)[0-9]+[A-Z]+"`

echo "Making new partition from ${RESIZE_START} to ${RESIZE_END}"

# Repartition
parted $LOOP_BASE --script rm 2
parted $LOOP_BASE --script mkpart primary ext4 ${RESIZE_START} ${RESIZE_END}

e2fsck -p -f $LOOP_P2
resize2fs $LOOP_P2

# Cleanup loopbacks
losetup -d $LOOP_BASE $LOOP_P2
