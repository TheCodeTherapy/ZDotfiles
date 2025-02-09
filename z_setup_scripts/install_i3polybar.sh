#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_i3polybar() {
  if polybar --version >/dev/null 2>&1; then
    print_info "polybar already installed ..."
  else
    print_info "Installing polybar ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    git clone --recursive https://github.com/polybar/polybar build/polybar || handle_error "Failed to clone repository"

    cd build/polybar || handle_error "Failed to enter polybar directory"

    mkdir -p build || handle_error "Failed to create build directory"

    cd build || handle_error "Failed to enter build directory"

    cmake .. || handle_error "Failed to configure build"

    make -j"$(nproc)" || handle_error "Failed to build polybar"

    sudo make install || handle_error "Failed to install polybar"

    cd "$DOTDIR" || handle_error "Failed to return to $DOTDIR"

    print_success "polybar installed successfully."
  fi
}

install_i3polybar
