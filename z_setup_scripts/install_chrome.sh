#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_chrome() {
  if google-chrome-stable --version >/dev/null 2>&1; then
    print_info "Google Chrome is already installed ..."
  else
    print_info "Installing Google Chrome ..."

    cd ~/Downloads || handle_error "Failed to change directory to ~/Downloads"

    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb ||
      handle_error "Failed to download Google Chrome package"

    sudo dpkg -i google-chrome-stable_current_amd64.deb >/dev/null 2>&1 ||
      (sudo apt-get install -f -y -qq && sudo dpkg -i google-chrome-stable_current_amd64.deb >/dev/null 2>&1) ||
      sudo dpkg -i --force-all google-chrome-stable_current_amd64.deb ||
      handle_error "Failed to install Google Chrome"

    sudo rm -f google-chrome-stable_current_amd64.deb || handle_error "Failed to remove the Chrome .deb package"

    cd "$DOTDIR" || handle_error "Failed to return to $DOTDIR"

    print_success "Google Chrome installed successfully."
  fi
}

install_chrome
