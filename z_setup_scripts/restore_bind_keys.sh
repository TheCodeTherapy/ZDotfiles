#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

restore_bind_keys() {
  print_info "Restoring custom shortcuts ..."
  dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < \
    "${DOTDIR}"/dotfiles/dconf/gnome-custom-shortcuts.dconf
}

restore_bind_keys
