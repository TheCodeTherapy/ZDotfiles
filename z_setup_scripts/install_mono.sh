#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_mono() {
  if mono-csc --version >/dev/null 2>&1; then
    print_info "Mono is already installed ..."
  else
    print_info "Installing Mono ..."

    sudo apt-get install -y -qq ca-certificates gnupg ||
      handle_error "Failed to install ca-certificates and gnupg"

    sudo gpg --homedir /tmp --no-default-keyring \
      --keyring /usr/share/keyrings/mono-official-archive-keyring.gpg \
      --keyserver hkp://keyserver.ubuntu.com:80 \
      --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF ||
      handle_error "Failed to download Mono repository key"

    echo "deb [signed-by=/usr/share/keyrings/mono-official-archive-keyring.gpg] https://download.mono-project.com/repo/ubuntu stable-focal main" |
      sudo tee /etc/apt/sources.list.d/mono-official-stable.list ||
      handle_error "Failed to add Mono repository"

    sudo apt-get update -qq || handle_error "Failed to update package list"

    sudo apt-get install -y -qq mono-complete || handle_error "Failed to install Mono"

    print_success "Mono installed successfully."
  fi
}

install_mono
