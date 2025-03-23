#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_cursor() {
  if [ -f "/opt/cursor/cursor.AppImage" ]; then
    print_info "Cursor is already installed ..."
  else
    print_info "Installing Cursor ..."

    sudo apt-get update -qq || handle_error "Failed to update package list."
    sudo apt-get full-upgrade -y -qq || handle_error "Failed to update and upgrade the system."

    # URLs for Cursor AppImage and Icon
    CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
    ICON_URL="https://raw.githubusercontent.com/rahuljangirwork/copmany-logos/refs/heads/main/cursor.png"

    # Paths for installation
    CURSOR_PATH="/opt/cursor"
    APPIMAGE_PATH="$CURSOR_PATH/cursor.AppImage"
    ICON_PATH="$CURSOR_PATH/cursor.png"
    DESKTOP_ENTRY_PATH="/usr/share/applications/cursor.desktop"

    sudo mkdir -p $CURSOR_PATH || handle_error "Failed to create directory for Cursor."

    # Download Cursor AppImage
    print_info "Downloading Cursor AppImage ..."
    sudo curl -L $CURSOR_URL -o $APPIMAGE_PATH || handle_error "Failed to download Cursor AppImage."
    sudo chmod +x $APPIMAGE_PATH || handle_error "Failed to set permissions for Cursor AppImage."

    print_info "Downloading Cursor Icon ..."
    sudo curl -L $ICON_URL -o $ICON_PATH || handle_error "Failed to download Cursor Icon."

    print_info "Creating .desktop entry for Cursor ..."
    sudo bash -c "cat > $DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH --no-sandbox %F
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

    print_success "Cursor installed successfully."
  fi
}

install_cursor
