#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_flatpak() {
  if flatpak --version >/dev/null 2>&1; then
    print_info "Flatpak is already installed ..."
  else
    print_info "Installing Flatpak ..."

    sudo apt-get update -qq || handle_error "Failed to update package list"

    sudo apt-get install -y -qq flatpak || handle_error "Failed to install flatpak"

    sudo apt-get install -y -qq gnome-software-plugin-flatpak ||
      handle_error "Failed to install gnome-software-plugin-flatpak"

    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo ||
      handle_error "Failed to add flathub remote"

    print_success "Flatpak installed successfully."
  fi
}

install_flatpak
