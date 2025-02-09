#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_i3() {
  if i3 --version >/dev/null 2>&1; then
    print_info "i3 already installed ..."
  else
    print_info "Installing i3 ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    git clone https://github.com/i3/i3 build/i3 || handle_error "Failed to clone repository"

    cd build/i3 || handle_error "Failed to enter i3 directory"

    mkdir -p build || handle_error "Failed to create build directory"

    cd build || handle_error "Failed to enter build directory"

    meson -Ddocs=true -Dmans=true .. || handle_error "Failed to configure build"

    ninja || handle_error "Failed to build i3"

    sudo ninja install || handle_error "Failed to install i3"

    cd "$DOTDIR" || handle_error "Failed to return to $DOTDIR"

    print_success "i3 installed successfully."
  fi
}

install_i3
