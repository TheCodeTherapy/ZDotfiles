#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_alacritty() {
  if command -v alacritty >/dev/null 2>&1; then
    print_info "Alacritty is already installed ..."
  else
    print_info "Building and installing Alacritty ..."

    # shellcheck source=/dev/null
    source "$HOME/.cargo/env" || handle_error "Failed to source Cargo environment"

    # Install alacritty quietly using Cargo
    cargo install alacritty >/dev/null 2>&1 || handle_error "Failed to install Alacritty"

    # Verify Alacritty installation
    if command -v alacritty >/dev/null 2>&1; then
      print_success "Alacritty installed successfully."
    else
      handle_error "Failed to verify Alacritty installation."
    fi
  fi
}

install_alacritty
