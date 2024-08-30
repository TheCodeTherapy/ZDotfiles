#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_vscode() {
  if code --version >/dev/null 2>&1; then
    print_info "VSCode is already installed ..."
  elif locate code | grep '/usr/bin/code' | grep -v 'codepage' >/dev/null 2>&1; then
    print_info "VSCode is already installed ..."
  else
    print_info "Installing VSCode ..."

    sudo apt-get install -y -qq software-properties-common apt-transport-https wget ||
      handle_error "Failed to install dependencies for VSCode"

    wget -qO- https://packages.microsoft.com/keys/microsoft.asc |
      gpg --dearmor >packages.microsoft.gpg ||
      handle_error "Failed to download Microsoft GPG key"

    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg ||
      handle_error "Failed to install Microsoft GPG key"

    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |
      sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null ||
      handle_error "Failed to add VSCode repository"

    sudo apt-get update -qq || handle_error "Failed to update package list"

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq code ||
      handle_error "Failed to install VSCode package"

    print_success "VSCode installed successfully."
  fi
}

install_vscode
