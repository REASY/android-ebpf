#!/bin/bash
set -euo pipefail

# Default values
DEFAULT_TARGET_PATH="$HOME/debian"
ARCH="amd64"
MIRROR="http://localhost:3142/ftp.debian.org/debian/"
RELEASE="bullseye"
VARIANT="minbase"

# Packages to install (keep alphabetized for maintainability)
PACKAGES=(
    apt
    bash
    binutils-dev
    bison
    build-essential
    ca-certificates
    cmake
    curl
    dwarves
    flex
    git
    gpg
    iputils-ping
    less
    libc++-dev
    libc++abi-dev
    libcereal-dev
    libcurl4-openssl-dev
    libdebuginfod-dev
    libedit-dev
    libelf-dev
    libelf1
    libfl-dev
    libgmock-dev
    libgtest-dev
    liblzma-dev
    libpcap-dev
    libzstd-dev
    lldb
    luajit
    libluajit-5.1-dev
    net-tools
    pkg-config
    procps
    python3
    python3-netaddr
    python3-setuptools
    strace
    sudo
    vim
    zip
    zlib1g-dev
)

show_usage() {
    echo "Usage: $0 [OPTIONS] [TARGET_PATH]"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -a, --arch      Set architecture (default: $ARCH)"
    echo "  -m, --mirror    Set mirror URL (default: $MIRROR)"
    echo "  -r, --release   Set Debian release (default: $RELEASE)"
    echo
    echo "Examples:"
    echo "  $0 /path/to/new_root         # Custom target path"
    echo "  $0                          # Uses default path: $DEFAULT_TARGET_PATH"
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_usage
            ;;
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -m|--mirror)
            MIRROR="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option $1" >&2
            exit 1
            ;;
        *)
            TARGET_PATH="$1"
            shift
            ;;
    esac
done

# Set default target path if not specified
TARGET_PATH="${TARGET_PATH:-$DEFAULT_TARGET_PATH}"

# Validate target path
if [[ -e "$TARGET_PATH" ]]; then
    if [[ ! -d "$TARGET_PATH" ]]; then
        echo "Error: Target path exists but is not a directory: $TARGET_PATH" >&2
        exit 1
    fi
    if [[ "$(ls -A "$TARGET_PATH")" ]]; then
        echo "Warning: Target directory is not empty: $TARGET_PATH" >&2
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || exit 1
    fi
fi

# Create directory if it doesn't exist
mkdir -p "$TARGET_PATH"

echo "Building Debian $RELEASE rootfs for $ARCH"
echo "Target directory: $TARGET_PATH"
echo "Mirror: $MIRROR"
echo "Included packages: ${PACKAGES[*]}"

debootstrap \
    --arch "$ARCH" \
    --include=$(IFS=,; echo "${PACKAGES[*]}") \
    --variant="$VARIANT" \
    "$RELEASE" \
    "$TARGET_PATH" \
    "$MIRROR"
