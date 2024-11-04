#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

install_fanatec() {
  if [[ -d $DOTDIR/drivers/hid-fanatecff ]]; then
    print_info "Fanatec drivers already installed ..."
  else
    print_info "Installing Fanatec drivers ..."

    cd "$DOTDIR" ||
      handle_error "Failed to change directory to $DOTDIR"

    mkdir -p drivers || handle_error "Failed to create drivers directory"
    cd drivers || handle_error "Failed to enter drivers directory"

    git clone --quiet https://github.com/TheCodeTherapy/hid-fanatecff.git ||
      handle_error "Failed to clone repository"

    cd hid-fanatecff || handle_error "Failed to enter hid-fanatecff directory"

    sudo apt-get install -y -qq linux-headers-$(uname -r)

    make || handle_error "Failed to build Fanatec drivers"

    sudo make install || handle_error "Failed to install Fanatec drivers"

    sudo udevadm control --reload-rules && sudo udevadm trigger

    print_success "Fanatec drivers installed successfully."
  fi
}

install_oversteer() {
  if oversteer --version >/dev/null 2>&1; then
    print_info "Oversteer already installed ..."
  else
    print_info "Installing Oversteer ..."

    cd "$DOTDIR" ||
      handle_error "Failed to change directory to $DOTDIR"

    mkdir -p drivers || handle_error "Failed to create drivers directory"
    cd drivers || handle_error "Failed to enter drivers directory"

    git clone --quiet https://github.com/TheCodeTherapy/oversteer.git ||
      handle_error "Failed to clone repository"

    cd oversteer || handle_error "Failed to enter oversteer directory"

    sudo apt-get install -y -qq \
      python3 python3-distutils-extra python3-gi python3-gi-cairo \
      gir1.2-gtk-4.0 python3-pyudev python3-pyxdg python3-evdev \
      gettext meson appstream desktop-file-utils python3-matplotlib \
      python3-scipy || handle_error "Failed to install required packages"

    meson setup build || handle_error "Failed to setup meson"

    cd build || handle_error "Failed to enter build directory"

    sudo ninja install || handle_error "Failed to install Oversteer"

    sudo udevadm control --reload-rules && sudo udevadm trigger

    print_success "Oversteer installed successfully."
  fi
}

install_fanatec
install_oversteer
