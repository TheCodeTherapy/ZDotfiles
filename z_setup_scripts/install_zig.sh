#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_zig() {
  if zig --version >/dev/null 2>&1; then
    print_info "Zig is already installed ..."
  else
    print_info "Installing Zig ..."

    cd $DOTDIR || handle_error "Failed to change directory to $DOTDIR"
    mkdir -p build || handle_error "Failed to create build directory"
    cd build || handle_error "Failed to change directory to build"

    zig_version="zig-linux-x86_64-0.14.0"
    zig_14_tarball="$zig_version.tar.xz"
    zig_14_url="https://ziglang.org/download/0.14.0/$zig_14_tarball"

    print_info "Downloading Zig package ..."
    curl -L "$zig_14_url" -o $zig_14_tarball ||
      handle_error "Failed to download Zig package"

    print_info "Extracting Zig package ..."
    tar -xf $zig_14_tarball ||
      handle_error "Failed to extract Zig package"
    
    rm $zig_14_tarball ||
      handle_error "Failed to remove Zig tarball"
    
    cd $zig_version || handle_error "Failed to change directory to $zig_version"
    mkdir -p ~/.zig || handle_error "Failed to create Zig directory"
    mv * ~/.zig || handle_error "Failed to move Zig files to ~/.zig"
    cd .. || handle_error "Failed to change directory to parent"
    rm -rf $zig_version || handle_error "Failed to remove Zig version directory"

    print_success "Zig installed successfully."
  fi
}

install_zig
