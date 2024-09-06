#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_brave() {
  if brave-browser --version >/dev/null 2>&1; then
    print_info "Brave Browser is already installed ..."
  else
    print_info "Installing Brave Browser ..."

    sudo apt-get install -y -qq curl || handle_error "Failed to install curl"

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg ||
      handle_error "Failed to download Brave Browser repository key"

    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" |
      sudo tee /etc/apt/sources.list.d/brave-browser-release.list >/dev/null ||
      handle_error "Failed to add Brave Browser repository"

    sudo apt-get update -qq || handle_error "Failed to update package list"

    sudo apt-get install -y -qq brave-browser || handle_error "Failed to install Brave Browser"

    print_success "Brave Browser installed successfully."
  fi
}

install_brave
