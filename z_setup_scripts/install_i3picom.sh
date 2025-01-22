#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_i3picom() {
  if picom --version >/dev/null 2>&1; then
    print_info "picom already installed ..."
  else
    print_info "Installing picom ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    git clone https://github.com/yshui/picom.git build/picom || handle_error "Failed to clone repository"

    cd build/picom || handle_error "Failed to enter picom directory"

    meson setup --buildtype=release build || handle_error "Failed to configure build"

    ninja -C build || handle_error "Failed to build picom"

    sudo ninja -C build install || handle_error "Failed to install picom"

    cd "$DOTDIR" || handle_error "Failed to return to $DOTDIR"

    print_success "picom installed successfully."
  fi
}

install_i3picom
