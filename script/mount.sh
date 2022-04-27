#!/bin/bash

# The MIT License (MIT) Copyright (c) 2016 Ryan Kurte
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#
# Script to mount a provided raspbian image to a provided location
#

set -euxo pipefail

main()
{
    # Check inputs
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 IMAGE MOUNT"
        echo "IMAGE - raspberry pi .img file"
        echo "MOUNT - mount location in the file system"
        exit
    fi

    IMAGE_FILE=$1
    MOUNT_POINT=$2

    if [ ! -f "${IMAGE_FILE}" ]; then
        echo "Image file ${IMAGE_FILE} does not exist"
        exit 1
    fi

    if [ ! -d "${MOUNT_POINT}" ]; then
        echo "Mount point ${MOUNT_POINT} does not exist"
        exit 2
    fi

    echo "Attaching image"
    set -e

    # Attach loopback device
    LOOP_BASE=$(sudo losetup -f -P --show ${IMAGE_FILE})

    echo "Attached image at: $LOOP_BASE"

    P1_NAME=${LOOP_BASE}p1
    P2_NAME=${LOOP_BASE}p2

    # Mount image with the offsets determined above
    echo "Attempting to mount ${IMAGE_FILE} to ${MOUNT_POINT}"
    mkdir -p "${MOUNT_POINT}"
    sudo mount "$P2_NAME" -o rw "${MOUNT_POINT}"
    sudo mount "$P1_NAME" -o rw "${MOUNT_POINT}"/boot
    echo "Mounted to ${MOUNT_POINT} and ${MOUNT_POINT}/boot"
}

main "$@"
