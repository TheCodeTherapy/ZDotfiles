#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

# https://github.com/geoffreybennett/linux-fcp/releases/tag/v6.12-f8

install_scarlett-fcp() {
  if [ -d "/lib/modules/$(uname -r)/updates/snd-usb-audio" ]; then
    print_info "Scarlett FCP Kernel Module already installed ..."
  else
    print_info "Installing Scarlett FCP Kernel Module ..."

    cd $DOTDIR || handle_error "Failed to change directory to $DOTDIR"

    cd drivers/scarlett18i20/fcp || handle_error "Failed to change directory to drivers/scarlett18i20/fcp"

    tar -xf snd-usb-audio-kmod-v6.11.11-f8.tar.xz || handle_error "Failed to extract snd-usb-audio-kmod-v6.11.11-f8.tar.xz"

    cd snd-usb-audio-kmod-v6.11.11-f8 || handle_error "Failed to change directory to snd-usb-audio-kmod-v6.11.11-f8"

    KSRCDIR=/lib/modules/$(uname -r)/build

    make -j4 -C $KSRCDIR M=$(pwd) clean || handle_error "Failed to clean kernel module"

    make -j4 -C $KSRCDIR M=$(pwd) || handle_error "Failed to build kernel module"

    sudo make -j4 -C $KSRCDIR M=$(pwd) INSTALL_MOD_DIR=updates/snd-usb-audio modules_install ||
      handle_error "Failed to install kernel module"

    sudo depmod || handle_error "Failed to run depmod"

    print_success "Scarlett FCP Kernel Module installed successfully."
  fi
}

install_scarlett-fcp
