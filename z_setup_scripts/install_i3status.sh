#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_i3status() {
  if i3status --version >/dev/null 2>&1; then
    print_info "i3status already installed ..."
  else
    print_info "Installing i3status ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    git clone https://github.com/i3/i3status build/i3status || handle_error "Failed to clone repository"

    cd build/i3status || handle_error "Failed to enter i3status directory"

    mkdir -p build || handle_error "Failed to create build directory"

    cd build || handle_error "Failed to enter build directory"

    meson .. || handle_error "Failed to configure build"

    ninja || handle_error "Failed to build i3status"

    sudo ninja install || handle_error "Failed to install i3status"

    cd "$DOTDIR" || handle_error "Failed to return to $DOTDIR"

    print_success "i3status installed successfully."
  fi
}

install_i3status
