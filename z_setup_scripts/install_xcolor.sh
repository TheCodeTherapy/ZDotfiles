#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_xcolor() {
  if [[ -f $HOME/.cargo/bin/xcolor ]]; then
    print_info "XColor is already installed ..."
  else
    print_info "Installing XColor ..."

    # shellcheck source=/dev/null
    source "$HOME"/.cargo/env || handle_error "Failed to source Cargo environment"

    # Install xcolor quietly using Cargo
    cargo install xcolor >/dev/null 2>&1 || handle_error "Failed to install XColor"

    # Verify XColor installation
    if [[ -f $HOME/.cargo/bin/xcolor ]]; then
      print_success "XColor installed successfully."
    else
      handle_error "Failed to verify XColor installation."
    fi
  fi
}

install_xcolor
