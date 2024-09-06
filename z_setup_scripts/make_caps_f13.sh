#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

make_caps_f13() {
  print_info "Replacing CAPS key with F13 key using custom keyboard file..."

  # Copy the custom keyboard configuration file to /etc/default/keyboard
  sudo cp "${DOTDIR}"/dotfiles/etc/keyboard_f13 /etc/default/keyboard ||
    handle_error "Failed to copy keyboard_f13 file."

  # Apply the new keyboard settings
  sudo udevadm trigger --subsystem-match=input --action=change ||
    handle_error "Failed to trigger udevadm to apply new keyboard settings."

  # Update GNOME settings to ensure they don't override the remap
  print_info "Updating GNOME settings to map CAPS to F13 ..."
  if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.input-sources xkb-options "['caps:f13']" ||
      handle_error "Failed to set xkb-options using gsettings."
  elif command -v dconf &>/dev/null; then
    dconf write /org/gnome/desktop/input-sources/xkb-options "['caps:f13']" ||
      handle_error "Failed to set xkb-options using dconf."
  else
    handle_error "Neither gsettings nor dconf command found; unable to update GNOME settings."
  fi

  # Confirm the update
  if dconf read /org/gnome/desktop/input-sources/xkb-options | grep -q "['caps:f13']"; then
    print_success "CAPS key successfully remapped to F13."
  else
    handle_error "Failed to confirm CAPS key remapping in GNOME settings."
  fi
}

make_caps_f13
