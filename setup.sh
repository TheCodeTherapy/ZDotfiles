#!/bin/bash

source "$(dirname "$0")/z_setup_scripts/_helpers.sh"
source "$(dirname "$0")/z_setup_scripts/_config.sh"

update_system() {
  print_info "Updating system ..."
  sudo apt-get update -qq || handle_error "Failed to update package lists."
  sudo apt-get full-upgrade -y -qq || handle_error "System update failed."
  sudo apt-get autoremove -y -qq || handle_error "Autoremove failed."
  sudo apt-get autoclean -y -qq || handle_error "Autoclean failed."
  sudo apt-get install -y -qq aptitude || handle_error "Failed to install aptitude."
}

install_basic_packages() {
  local packages=(
    plocate build-essential llvm pkg-config autoconf automake cmake cmake-data
    autopoint ninja-build gettext libtool libtool-bin g++ make meson clang gcc
    nasm clang-tools dkms curl wget ca-certificates gnupg lsb-release feh gawk
    xclip notification-daemon git git-lfs zsh tmux gnome-tweaks inxi most tree
    nautilus-admin tar jq pixz screenkey mypaint rofi gimp blender lzma unzip
    neofetch playerctl fonts-font-awesome slop dunst timidity gir1.2-gtk-3.0
    ttfautohint v4l2loopback-dkms ffmpeg htop bc fzf ranger ripgrep gdebi rar
    imagemagick net-tools xcb-proto gir1.2-ayatanaappindicator3-0.1 dialog
    nautilus-extension-gnome-terminal asciidoc gnome-shell-extension-manager
    policykit-1 policykit-1-gnome uthash-dev hashdeep file usbview v4l-utils
    python-is-python3 ipython3 python3-pip python3-dev python3-venv
    python3-gi python3-gi-cairo python3-cairo python3-setuptools
    python3-babel python3-dbus python3-pynvim python3-sphinx python3-packaging
    python3-xcbgen pipx xutils-dev xwayland valac hwdata vlc transmission
    bear p7zip-full conky-all zsh-autosuggestions zsh-syntax-highlighting
  )

  print_info "Installing basic packages ..."
  if ! sudo debconf-apt-progress -- apt-get install -y "${packages[@]}"; then
    handle_error "Failed to install one or more packages."
  fi
}

install_dev_libs() {
  local devlibs=(
    libwayland-dev libffi-dev libxml2-dev libegl1-mesa-dev libgles2-mesa-dev
    libgbm-dev libinput-dev libglm-dev libgtkmm-3.0-dev libdrm-dev
    libgirepository1.0-dev libsystemd-dev libxcb-xinput-dev libseat-dev
    libdbusmenu-gtk3-dev libxkbregistry-dev libdisplay-info-dev
    libev-dev libgtk-3-dev libgtk-4-dev libwebkit2gtk-4.1-dev libsdl1.2-dev
    libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev
    libnotify-bin libfontconfig1-dev libfreetype-dev libxext-dev liblxc-dev
    libxrandr-dev libxinerama-dev libxcursor-dev libglx-dev libgl-dev
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev
    libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev
    libxcb-randr0-dev libxcb-cursor-dev libxcb-xinerama0-dev
    libxcb-shape0-dev libxcb-xrm-dev libxcb-xrm0 libxcb-xkb-dev libconfig-dev
    libx11-xcb-dev libdbus-1-dev libegl-dev libpcre2-dev libpixman-1-dev
    libxcb-composite0-dev libxcb-damage0-dev libxcb-dpms0-dev libxcb-glx0-dev
    libxcb-image0-dev libxcb-present-dev libxcb-render0-dev
    libxcb-render-util0-dev libxcb-util-dev libxcb-xfixes0-dev libxkbcommon-dev
    libxcb-ewmh-dev libnl-genl-3-dev libuv1-dev libcairo2-dev libjsoncpp-dev
    libxkbcommon-x11-dev libconfuse-dev libasound2-dev libiw-dev libpulse-dev
    libmpdclient-dev libcurl4-openssl-dev libx11-dev libxcomposite-dev
    libxfixes-dev libgl1-mesa-dev libxi-dev libwayland-dev libncurses5-dev
    libreadline-dev libxrender-dev libglew-dev libsdl2-dev libz3-dev
    libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libopenal-data
    libmpg123-dev libsndfile1-dev zlib1g-dev libglvnd-dev mesa-common-dev
    libegl1 libgles-dev libgles1 libglvnd-core-dev libopengl-dev
    libwxgtk3.2-dev libwxgtk3.2-1t64 libwxbase3.2-1t64 libwxsvg-dev libftgl-dev
    libfreeimage-dev liblua5.4-dev libwxgtk-webview3.2-dev libadwaita-1-dev
    libwireplumber-0.4-dev libdmapsharing-4.0-dev libswresample-dev
  )

  print_info "Installing dev libs ..."
  if ! sudo debconf-apt-progress -- apt-get install -y "${devlibs[@]}"; then
    handle_error "Failed to install one or more dev libs."
  fi
}

update_plocate_db() {
  print_info "Updating plocate database ..."
  sudo updatedb || handle_error "Failed to update the file database."
}

install_recipes() {
  local recipe_dir
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  recipe_dir="${SCRIPT_DIR}/z_setup_scripts"

  local recipes=(
    "$recipe_dir/install_neovim.sh"
    "$recipe_dir/install_vscode.sh"
    "$recipe_dir/install_obs.sh"
    "$recipe_dir/install_nvm.sh"
    "$recipe_dir/install_node.sh"
    "$recipe_dir/install_yarn.sh"
    "$recipe_dir/install_chrome.sh"
    "$recipe_dir/install_brave.sh"
    "$recipe_dir/install_lazygit.sh"
    "$recipe_dir/install_gcloud.sh"
    "$recipe_dir/install_chromiumdepottools.sh"
    "$recipe_dir/install_cloudflared.sh"
    "$recipe_dir/install_githubcli.sh"
    "$recipe_dir/install_tmuxpm.sh"
    "$recipe_dir/install_rust.sh"
    "$recipe_dir/install_golang.sh"
    "$recipe_dir/install_mono.sh"
    "$recipe_dir/install_exa.sh"
    "$recipe_dir/install_docker.sh"
    "$recipe_dir/install_dockercompose.sh"
    "$recipe_dir/install_nvidiacontainertk.sh"
    "$recipe_dir/install_xcolor.sh"
    "$recipe_dir/install_fd.sh"
    "$recipe_dir/install_alacritty.sh"
    "$recipe_dir/install_ytdlp.sh"
    "$recipe_dir/install_squid.sh"
    "$recipe_dir/fix_cedilla.sh"
    "$recipe_dir/restore_terminal_cfg.sh"
    "$recipe_dir/restore_bind_keys.sh"
    "$recipe_dir/make_caps_hyper.sh"
  )

  for recipe in "${recipes[@]}"; do
    if [ -f "$recipe" ]; then
      print_info "Running recipe: $(basename "$recipe")"
      # shellcheck source=/dev/null
      source "$recipe" || handle_error "Failed to execute recipe: $(basename "$recipe")"
    else
      print_warning "Recipe not found: $(basename "$recipe")"
    fi
  done
}

link_dotfiles() {
  local target_home="$HOME"
  local target_config="$HOME/.config"
  mkdir -p "$target_config/Code/User"
  declare -A files_to_link=(
    ["${DOTDOT}/profile/profile"]="$target_home/.profile"
    ["${DOTDOT}/bash/bashrc"]="$target_home/.bashrc"
    ["${DOTDOT}/bash/inputrc"]="$target_home/.inputrc"
    ["${DOTDOT}/zsh/zshrc"]="$target_home/.zshrc"
    ["${DOTDOT}/zsh/zshenv"]="$target_home/.zshenv"
    ["${DOTDOT}/tmux/tmux.conf"]="$target_home/.tmux.conf"
    ["${DOTDOT}/x/XCompose"]="$target_home/.XCompose"
    ["${DOTDOT}/themes"]="$target_home/.themes"
    ["${DOTDOT}/mame"]="$target_home/.mame"
    ["${DOTDOT}/darkplaces"]="$target_home/.darkplaces"
    ["${DOTDOT}/lutris"]="$target_home/.local/share/lutris"
    ["${DOTDOT}/attract"]="$target_home/.attract"
    ["${DOTDOT}/vst3"]="$target_home/.vst3"
    ["${DOTDOT}/fonts"]="$target_home/.fonts"
    ["${DOTDOT}/scummvm"]="$target_config/scummvm"
    ["${DOTDOT}/screenkey"]="$target_config/screenkey"
    ["${DOTDOT}/nvim"]="$target_config/nvim"
    ["${DOTDOT}/i3"]="$target_config/i3"
    ["${DOTDOT}/i3status"]="$target_config/i3status"
    ["${DOTDOT}/polybar"]="$target_config/polybar"
    ["${DOTDOT}/alacritty"]="$target_config/alacritty"
    ["${DOTDOT}/picom"]="$target_config/picom"
    ["${DOTDOT}/dunst"]="$target_config/dunst"
    ["${DOTDOT}/neofetch"]="$target_config/neofetch"
    ["${DOTDOT}/vscode/settings.json"]="$target_config/Code/User/settings.json"
  )

  for source_file in "${!files_to_link[@]}"; do
    local target_file="${files_to_link[$source_file]}"
    link_file "$source_file" "$target_file"
  done
}

install_snap_packages() {
  print_info "Installing snap packages ..."
  install_with_snap discord
  install_with_snap kdiskmark
  install_with_snap spotify
}

link_launchers() {
  print_info "Linking launchers ..."
  mkdir -p "$ME"/.local/share/applications
  link_file "${DOTDOT}/launchers/alacritty.desktop" "${HOME}/.local/share/applications/alacritty.desktop"
  update-desktop-database "$ME"/.local/share/applications
}

update_cache() {
  print_info "Updating fonts cache ..."
  fc-cache -f || handle_error "Failed to update font cache."
  sudo updatedb || handle_error "Failed to update the file database."
}

update_system

install_basic_packages
install_dev_libs
update_plocate_db

install_recipes
install_snap_packages

link_dotfiles
link_launchers

update_cache
