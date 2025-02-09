#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_urblind() {
  if [[ -f $DOTDIR/bin/urblind ]]; then
    print_info "URBlind is already installed ..."
  else
    print_info "Installing URBlind ..."

    cd "$DOTDIR" ||
      handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    if [[ -d build/urblind ]]; then
      cd build/urblind || handle_error "Failed to change directory to URBlind"
      git pull || handle_error "Failed to update URBlind"
    else
      git clone https://github.com/TheCodeTherapy/urblind.git build/urblind ||
        handle_error "Failed to clone repository"
      cd build/urblind || handle_error "Failed to change directory to URBlind"
    fi

    ./build_posix.sh || handle_error "Failed to build URBlind"

    if [[ -f ./build/urblind ]]; then
      cp ./build/urblind "$DOTDIR/bin/." ||
        handle_error "Failed to copy urblindBlind binary to $DOTDIR/bin"
    else
      handle_error "URBlind binary not found"
    fi

    if [[ -f $DOTDIR/bin/urblind ]]; then
      print_success "URBlind installed successfully."
    else
      handle_error "URBlind binary not created properly"
    fi
  fi
}

install_urblind
