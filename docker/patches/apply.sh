#!/usr/bin/env bash

set -ue

cwd=$(pwd)

echo "Patching /aosp/device/generic/common ..."
cd /aosp/device/generic/common && git apply '/patches/fix__Increase_BOARD_SYSTEMIMAGE_PARTITION_SIZE.patch'
echo "Done"

echo "Patching /aosp/kernel/x86/common ..."
cd /aosp/kernel/x86/common && git apply < '/patches/fix__enable_eBPF.patch' && \
  git apply < '/patches/fix__use_system_tools_instead_of_provided.patch'
echo "Done"

cd "${cwd}"

