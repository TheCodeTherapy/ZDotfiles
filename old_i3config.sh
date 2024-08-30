#!/bin/bash

restore_xorg() {
  sudo cp "${DOTDIR}"/x/xorg.conf /etc/X11/xorg.conf
}

install_i3() {
  echo
  msg="Building i3-wm ..."
  print_yellow "${msg}"
  cd "$DOTDIR" || exit
  mkdir -p build
  git clone https://github.com/i3/i3 build/i3
  cd build/i3 || exit
  mkdir -p build && cd build || exit
  meson -Ddocs=true -Dmans=true ..
  ninja
  sudo ninja install
  cd "$DOTDIR" || exit
}

install_i3_status() {
  echo
  msg="Building i3-status ..."
  print_yellow "${msg}"
  cd "$DOTDIR" || exit
  mkdir -p build
  git clone https://github.com/i3/i3status build/i3status
  cd build/i3status || exit
  mkdir -p build && cd build || exit
  meson ..
  ninja
  sudo ninja install
  cd "$DOTDIR" || exit
}

install_picom() {
  echo
  msg="Building picom ..."
  print_yellow "${msg}"
  cd "$DOTDIR" || exit
  mkdir -p build
  git clone https://github.com/TheCodeTherapy/picom build/picom
  cd build/picom || exit
  meson setup --buildtype=release build
  ninja -C build
  sudo ninja -C build install
  cd "$DOTDIR" || exit
}

install_polybar() {
  echo
  msg="Building polybar ..."
  print_yellow "${msg}"
  cd "$DOTDIR" || exit
  mkdir -p build
  git clone --recursive https://github.com/polybar/polybar build/polybar
  cd build/polybar || exit
  mkdir -p build && cd build || exit
  cmake ..
  make -j"$(nproc)"
  sudo make install
  cd "$DOTDIR" || exit
}

install_reaper() {
  echo
  if [[ -f $ME/.gnome/apps/cockos-reaper.desktop ]]; then
    msg="Reaper already installed."
    print_green "${msg}"
  else
    msg="Installing Reaper ..."
    print_yellow "${msg}"
    cd "$DOTDIR"/software || exit
    tar -xf reaper707_linux_x86_64.tar.xz
    cd "$DOTDIR"/software/reaper_linux_x86_64 || exit
    ./install-reaper.sh --integrate-user-desktop
    cd "$DOTDIR" || exit
  fi
}

restore_monitor_cfg() {
  msg="Restoring monitor configuration"
  print_cyan "${msg}"
  cp "${HOME}"/ZDotfiles/monitor/monitors-backup.xml ~/.config/monitors.xml
}

sudo updatedb
setup_fonts

# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# chsh -s $(which zsh)
#
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
# echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# p10k configure
#
