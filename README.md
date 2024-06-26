# custom-rpi-img

## Requirements
This will only work on **linux** machines. It will not work on macOS because there's no viable way to mount ext3/4 partitions.

## Usage

### Building
To build, simply run `./startCustomization.sh` for the latest commits of chiptool, ot-br-posix and zap or following below syntax:

	startCustomization -h                                                            # for help
	startCustomization -ct <commit_hash>"                                            # commits of ot-br-posix and zap are the latest
	startCustomization -otbr <commit_hash>"                                          # commits of chip-tool and zap are the latest
	startCustomization -z <commit_hash>"                                             # commits of chip-tool and ot-br-posix are the latest
	startCustomization -ct <commit_hash> -otbr <commit_hash> -zap <commit_hash>"     # Specific commits for ot-br-posix, chip-tool and zap are provided

This script will do the following:

- Download the base raspios image if not already downloaded
- Mount preinstalled ubuntu for raspi
- Execute custom scripts/commands
- Unmount the preinstalled ubuntu for raspi
- Package a new ubuntu image file and z it

The final `.zip` file will be in `build/`

### Running scripts/commands inside the custom ubuntu image
Place any scripts you want to run inside of `src`. When a new script is added, make sure it to `build.sh` under the section that looks like this:

```
        # Use chroot to run any commands
        # Ex:
        #     sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash whoami
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/00-test.sh
        sudo chroot "${IMAGE_MOUNT_POINT}" /bin/bash /repo/src/01-my-new-script.sh
```
