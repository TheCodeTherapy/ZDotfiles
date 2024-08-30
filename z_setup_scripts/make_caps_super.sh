#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

make_caps_super() {
  print_info "Replacing CAPS key by Super key ..."
  sudo cp "${DOTDIR}"/dotfiles/etc/keyboard /etc/default/keyboard
  sudo udevadm trigger --subsystem-match=input --action=change
}

make_caps_super
