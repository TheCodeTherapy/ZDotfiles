#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_docker() {
  if docker --version >/dev/null 2>&1; then
    print_info "Docker is already installed ..."
  else
    print_info "Installing Docker ..."

    sudo apt-get update -qq || handle_error "Failed to update package list."
    sudo apt-get full-upgrade -y -qq || handle_error "Failed to update and upgrade the system."
    sudo apt-get install -y -qq ca-certificates curl || handle_error "Failed to install required packages."

    # Create directory for Docker's GPG key
    sudo install -m 0755 -d /etc/apt/keyrings || handle_error "Failed to create directory for Docker's GPG key."

    # Download Docker's official GPG key
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
      -o /etc/apt/keyrings/docker.asc ||
      handle_error "Failed to download Docker's GPG key."

    # Adjust permissions for Docker's GPG key
    sudo chmod a+r /etc/apt/keyrings/docker.asc ||
      handle_error "Failed to set permissions for Docker's GPG key."

    # Add Docker repository to Apt sources
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null ||
      handle_error "Failed to add Docker repository."

    # Update package index to include Docker repository
    sudo apt-get update -qq || handle_error "Failed to update package list with Docker repository."

    # Install Docker packages
    sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ||
      handle_error "Failed to install Docker packages."

    # Add the current user to the Docker group
    sudo usermod -aG docker "$USER" || handle_error "Failed to add user to Docker group."

    print_success "Docker installed successfully."
  fi
}

install_docker
