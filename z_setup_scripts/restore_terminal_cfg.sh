#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

restore_terminal_cfg() {
  print_info "Restoring terminal configuration ..."
  dconf load /org/gnome/terminal/ < \
    "${DOTDIR}"/dotfiles/dconf/gnome-terminal-settings-backup.dconf
}

restore_terminal_cfg
