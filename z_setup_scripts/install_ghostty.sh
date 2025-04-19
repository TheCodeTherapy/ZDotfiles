#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_ghostty() {
  if ghostty --version >/dev/null 2>&1; then
    print_info "Ghostty is already installed ..."
  else
    print_info "Installing Ghostty ..."

    cd $DOTDIR || handle_error "Failed to change directory to $DOTDIR"
    mkdir -p build || handle_error "Failed to create build directory"
    cd build || handle_error "Failed to change directory to build"

    if [ -d "ghostty" ]; then
      rm -rf ghostty || handle_error "Failed to remove existing Ghostty directory"
    fi

    print_info "Cloning Ghostty repository ..."
    git clone https://github.com/ghostty-org/ghostty ||
      handle_error "Failed to clone Ghostty repository"
    cd ghostty || handle_error "Failed to change directory to ghostty"

    git checkout v1.1.3 ||
      handle_error "Failed to checkout v1.1.3 branch"

    zig build -p $HOME/.local -Doptimize=ReleaseFast ||
      handle_error "Failed to build Ghostty"

    print_success "Ghostty installed successfully."
  fi
}

install_ghostty
