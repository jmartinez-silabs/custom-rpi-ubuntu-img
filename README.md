# custom-rpi-img

## Usage

### Setup
A bootstrap script has been provided. The only setup you will need to do is to initialize git submodules and run the script

```shell
git submodule update --init --recursive .
./script/bootstrap
```

### Building
To build, simply run `./build.sh`. This script will do the following:

- Download the base raspios image if not already downloaded
- Mount raspios
- Execute custom scripts/commands
- Unmount raspios
- Package a new raspios image file and zip it

The final `.zip` file will be in `build/`

### Running scripts/commands inside the custom raspios image
Place any scripts you want to run inside of `src`. When a new script is added, make sure it to `build.sh` under the section that looks like this:

```
        # Use chroot to run any commands
        # Ex:
        #     sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash whoami
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/00-test.sh
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/01-my-new-script.sh
```
