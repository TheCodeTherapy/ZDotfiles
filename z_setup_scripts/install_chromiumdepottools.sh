#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_chrome() {
  if gclient --version >/dev/null 2>&1; then
    print_info "Chromium Depot Tools is already installed ..."
  else
    print_info "Installing Chromium Depot Tools ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git ||
      handle_error "Failed to clone Chromium Depot Tools"

    PATH="$PATH:$DOTDIR/depot_tools" || handle_error "Failed to add depot_tools to PATH"
    export PATH || handle_error "Failed to export PATH"

    print_success "Chromium Depot Tools installed successfully."
  fi
}

install_chrome
