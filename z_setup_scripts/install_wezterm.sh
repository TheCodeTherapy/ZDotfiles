#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_wezterm() {
  if wezterm --version >/dev/null 2>&1; then
    print_info "Wezterm already installed ..."
  else
    print_info "Installing Wezterm ..."

    cd "$DOTDIR" || handle_error "Failed to change directory to $DOTDIR"

    mkdir -p build || handle_error "Failed to create build directory"

    cd build || handle_error "Failed to enter build directory"

    git clone --depth=1 --branch=main --recursive https://github.com/wezterm/wezterm.git || handle_error "Failed to clone Wezterm repository"

    cd wezterm || handle_error "Failed to enter Wezterm directory"

    git submodule update --init --recursive || handle_error "Failed to update submodules"

    ./get-deps || handle_error "Failed to get dependencies"

    cargo update || handle_error "Failed to update Cargo dependencies"

    # This is the option to build with no wayland support
    # cargo build --release --no-default-features --features vendored-fonts

    cargo build --release || handle_error "Failed to build Wezterm"

    print_info "Installing WezTerm binaries ..."

    BIN_DEST="$HOME/.local/bin"
    mkdir -p "$BIN_DEST" || handle_error "Failed to create $BIN_DEST"

    cd target/release || handle_error "Failed to enter target/release"

    # Find and copy all ELF executables into ~/.local/bin
    for bin in $(file * | grep 'ELF .* executable' | cut -d: -f1); do
      cp "$bin" "$BIN_DEST/" || handle_error "Failed to copy $bin to $BIN_DEST"
      print_success "Installed $bin to $BIN_DEST"
    done

    # Go back to project root or wherever you want
    cd "$DOTDIR" || handle_error "Failed to return to project root"

    print_success "Wezterm installed successfully."
  fi
}

install_wezterm
