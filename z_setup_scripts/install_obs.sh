#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_obs_studio() {
  if obs --version >/dev/null 2>&1; then
    print_info "OBS Studio is already installed ..."
  else
    print_info "Installing OBS Studio ..."

    if ! ls /etc/apt/sources.list.d/obs* >/dev/null 2>&1; then
      print_info "Adding OBS Studio PPA ..."
      sudo add-apt-repository -y ppa:obsproject/obs-studio >/dev/null 2>&1 ||
        handle_error "Failed to add OBS Studio PPA"

      sudo apt-get update -qq || handle_error "Failed to update package list"
    else
      print_info "OBS Studio PPA already configured."
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq obs-studio ||
      handle_error "Failed to install OBS Studio package"

    print_success "OBS Studio installed successfully."
  fi
}

install_obs_studio
