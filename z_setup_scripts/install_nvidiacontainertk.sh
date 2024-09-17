#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_nvidiacontainertk() {
  if dpkg -l | grep -q nvidia-container-toolkit; then
    print_info "NVIDIA Container Toolkit is already installed ..."
  else
    print_info "Installing NVIDIA Container Toolkit ..."

    if ! ls /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null 2>&1; then
      print_info "Adding NVIDIA Container Toolkit repository ..."

      curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
        sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg &&
        curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
          sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

      sudo apt-get update -qq || handle_error "Failed to update package list"
    else
      print_info "NVIDIA Container Toolkit repository already configured."
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nvidia-container-toolkit ||
      handle_error "Failed to install NVIDIA Container Toolkit package"

    print_success "NVIDIA Container Toolkit installed successfully."
  fi

  print_info "Restarting Docker to apply changes ..."
  sudo systemctl restart docker || handle_error "Failed to restart Docker"

  print_success "Docker restarted successfully, NVIDIA Container Toolkit is ready."
}

install_nvidiacontainertk
