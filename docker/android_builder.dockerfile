# Insipored from: https://android-review.googlesource.com/c/platform/build/+/1161367
FROM ubuntu:24.04

ARG userid=1000
ARG groupid=1000
ARG username=aosp
ARG http_proxy

# Using separate RUNs here allows Docker to chache each update
RUN DEBIAN_FRONTEND="noninteractive" apt-get update

# Make sure the base image is up to date
RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y

# Install apt-utils to make apt run more smoothly
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y apt-utils

# Install the packages needed for the build
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y git-core gnupg flex bison build-essential python3 python3-pip python3-setuptools python3-wheel python3-mako \
	zip curl zlib1g-dev gcc-multilib g++-multilib libc6 libc6-dev-i386 \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
	fontconfig procps rsync gperf ccache squashfs-tools libssl-dev ninja-build lunzip \
    syslinux syslinux-utils gettext genisoimage bc xorriso xmlstarlet glslang-tools git-lfs libelf-dev \
    aapt zstd rdfind nasm rsync wget pkg-config sudo kmod pahole cpio \
    lib32ncurses-dev libncurses6 p7zip-full p7zip-rar

ENV HOME_DIR="/home/$username"

RUN usermod -md "/home/$username" -l "$username" ubuntu && groupmod -n "$username" ubuntu

# Create the home directory for the build user
#RUN groupadd --force -g $groupid $username && useradd -m -s /bin/bash -u $userid -g $groupid $username &&  usermod -aG sudo $username
COPY gitconfig "$HOME_DIR/.gitconfig"
RUN chown $userid:$groupid /home/$username/.gitconfig
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Rust
ENV RUSTUP_HOME="$HOME_DIR/.rustup" \
    CARGO_HOME="$HOME_DIR/.cargo" \
    PATH="$HOME_DIR/.cargo/bin":$PATH \
    RUST_VERSION=1.85.1

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain=$RUST_VERSION -y
RUN rustup target add x86_64-linux-android i686-linux-android
RUN cargo install --version 0.69.5 bindgen-cli && cargo install cbindgen

RUN pip3 install --break-system-packages meson==1.6.1 pycparser ply PyYAML

#   As Ubuntu 24.04+ removed libncurses5, we need to symlink some libncurses6 libraries
#   to be libncurses5 in order to make the toolchain work.
#   !!!WARNING: These commands are poking into /lib, please proceed with cautions
RUN ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /lib/x86_64-linux-gnu/libncurses.so.5 && \
    ln -s /lib/x86_64-linux-gnu/libncursesw.so.6 /lib/x86_64-linux-gnu/libncursesw.so.5 && \
    ln -s /lib/x86_64-linux-gnu/libtinfo.so.6 /lib/x86_64-linux-gnu/libtinfo.so.5

# Disable some gpg options which can cause problems in IPv4 only environments
RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

# Download and verify repo
RUN gpg --recv-key 8BB9AD793E8E6153AF0F9A4416530D5E920F5C65
RUN curl -o /usr/local/bin/repo https://storage.googleapis.com/git-repo-downloads/repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo.asc | gpg --verify - /usr/local/bin/repo
RUN chmod a+x /usr/local/bin/repo

COPY patches /patches

WORKDIR /home/$username
USER $username
