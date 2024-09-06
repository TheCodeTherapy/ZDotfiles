#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

make_caps_altr() {
  print_info "Replacing CAPS key by Alt_R key ..."

  # Update /etc/default/keyboard
  sudo cp "${DOTDIR}"/dotfiles/etc/keyboard_altr /etc/default/keyboard ||
    handle_error "Failed to copy keyboard_altr file."
  sudo udevadm trigger --subsystem-match=input --action=change ||
    handle_error "Failed to trigger udevadm."

  # Update GNOME settings using gsettings or dconf
  print_info "Updating GNOME settings to map CAPS to Alt_R ..."
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:altgr']" ||
      handle_error "Failed to set xkb-options using gsettings."
  elif command -v dconf &>/dev/null; then
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:altgr']" ||
      handle_error "Failed to set xkb-options using dconf."
  else
    handle_error "Neither gsettings nor dconf command found; unable to update GNOME settings."
  fi

  # Confirm the update
  if dconf read /org/gnome/desktop/input-sources/xkb-options | grep -q "['caps:altgr']"; then
    print_success "CAPS key successfully remapped to Alt_R."
  else
    handle_error "Failed to confirm CAPS key remapping in GNOME settings."
  fi
}

make_caps_altr
