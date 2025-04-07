#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

# https://github.com/geoffreybennett/linux-fcp/releases/tag/v6.12-f8

install_scarlett-fcp-support() {
  if [ -f "/usr/local/bin/fcp-server" ]; then
    print_info "Scarlett FCP Support Server already installed ..."
  else
    print_info "Installing Scarlett FCP Support Server ..."

    cd $DOTDIR || handle_error "Failed to change directory to $DOTDIR"

    cd drivers/scarlett18i20/fcp || handle_error "Failed to change directory to drivers/scarlett18i20/fcp"

    git clone https://github.com/TheCodeTherapy/fcp-support.git || handle_error "Failed to clone fcp-support repository"

    cd fcp-support || handle_error "Failed to change directory to fcp-support"

    sudo usermod -a -G audio $USER || handle_error "Failed to add user to audio group"

    make -j4 || handle_error "Failed to build fcp-support"

    sudo make install || handle_error "Failed to install fcp-support"

    print_success "Scarlett FCP Support Server installed successfully."
  fi
}

install_scarlett-fcp-support
