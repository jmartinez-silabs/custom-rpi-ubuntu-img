# custom-rpi-img

## Usage

Place any scripts you want to run inside of `src`. When a new script is added, make sure it to `build.sh` under the section that looks like this:

```
        # Use chroot to run any commands
        # Ex:
        #     sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash whoami
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/00-test.sh
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/01-my-new-script.sh
```