#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_docker_compose() {
  if docker-compose --version >/dev/null 2>&1; then
    print_info "Docker Compose is already installed ..."
  else
    print_info "Installing Docker Compose ..."

    # Download Docker Compose quietly
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >/dev/null 2>&1 ||
      handle_error "Failed to download Docker Compose"

    # Make Docker Compose executable
    sudo chmod +x /usr/local/bin/docker-compose || handle_error "Failed to set Docker Compose as executable"

    # Verify Docker Compose installation
    docker-compose --version >/dev/null 2>&1 || handle_error "Failed to verify Docker Compose installation"

    print_success "Docker Compose installed successfully."
  fi
}

install_docker_compose
