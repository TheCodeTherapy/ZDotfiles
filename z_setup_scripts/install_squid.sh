#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_squid() {
  if squid --version >/dev/null 2>&1; then
    print_info "Squid is already installed ..."
  else
    print_info "Installing Squid ..."

    sudo apt-get update -qq ||
      handle_error "Failed to update package list"

    sudo apt-get install -y -qq squid-openssl ||
      handle_error "Failed to install Squid"

    # backup default config
    sudo mv /etc/squid/squid.conf /etc/squid/squid.conf.bak ||
      handle_error "Failed to backup default config"

    # copy custom config
    sudo cp "$DOTDOT/etc/squid.conf" /etc/squid/squid.conf ||
      handle_error "Failed to copy custom config"

    # generates certificates
    sudo openssl req -new -newkey rsa:2048 \
      -days 1825 -nodes -x509 \
      -keyout /etc/squid/squid.key \
      -out /etc/squid/squid.crt ||
      handle_error "Failed to generate certificates"

    # initialize security dir
    sudo /usr/lib/squid/security_file_certgen -c -s /var/lib/ssl_db -M 32MB ||
      handle_error "Failed to initialize security dir ssl_db"

    # restart squid
    sudo systemctl restart squid ||
      handle_error "Failed to restart Squid"

    print_success "Squid installed successfully."
  fi
}

install_squid
