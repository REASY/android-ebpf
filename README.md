eBPF for Android x86-64
-----

## Building the builder image
To make the development environment reproducible there is [docker/android_builder.dockerfile](docker/android_builder.dockerfile) that has everything you need to build [BlissOS 15.x](https://docs.blissos.org/development/build-bliss-os-15.x/). 
```console
sudo docker build -f docker/android_builder.dockerfile  -t android_builder:0.1 docker
```

## Initializing BlissOS repo
All the commands are run inside docker container that was run with the command below. The folder `/media/android_dev_disk/arcadia-x86` is an empty one that will be initialized inside container.
```console
sudo docker run -v /media/android_dev_disk/arcadia-x86:/aosp -w /aosp -i -t android_builder:0.1
```

### Repo initialization
```console
aosp@29b675cef2f2:/aosp$ repo init -u https://github.com/BlissRoms-x86/manifest.git -b arcadia-x86 --git-lfs
```
### Sync repo
```
aosp@29b675cef2f2:/aosp$ repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune
Fetching: 100% (1196/1196), done in 5.763s
Checking out:  98% (1176/1196), done in 2.610s
Checking out:   1% (20/1196), done in 0.021s
repo sync has finished successfully.
```
### Initialize Intel libhoudini
[libhoudini](https://commonsware.com/blog/2013/11/21/libhoudini-what-it-means-for-developers.html) is a proprietary ARM translation layer for x86-powered Android devices. It allows an app that has NDK binaries for ARM, but not x86, to still run on x86 hardware, albeit not as quickly as it would with native x86 binaries.
```
aosp@29b675cef2f2:/aosp$ git clone --single-branch --branch wsa-12.1 shttps://github.com/supremegamers/vendor_intel_proprietary_houdini vendor/intel/proprietary/houdini
Cloning into 'vendor/intel/proprietary/houdini'...
remote: Enumerating objects: 1636, done.
remote: Counting objects: 100% (274/274), done.
remote: Compressing objects: 100% (160/160), done.
remote: Total 1636 (delta 144), reused 114 (delta 114), pack-reused 1362 (from 1)
Receiving objects: 100% (1636/1636), 149.00 MiB | 13.47 MiB/s, done.
Resolving deltas: 100% (702/702), done.
aosp@29b675cef2f2:/aosp$ 
```
### Setup FOSS apps for x86/x86_64
```console
aosp@fda9edb5454c:/aosp$ cd vendor/foss
aosp@fda9edb5454c:/aosp/vendor/foss$ ./update.sh
(default is 'ABI:x86_64 & ABI2:x86')
Timeout in 10 sec.
1) ABI:x86_64 & ABI2:x86
2) ABI:arm64-v8a & ABI2:armeabi-v7a
3) ABI:x86
Which device type do you plan on building?: 1
you chose choice 1 which is ABI:x86_64 & ABI2:x86
```

## Build BlissOS 15.x
### Apply patches to enable eBFP
```
aosp@fda9edb5454c:/aosp$ /patches/apply.sh
Patching /aosp/device/generic/common ...
Done
Patching /aosp/kernel/x86/common ...
Done
```

### Build it
```bash
export BLISS_BUILD_VARIANT=foss
export ANDROID_USE_INTEL_HOUDINI=true
source build/envsetup.sh
lunch bliss_x86_64-userdebug
make blissify iso_img -j$(nproc --all)
```
