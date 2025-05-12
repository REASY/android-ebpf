#!/bin/bash
set -euo pipefail

# Add LLVM repository configuration
setup_llvm_repo() {
    # Install required dependencies for this script
    apt-get update
    apt-get install -y --no-install-recommends curl gnupg

    # Add LLVM repository signing key
    curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | \
        gpg --dearmor -o /etc/apt/trusted.gpg.d/llvm.gpg

    # Add repository to sources.list.d
    echo "deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-18 main" \
        > /etc/apt/sources.list.d/llvm.list
}

# Install LLVM packages (accepts package arguments)
install_llvm_packages() {
    apt-get update
    apt-get install -y --no-install-recommends clang-18 \
                                               llvm-18 \
                                               llvm-18-dev \
                                               lld-18 \
                                               libllvm18 \
                                               clang-tidy-18 \
                                               libclang-18-dev \
                                               libpolly-18-dev
}

# Main execution
main() {
    [ $(id -u) -eq 0 ] || { echo "Must be run as root"; exit 1; }

    setup_llvm_repo
    install_llvm_packages
}

main "$@"