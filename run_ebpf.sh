#!/bin/bash
qemu-system-x86_64 \
    -enable-kvm \
    -M q35 \
    -m 8192 -smp 8 -cpu host \
    -bios /usr/share/ovmf/OVMF.fd \
    -drive file=/media/android_dev_disk/android-ebpf/disk/disk.qcow2,if=virtio \
    -usb \
    -device virtio-tablet \
    -device virtio-keyboard \
    -device qemu-xhci,id=xhci \
    -device vhost-vsock-pci,id=vhost-vsock-pci0,guest-cid=3 \
    -machine vmport=off \
    -device virtio-vga-gl -display sdl,gl=on \
    -audiodev pa,id=snd0 -device AC97,audiodev=snd0 \
    -net nic,model=virtio-net-pci -net user,hostfwd=tcp::4444-:5555