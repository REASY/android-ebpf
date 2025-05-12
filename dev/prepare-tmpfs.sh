#!/bin/bash
set -euo pipefail

# Create mount point
sudo mkdir -p /mnt/build-tmpfs

# Mount tmpfs with device support (remove nodev)
sudo mount -t tmpfs -o size=4G,mode=0755,uid=$(id -u),gid=$(id -g) tmpfs /mnt/build-tmpfs