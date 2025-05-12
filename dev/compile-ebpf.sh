#!/bin/bash
set -euo pipefail

mkdir ~/code && cd ~/code

echo "Cloning and building bcc"
git clone --depth 1 --recurse-submodules https://github.com/iovisor/bcc.git --branch v0.34.0 --single-branch && cd bcc
mkdir build && cd build &&
 cmake -DLLVM_CONFIG=/usr/lib/llvm-18/bin/llvm-config \
     -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm/ \
     -DCMAKE_CXX_COMPILER=/usr/bin/clang++-18 \
     -DCMAKE_C_COMPILER=/usr/bin/clang-18 \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_FLAGS="-I/usr/lib/llvm-18/include -std=c++17 -funwind-tables -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"  \
     -DCMAKE_C_FLAGS="$(llvm-config-18 --cppflags)" \
     -DSYSTEM_INCLUDE_PATHS=none \
     -DPYTHON_CMD=python3 .. &&
   make -j$(nproc) && make install &&
   pushd src/python/ && make -j$(nproc) && make install && popd

# Make Python3 as /usr/bin/python
ln -s $(which python3) /usr/bin/python

cd ~/code

echo "Cloning and building bpftool"
git clone --depth 1 --recurse-submodules https://github.com/libbpf/bpftool.git --branch v7.5.0 --single-branch && cd bpftool
cd src && make -j$(nproc) install


cd ~/code

#
echo "Cloning and building libbpf"
git clone --depth 1 https://github.com/libbpf/libbpf.git --branch v1.5.0 --single-branch && cd libbpf
cd src && make -j$(nproc) && make install && make install_uapi_headers
ln -s /usr/lib64/libbpf.so.1.5.0 /usr/lib/aarch64-linux-gnu/libbpf.so.1


cd ~/code
echo "Cloning and building bpftrace"
git clone --depth 1 https://github.com/bpftrace/bpftrace.git --branch v0.23.2 --single-branch && cd bpftrace
mkdir build && cd build &&
 cmake -DLLVM_CONFIG=/usr/lib/llvm-18/bin/llvm-config \
     -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm/ \
     -DCMAKE_CXX_COMPILER=/usr/bin/clang++-18 \
     -DCMAKE_C_COMPILER=/usr/bin/clang-18 \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_FLAGS="-I/usr/lib/llvm-18/include -std=c++17 -funwind-tables -D_GNU_SOURCE -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS"  \
     -DCMAKE_C_FLAGS="$(llvm-config-18 --cppflags)" \
     -DSYSTEM_INCLUDE_PATHS=none .. &&
  make -j$(nproc) && make install

# Check the binary can be executed
bpftool --version
bpftrace --version
