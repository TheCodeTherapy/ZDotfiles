#!/bin/bash
#set -eu -o pipefail

#=============================================================================
# @TheCodeTherapy - https://mgz.me
# dotfiles config script
#=============================================================================

ME="/home/$(whoami)"
DOTDIR="${ME}/ZDotfiles"
NVMDIR="${ME}/.nvm"
DOTLOCAL="${ME}/.local"
BINDIR="${DOTDIR}/bin"
CFG="$ME/.config"
HOSTSBACKUP=/etc/hosts.bak
HOSTSDENYBACKUP=/etc/hostsdeny.bak
HOSTSSECURED="${DOTDIR}/hostssecured"

mkdir -p "$ME"/Storage/NAS/volume1/

declare -rA COLORS=(
  [RED]=$'\033[0;31m'
  [GREEN]=$'\033[0;32m'
  [BLUE]=$'\033[0;34m'
  [PURPLE]=$'\033[0;35m'
  [CYAN]=$'\033[0;36m'
  [WHITE]=$'\033[0;37m'
  [YELLOW]=$'\033[0;33m'
  [BOLD]=$'\033[1m'
  [OFF]=$'\033[0m'
)

print_red() {
  echo -e "${COLORS[RED]}${1}${COLORS[OFF]}"
}

print_yellow() {
  echo -e "${COLORS[YELLOW]}${1}${COLORS[OFF]}"
}

print_green() {
  echo -e "${COLORS[GREEN]}${1}${COLORS[OFF]}"
}

print_cyan() {
  echo -e "${COLORS[CYAN]}${1}${COLORS[OFF]}"
}

wait_key() {
  echo -e "\n${COLORS[YELLOW]}"
  read -n 1 -s -r -p "${1}"
  echo -e "${COLORS[OFF]}\n"
}

home_link() {
  msg="[LINKING] $DOTDIR/$1 to $ME/$2"
  print_cyan "${msg}"
  sudo rm -rf "$ME"/"$2" >/dev/null 2>&1 &&
    ln -s "$DOTDIR"/"$1" "$ME"/"$2" ||
    ln -s "$DOTDIR"/"$1" "$ME"/"$2"
}

home_link_cfg() {
  msg="[LINKING] $DOTDIR/dotconfig/$1 to $CFG/$1"
  print_cyan "${msg}"
  sudo rm -rf "$CFG"/"$1" >/dev/null 2>&1 &&
    ln -s "$DOTDIR"/dotconfig/"$1" "$CFG"/. ||
    ln -s "$DOTDIR"/dotconfig/"$1" "$CFG"/.
}

link_dotfiles() {
  echo
  msg="LINKING DOTFILES ..."
  print_yellow "${msg}"
  mkdir -p "${DOTLOCAL}"

  if [[ -f $DOTDIR/homeconfig/attract/attract.cfg ]]; then
    msg="Attract Mode configs already retrieved."
    print_green "${msg}"
  else
    msg="RETRIEVING ATTRACT MODE CONFIG ..."
    print_yellow "${msg}"
    cd "$DOTDIR"/homeconfig || exit
    git clone https://github.com/TheCodeTherapy/attract-cfg.git attract
    cd "$DOTDIR" || exit
  fi

  home_link "homeconfig/profile/profile" ".profile"
  home_link "homeconfig/bash/bashrc" ".bashrc"
  home_link "homeconfig/bash/inputrc" ".inputrc"
  home_link "homeconfig/zsh/zshrc" ".zshrc"
  home_link "homeconfig/zsh/zshenv" ".zshenv"
  home_link "homeconfig/tmux/tmux.conf" ".tmux.conf"

  home_link "homeconfig/x/XCompose" ".XCompose"
  home_link "homeconfig/themes" ".themes"
  home_link "homeconfig/mame" ".mame"

  home_link "homeconfig/darkplaces" ".darkplaces"
  home_link "homeconfig/lutris" ".local/share/lutris"
  home_link "homeconfig/attract" ".attract"
  home_link "homeconfig/vst3" ".vst3"

  home_link_cfg "scummvm"
  home_link_cfg "screenkey"
  home_link_cfg "nvim"
  home_link_cfg "i3"
  home_link_cfg "i3status"
  home_link_cfg "polybar"
  home_link_cfg "alacritty"
  home_link_cfg "picom"
  home_link_cfg "dunst"
  home_link_cfg "neofetch"
}

link_launchers() {
  echo
  mkdir -p "$ME"/.local/share/applications
  # home_link "homeconfig/launchers/org.gnome.Terminal.desktop" ".local/share/applications/org.gnome.Terminal.desktop"
  home_link "homeconfig/launchers/alacritty.desktop" ".local/share/applications/alacritty.desktop"
  update-desktop-database "$ME"/.local/share/applications
}

install_with_aptitude() {
  msg="Installing $1 ..."
  print_yellow "${msg}"
  sudo aptitude -y install "$1"
}

install_with_snap() {
  if locate "$1" | grep '/snap/bin' >/dev/null 2>&1; then
    msg="$1 already installed."
    print_green "${msg}"
  else
    msg="Installing $1 ..."
    print_yellow "${msg}"
    sudo snap install "$1"
  fi
}

update_system() {
  echo
  msg="UPDATING SYSTEM ..."
  print_yellow "${msg}"
  sudo apt --assume-yes update && sudo apt --assume-yes full-upgrade
  sudo apt --assume-yes autoremove
  sudo apt --assume-yes autoclean
  sudo apt --assume-yes install aptitude
}

install_basic_packages() {
  echo
  msg="INSTALLING BASIC PACKAGES ..."
  mkdir -p "${BINDIR}"
  print_yellow "${msg}"
  # sudo killall packagekitd
  sudo systemctl daemon-reload
  sudo add-apt-repository --yes multiverse
  sudo aptitude update
  sudo aptitude -y install plocate build-essential llvm \
    pkg-config autoconf automake cmake cmake-data autopoint \
    ninja-build gettext libtool libtool-bin g++ meson \
    clang clang-tools ca-certificates curl gnupg lsb-release \
    python-is-python3 ipython3 python3-pip python3-dev gawk \
    unzip lzma tree neofetch git git-lfs zsh tmux gnome-tweaks \
    inxi most ttfautohint v4l2loopback-dkms ffmpeg htop bc \
    ranger libxext-dev ripgrep python3-pynvim xclip libnotify-bin \
    libfontconfig1-dev libfreetype-dev jq pixz hashdeep liblxc-dev \
    libxrandr-dev libxinerama-dev libxcursor-dev libglx-dev libgl-dev \
    screenkey mypaint rofi gimp blender imagemagick net-tools \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
    libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev \
    libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev \
    libxcb-shape0-dev libxcb-xrm-dev libxcb-xrm0 libxcb-xkb-dev \
    libconfig-dev libdbus-1-dev libegl-dev libpcre2-dev libpixman-1-dev \
    libx11-xcb-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-util-dev \
    libxcb-xfixes0-dev uthash-dev libxkbcommon-dev libxkbcommon-x11-dev \
    xutils-dev asciidoc libconfuse-dev libasound2-dev libiw-dev \
    libpulse-dev libnl-genl-3-dev feh notification-daemon dunst \
    python3-sphinx python3-packaging libuv1-dev libcairo2-dev \
    python3-xcbgen libxcb-ewmh-dev libjsoncpp-dev libmpdclient-dev \
    libcurl4-openssl-dev xcb-proto policykit-1-gnome \
    python3-gi gir1.2-gtk-3.0 python3-gi-cairo python3-cairo \
    python3-setuptools python3-babel python3-dbus playerctl \
    fonts-font-awesome slop gir1.2-ayatanaappindicator3-0.1 \
    libgtk-4-dev libx11-dev libxcomposite-dev libxfixes-dev \
    libgl1-mesa-dev libxi-dev libwayland-dev \
    libncurses5-dev libreadline-dev usbview v4l-utils

  # sudo aptitude install \
  #     openjdk-8-jre=8u312-b07-0ubuntu1 \
  #     openjdk-8-jre-headless=8u312-b07-0ubuntu1
  sudo updatedb
}

install_vscode() {
  echo
  if code --version >/dev/null 2>&1; then
    msg="VSCode already installed."
    print_green "${msg}"
  elif locate code | grep '/usr/bin/code' | grep -v 'codepage' >/dev/null 2>&1; then
    msg="VSCode already installed."
    print_green "${msg}"
  else
    msg="INSTALLING VSCODE ..."
    print_yellow "${msg}"
    sudo apt --assume-yes install software-properties-common apt-transport-https wget
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
            https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt --assume-yes update
    sudo apt --assume-yes install code
  fi
}

install_obs_studio() {
  echo
  PPA=$(ls /etc/apt/sources.list.d/obs* 2>/dev/null | wc -l)
  if [ "$PPA" != 0 ]; then
    msg="OBS Studio PPA already configured."
    print_green "${msg}"
  else
    sudo add-apt-repository -y ppa:obsproject/obs-studio
    sudo apt update
  fi
  if obs --version >/dev/null 2>&1; then
    msg="OBS Studio alteady installed."
    print_green "${msg}"
  else
    install_with_aptitude obs-studio
  fi
}

install_extra_packages() {
  echo
  msg="INSTALLING EXTRA PACKAGES ..."
  print_yellow "${msg}"
  if cat /etc/os-release | head -n 1 | grep "Pop" >/dev/null 2>&1; then
    msg="Distro is Pop!_OS"
    print_cyan "${msg}"
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak update
    sudo flatpak -y install com.spotify.Client
    sudo flatpak -y install com.discordapp.Discord
  else
    install_with_snap discord
    install_with_snap kdiskmark
    install_with_snap spotify
  fi
  install_vscode
  install_obs_studio
}

fix_cedilla() {
  echo
  msg="Fixing cedilla character on XCompose..."
  print_cyan "${msg}"
  mkdir -p "$DOTDIR"/homeconfig/x
  sed -e 's,\xc4\x86,\xc3\x87,g' -e 's,\xc4\x87,\xc3\xa7,g' \
    </usr/share/X11/locale/en_US.UTF-8/Compose \
    >"$DOTDIR"/homeconfig/x/XCompose
  home_link "homeconfig/x/XCompose" ".XCompose"
  sudo cp /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache.bckp
  sudo sed -i 's,"az:ca:co:fr:gv:oc:pt:sq:tr:wa","az:ca:co:fr:gv:oc:pt:sq:tr:wa:en",g' /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
  sudo cp /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache.bckp
  sudo sed -i 's,"az:ca:co:fr:gv:oc:pt:sq:tr:wa","az:ca:co:fr:gv:oc:pt:sq:tr:wa:en",g' /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache
  sudo cp "$DOTDIR"/etc/environment /etc/environment
}

make_caps_super() {
  echo
  msg="Replacing CAPS key by Super key ..."
  print_yellow "${msg}"
  sudo cp "${DOTDIR}"/keyboard/keyboard /etc/default/keyboard
  sudo udevadm trigger --subsystem-match=input --action=change
}

install_nvm() {
  echo
  msg="INSTALLING NVM ..."
  print_yellow "${msg}"
  if [[ -f $NVMDIR/nvm.sh ]]; then
    print_green "nvm already installed."
  else
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source "${ME}"/.bashrc
    nvm --version
  fi
}

install_node() {
  echo
  msg="INSTALLING NODEJS ..."
  print_yellow "${msg}"
  if [[ -f $NVMDIR/nvm.sh ]]; then
    if npm --version >/dev/null 2>&1; then
      msg="npm already installed."
      print_green "${msg}"
    else
      source "$NVMDIR"/nvm.sh
      VER=$(nvm ls-remote --lts | grep "Latest" | tail -n 1 | sed 's/[-/a-zA-Z]//g' | sed 's/^[ \t]*//')
      msg="Installing Latest NodeJS version found: ${VER}"
      print_yellow "${msg}"
      nvm install "$VER"
    fi
  else
    msg="nvm not installed."
    print_red "${msg}"
  fi
}

install_yarn() {
  echo
  if yarn --version >/dev/null 2>&1; then
    msg="Yarn already installed."
    print_green "${msg}"
  else
    msg="Installing Yarn package..."
    print_yellow "${msg}"
    NVM_DIR="$HOME/.nvm"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
    source "${ME}"/.bashrc
    npm install --global yarn
  fi
}

install_rust() {
  echo
  if [[ -f /etc/profile.d/rust.sh ]]; then
    msg="Rust already installed."
    print_green "${msg}"
  else
    msg="INSTALLING RUST ..."
    print_yellow "${msg}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "${ME}"/.bashrc
    rustc --version
  fi
}

install_exa() {
  echo
  if [[ -f $HOME/.cargo/bin/exa ]]; then
    msg="Exa already installed."
    print_green "${msg}"
  else
    msg="INSTALLING EXA ..."
    print_yellow "${msg}"
    cargo install exa
  fi
}

install_golang() {
  echo
  if go version >/dev/null 2>&1; then
    msg="Golang already installed."
    print_green "${msg}"
  else
    msg="INSTALLING GOLANG ..."
    print_yellow "${msg}"
    cd "$DOTDIR" || exit
    mkdir -p temp
    cd temp || exit
    wget https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.0.linux-amd64.tar.gz
    # we mst add export PATH=$PATH:/usr/local/go/bin to $HOME/.profile IF it's not there
    if ! grep -q '/usr/local/go/bin' "$HOME"/.profile; then
      echo 'export PATH=$PATH:/usr/local/go/bin' >>"$HOME"/.profile
    fi
    source "$HOME"/.profile
    go version
  fi
}

install_xcolor() {
  echo
  if [[ -f $HOME/.cargo/bin/xcolor ]]; then
    msg="XColor already installed."
    print_green "${msg}"
  else
    msg="INSTALLING XCOLOR ..."
    print_yellow "${msg}"
    cargo install xcolor
  fi
}

choose_fastest_mirror() {
  echo
  sudo apt -y install curl
  msg="# Checking mirrors speed (please wait)..."
  print_cyan "${msg}"
  fastest=$(curl -s http://mirrors.ubuntu.com/mirrors.txt |
    xargs -n1 -I {} sh -c 'echo `curl -r 0-102400 -s -w %{speed_download} -o /dev/null {}/ls-lR.gz` {}' |
    sort -g -r |
    head -1 |
    awk '{ print $2 }')
  echo $fastest
  cn=$(lsb_release -cs)
  mirror="deb $fastest"
  list="$mirror $cn main restricted"
  list="$list\n$mirror $cn-updates main restricted"
  list="$list\n$mirror $cn universe"
  list="$list\n$mirror $cn-updates universe"
  list="$list\n$mirror $cn multiverse"
  list="$list\n$mirror $cn-updates multiverse"
  list="$list\n$mirror $cn-backports main restricted universe multiverse"
  list="$list\n$mirror $cn-security main restricted"
  list="$list\n$mirror $cn-security universe"
  list="$list\n$mirror $cn-security multiverse"
  #echo -e $list | sudo tee /etc/apt/sources.list
  echo -e $list
}

protect_hosts() {
  echo
  if [ ! -f "$HOSTSBACKUP" ]; then
    sudo cp /etc/hosts $HOSTSBACKUP
  fi
  if [ ! -f "$HOSTSDENYBACKUP" ]; then
    sudo cp /etc/hosts.deny $HOSTSDENYBACKUP
  fi
  if [ ! -f "$HOSTSSECURED" ]; then
    msg="# Protecting hosts and hosts.deny"
    print_cyan "${msg}"
    sudo wget https://hosts.ubuntu101.co.za/hosts -O /etc/hosts
    sudo wget https://hosts.ubuntu101.co.za/hosts.deny -O /etc/hosts.deny
    touch $HOSTSSECURED
  else
    msg="# hosts and hosts.deny already protected."
    print_green "${msg}"
  fi
}

restore_xorg() {
  sudo cp "${DOTDIR}"/x/xorg.conf /etc/X11/xorg.conf
}

install_neovim() {
  echo
  if [[ -f /usr/bin/nvim ]]; then
    msg="Neovim already installed."
    print_green "${msg}"
  else
    msg="INSTALLING NEOVIM ..."
    print_yellow "${msg}"
    cd "$DOTDIR" || exit
    git clone https://github.com/neovim/neovim
    cd neovim || exit
    git fetch --tags
    git checkout v0.10.1
    make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)
    cd build && cpack -G DEB
    sudo dpkg -i nvim-linux64.deb
    cd "$DOTDIR" || exit
  fi
}

install_docker() {
  echo
  if docker --version >/dev/null 2>&1; then
    msg="Docker already installed."
    print_green "${msg}"
  else
    msg="INSTALLING DOCKER ..."
    print_yellow "${msg}"
    # Add Docker's official GPG key:
    sudo apt --assume-yes update && sudo apt --assume-yes full-upgrade
    sudo apt --assume-yes install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt --assume-yes update
    sudo apt --assume-yes install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -a -G docker "$USER"
  fi
}

install_docker_compose() {
  echo
  if docker-compose --version >/dev/null 2>&1; then
    msg="Docker-compose already installed."
    print_green "${msg}"
  else
    msg="INSTALLING DOCKER-COMPOSE ..."
    print_yellow "${msg}"
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi
}

install_fd() {
  echo
  if fd --version >/dev/null 2>&1; then
    msg="fd already installed."
    print_green "${msg}"
  else
    msg="Installing fd package..."
    print_yellow "${msg}"
    cargo install fd-find
  fi
}

setup_fonts() {
  echo
  msg="SETTING UP FONTS ..."
  print_yellow "${msg}"
  rm -rf "$ME"/.fonts >/dev/null 2>&1 &&
    ln -s "$DOTDIR"/fonts "$ME"/.fonts ||
    ln -s "$DOTDIR"/fonts "$ME"/.fonts
  fc-cache -f
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
  make -j$(nproc)
  sudo make install
  cd "$DOTDIR" || exit
}

install_alacritty() {
  echo
  msg="Building alacritty ..."
  print_yellow "${msg}"
  cargo install alacritty
}

customize_vscode() {
  echo
  msg="Customizing vscode ..."
  print_yellow "${msg}"
  sudo rm -rf "${CFG}"/Code/User/settings.json >/dev/null 2>&1 &&
    ln -s "${DOTDIR}"/vscode/settings.json "${CFG}"/Code/User/settings.json ||
    ln -s "${DOTDIR}"/vscode/settings.json "${CFG}"/Code/User/settings.json
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

install_chrome() {
  echo
  if google-chrome-stable --version >/dev/null 2>&1; then
    msg="Google Chrome already installed."
    print_green "${msg}"
  else
    msg="Installing Google Chrome..."
    print_yellow "${msg}"
    cd ~/Downloads || exit
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo rm -f google-chrome-stable_current_amd64.deb
  fi
}

install_brave() {
  echo
  if brave-browser --version >/dev/null 2>&1; then
    msg="Brave Browser already installed."
    print_green "${msg}"
  else
    msg="Installing Brave Browser..."
    print_yellow "${msg}"
    sudo apt --assume-yes install curl
    sudo curl -fsSLo \
      /usr/share/keyrings/brave-browser-archive-keyring.gpg \
      https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt --assume-yes update
    sudo apt --assume-yes install brave-browser
  fi
}

install_lazygit() {
  echo
  if lazygit --version >/dev/null 2>&1; then
    msg="Lazygit already installed."
    print_green "${msg}"
  else
    msg="Installing Lazygit..."
    print_yellow "${msg}"
    cd "$DOTDIR" || exit
    mkdir temp
    cd temp || exit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    cd "$DOTDIR" || exit
  fi
}

install_tmux_plugin_manager() {
  echo
  if [[ -d $ME/.tmux/plugins/tpm ]]; then
    msg="Tmux Plugin Manager already installed."
    print_green "${msg}"
  else
    msg="Installing Tmux Plugin Manager..."
    print_yellow "${msg}"
    git clone https://github.com/tmux-plugins/tpm "${ME}"/.tmux/plugins/tpm
  fi
}

restore_terminal_cfg() {
  msg="Restoring terminal configuration"
  print_cyan "${msg}"
  dconf load /org/gnome/terminal/ < \
    "${DOTDIR}"/dconf/gnome-terminal-settings-backup.dconf
}

restore_bind_keys() {
  msg="Restoring custom shortcuts"
  print_cyan "${msg}"
  dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < \
    "${DOTDIR}"/dconf/gnome-custom-shortcuts.dconf
}

restore_monitor_cfg() {
  msg="Restoring monitor configuration"
  print_cyan "${msg}"
  cp "${HOME}"/ZDotfiles/monitor/monitors-backup.xml ~/.config/monitors.xml
}

update_system

install_basic_packages
install_extra_packages

install_chrome
install_brave
customize_vscode

fix_cedilla
make_caps_super

link_dotfiles

install_nvm
install_node
install_yarn

install_rust
install_exa
install_xcolor

install_golang

install_docker
install_docker_compose
install_fd

restore_terminal_cfg
restore_bind_keys

link_launchers
# restore_monitor_cfg

# install_i3
# install_i3_status
# install_picom
# install_polybar
# install_alacritty
# restore_xorg

# install_reaper

install_lazygit
install_neovim
install_tmux_plugin_manager

# source ${ME}/.bashrc

sudo updatedb
setup_fonts

echo
msg="CONFIG COMPLETE"
print_cyan "${msg}"

# choose_fastest_mirror
# protect_hosts

# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# chsh -s $(which zsh)
#
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
# echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# p10k configure

# sudo apt install jackd qjackctl pulseaudio-module-jack
# pactl load-module module-jack-sink client_name=discord_sink connect=no
# pactl load-module module-jack-source client_name=discord_source connect=no
