#!/bin/bash

set -euxo pipefail

# ==============================================================================
# Variables
# ==============================================================================
if [[ -n ${BASH_SOURCE[0]} ]]; then
    script_path="${BASH_SOURCE[0]}"
else
    script_path="$0"
fi

# Path to dir containing this script
script_dir="$(dirname "$(realpath "$script_path")")"

# Path to repo
repo_dir="$script_dir"

# This is where the image will be created
OUTPUT_ROOT=${OUTPUT_ROOT:-${repo_dir}/build}
echo "OUTPUT_ROOT=${OUTPUT_ROOT}"
mkdir -p ${OUTPUT_ROOT}

# Output raspios image and zip name
CUSTOM_IMG_FILE="raspios_lite_custom_$(date +%Y%m%d).img"
IMG_ZIP_FILE="$CUSTOM_IMG_FILE.zip"

# Staging directory where images are copied to for temporary storage
STAGE_DIR=/tmp/raspbian

# Where the raspios image will be mounted
IMAGE_MOUNT_POINT=${OUTPUT_ROOT}/mnt-rpi

# URL for a raspios image
BASE_IMAGE_URL=${BASE_IMAGE_URL:-"https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"}

# Where to download the raspios image
TOOLS_HOME=$HOME/.cache/tools

# ==============================================================================
cleanup() {
    set +e

    # Unmount and detach any loop devices
    loop_names=$(losetup -j $STAGE_DIR/raspios_base.img --output NAME -n)
    for loop in ${loop_names}; do
        sudo umount -lf "${loop}p1"
        sudo umount -lf "${loop}p2"
        sudo losetup -d "${loop}"
    done

    set -e
}

trap cleanup EXIT

main() {

    # Download base image
    BASE_IMAGE_NAME=$(basename "${BASE_IMAGE_URL}" .zip)
    IMAGE_FILE="$BASE_IMAGE_NAME".img
    [ -f "$TOOLS_HOME"/images/"$IMAGE_FILE" ] || {

        # Download image if it doesn't already exist
        [ -d "$TOOLS_HOME"/images ] || mkdir -p "$TOOLS_HOME"/images
        [[ -f "$BASE_IMAGE_NAME".zip ]] || curl -kLO "$BASE_IMAGE_URL"

        # Extract
        unzip "$BASE_IMAGE_NAME".zip -d /tmp

        # Expand OS partition to 4GB
        EXPAND_SIZE=4096
        (cd /tmp &&
            dd if=/dev/zero bs=1048576 count="$EXPAND_SIZE" >> "$IMAGE_FILE" &&
            mv "$IMAGE_FILE" "$TOOLS_HOME"/images/"$IMAGE_FILE")

        (cd docker-rpi-emu/scripts &&
            sudo ./expand.sh "$TOOLS_HOME"/images/"$IMAGE_FILE" "$EXPAND_SIZE")
    }

    IMAGE_FILE="$TOOLS_HOME"/images/"$BASE_IMAGE_NAME".img

    # Create a staging dir and make a copy of the raspios base image
    [ -d "$STAGE_DIR" ] || mkdir -p "$STAGE_DIR"
    cp -v "$IMAGE_FILE" "$STAGE_DIR"/raspios_base.img

    # Mount the base image
    mkdir -p "$IMAGE_MOUNT_POINT"
    chown -R $(whoami): "$IMAGE_MOUNT_POINT"
    ls -alh "$IMAGE_MOUNT_POINT"
    script/mount.sh "$STAGE_DIR"/raspios_base.img "$IMAGE_MOUNT_POINT"

    (
        # Setup QEMU
        cd docker-rpi-emu/scripts
        sudo mount --bind /dev/pts "$IMAGE_MOUNT_POINT"/dev/pts
        sudo ./qemu-setup.sh "$IMAGE_MOUNT_POINT"

        # Mount this repo in $IMAGE_MOUNT_POINT
        sudo mkdir "$IMAGE_MOUNT_POINT"/repo
        sudo mount --bind ${repo_dir} "$IMAGE_MOUNT_POINT"/repo

        # Use chroot to run any commands
        # Ex:
        #     sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash whoami
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/00-test.sh


        # Tear down QEMU and create new .img file
        sync && sleep 1
        sudo ./qemu-cleanup.sh "$IMAGE_MOUNT_POINT"
        LOOP_NAME=$(losetup -j $STAGE_DIR/raspios_base.img --output NAME -n)
        sudo sh -c "dcfldd of=$STAGE_DIR/$CUSTOM_IMG_FILE if=$LOOP_NAME bs=1m && sync"

        # Attempt to shrink image
        sudo cp "$STAGE_DIR/$CUSTOM_IMG_FILE" "$STAGE_DIR/${CUSTOM_IMG_FILE}_backup.img"
        if [[ ! -f /usr/bin/pishrink.sh ]]; then
            sudo wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh -O /usr/bin/pishrink.sh && sudo chmod a+x /usr/bin/pishrink.sh
        fi
        set +e
        sudo /usr/bin/pishrink.sh $STAGE_DIR/$CUSTOM_IMG_FILE
        retVal=$?

        # Ignore error when pishrink can't shrink the image any further
        if [[ $retVal -ne 11 ]] && [[ $retVal -ne 0 ]]; then
            exit $retval
        fi
        set -e

        # (Optional) Write image to SD card
        if [[ -n ${SD_CARD:=} ]]; then
            sudo sh -c "dcfldd if=$STAGE_DIR/$CUSTOM_IMG_FILE of=$SD_CARD bs=1m && sync"
        fi

        # Zip image file
        (cd $STAGE_DIR && zip "$IMG_ZIP_FILE" $CUSTOM_IMG_FILE && mv "$IMG_ZIP_FILE" "$OUTPUT_ROOT")
    )
}

main "$@"