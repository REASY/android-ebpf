#!/bin/bash
set -euo pipefail

TARGET_PATH="$1"

# Clean-up
rm -rf "${TARGET_PATH}/lib/udev/"
rm -rf "${TARGET_PATH}/var/lib/apt/lists/"
rm -rf "${TARGET_PATH}/var/cache/apt/archives/"
rm -rf "${TARGET_PATH}/usr/share/locale/"
rm -rf "${TARGET_PATH}/usr/lib/share/locale/"
rm -rf "${TARGET_PATH}/usr/share/doc/"
rm -rf "${TARGET_PATH}/usr/lib/share/doc/"
rm -rf "${TARGET_PATH}/usr/share/ieee-data/"
rm -rf "${TARGET_PATH}/usr/lib/share/ieee-data/"
rm -rf "${TARGET_PATH}/usr/share/man/"


# Fix DNS
echo "nameserver 8.8.8.8" > "${TARGET_PATH}/etc/resolv.conf"