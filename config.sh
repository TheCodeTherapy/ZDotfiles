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

mkdir -p $ME/Storage/NAS/volume1/

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

print_red () {
    echo -e "\n${COLORS[RED]}${1}${COLORS[OFF]}\n"
}

print_yellow () {
    echo -e "\n${COLORS[YELLOW]}${1}${COLORS[OFF]}\n"
}

print_green () {
    echo -e "\n${COLORS[GREEN]}${1}${COLORS[OFF]}\n"
}

print_cyan () {
    echo -e "\n${COLORS[CYAN]}${1}${COLORS[OFF]}\n"
}

wait_key () {
    echo -e "\n${COLORS[YELLOW]}"
    read -n 1 -s -r -p "${1}"
    echo -e "${COLORS[OFF]}\n"
}

choose_fastest_mirror () {
    sudo apt -y install curl
    msg="# Checking mirrors speed (please wait)..."
    print_cyan "${msg}"
    fastest=$(curl -s http://mirrors.ubuntu.com/mirrors.txt \
        | xargs -n1 -I {} sh -c 'echo `curl -r 0-102400 -s -w %{speed_download} -o /dev/null {}/ls-lR.gz` {}' \
        | sort -g -r \
        | head -1 \
        | awk '{ print $2 }')
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

protect_hosts () {
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

home_link () {
    msg="[LINKING] $DOTDIR/$1 to $ME/$2"
    print_cyan "${msg}"
    sudo rm -rf $ME/$2 > /dev/null 2>&1 \
        && ln -s $DOTDIR/$1 $ME/$2 \
        || ln -s $DOTDIR/$1 $ME/$2
}

home_link_cfg () {
    msg="[LINKING] $DOTDIR/$1 to $CFG/$1"
    print_cyan "${msg}"
    sudo rm -rf $CFG/$1 > /dev/null 2>&1 \
        && ln -s $DOTDIR/$1 $CFG/. \
        || ln -s $DOTDIR/$1 $CFG/.
}

link_dotfiles () {
    msg="LINKING DOTFILES ..."
    print_yellow "${msg}"
    mkdir -p ${DOTLOCAL}

    if [[ -f ./attract/attract.cfg ]]; then
        msg="Attract Mode configs already retrieved."
        print_green "${msg}"
    else
        msg="RETRIEVING ATTRACT MODE CONFIG ..."
        print_yellow "${msg}"
        git clone https://github.com/TheCodeTherapy/attract-cfg.git attract
    fi

    home_link "profile/profile" ".profile"
    home_link "bash/bashrc" ".bashrc"
    home_link "bash/inputrc" ".inputrc"
    home_link "x/XCompose" ".XCompose"
    home_link "themes" ".themes"
    home_link "mame" ".mame"
    home_link "darkplaces" ".darkplaces"
    home_link "lutris" ".local/share/lutris"
    home_link "attract" ".attract"
    home_link "vst3" ".vst3"

    home_link_cfg "scummvm"
    home_link_cfg "screenkey"
    home_link_cfg "nvim"
    home_link_cfg "i3"
    home_link_cfg "i3status"
    home_link_cfg "polybar"
    home_link_cfg "alacritty"
    home_link_cfg "picom"
    home_link_cfg "dunst"
}

restore_xorg () {
    sudo cp ${DOTDIR}/x/xorg.conf /etc/X11/xorg.conf
}

fix_cedilla () {
    msg="Fixing cedilla character on XCompose..."
    print_cyan "${msg}"
    mkdir -p $DOTDIR/x
    sed -e 's,\xc4\x86,\xc3\x87,g' -e 's,\xc4\x87,\xc3\xa7,g' \
        < /usr/share/X11/locale/en_US.UTF-8/Compose \
        > $DOTDIR/x/XCompose
    home_link "x/XCompose" ".XCompose"
    sudo cp /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache.bckp
    sudo sed -i 's,"az:ca:co:fr:gv:oc:pt:sq:tr:wa","az:ca:co:fr:gv:oc:pt:sq:tr:wa:en",g' /usr/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache
    sudo cp /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache.bckp
    sudo sed -i 's,"az:ca:co:fr:gv:oc:pt:sq:tr:wa","az:ca:co:fr:gv:oc:pt:sq:tr:wa:en",g' /usr/lib/x86_64-linux-gnu/gtk-2.0/2.10.0/immodules.cache
    sudo cp $DOTDIR/etc/environment /etc/environment
}

make_caps_super () {
    msg="Replacing CAPS key by Super key ..."
    print_yellow "${msg}"
    sudo cp ${DOTDIR}/keyboard/keyboard /etc/default/keyboard
    sudo udevadm trigger --subsystem-match=input --action=change
}

update_system () {
    msg="UPDATING SYSTEM ..."
    print_yellow "${msg}"
    sudo apt --assume-yes update && sudo apt --assume-yes full-upgrade
    sudo apt --assume-yes autoremove
    sudo apt --assume-yes autoclean
    sudo apt --assume-yes install aptitude
}

install_with_aptitude () {
    msg="Installing $1 ..."
    print_yellow "${msg}"
    sudo aptitude -y install $1
}

install_with_snap () {
    if $(locate $1 | grep '/snap/bin' > /dev/null 2>&1); then
        msg="$1 already installed."
        print_green "${msg}"
    else
        msg="Installing $1 ..."
        print_yellow "${msg}"
        sudo snap install $1
    fi
}

install_with_pip () {
    msg="Installing $1 ..."
    print_yellow "${msg}"
    pip install --upgrade $1
}

install_neovim () {
    msg="Building Neovim ..."
    print_yellow "${msg}"
    cd $DOTDIR
    git clone https://github.com/neovim/neovim
    git checkout stable
    cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
    cd $DOTDIR
}

install_basic_packages () {
    msg="INSTALLING BASIC PACKAGES ..."
    mkdir -p ${BINDIR}
    print_yellow "${msg}"
    # sudo killall packagekitd
    sudo add-apt-repository multiverse
    sudo aptitude update
    sudo aptitude -y install mlocate build-essential llvm \
        pkg-config autoconf automake cmake cmake-data \
        ninja-build gettext libtool libtool-bin g++ meson \
        clang clang-tools ca-certificates curl gnupg lsb-release \
        python-is-python3 ipython3 python3-pip python3-dev \
        unzip lzma tree neofetch git git-lfs zsh tmux gnome-tweaks \
        inxi most ttfautohint v4l2loopback-dkms ffmpeg \
        ranger libxext-dev ripgrep python3-pynvim xclip libnotify-bin \
        libfontconfig1-dev libfreetype-dev jq pixz hashdeep liblxc-dev \
        jackd qjackctl ardour pulseaudio-module-jack pipewire pavucontrol \
        libxrandr-dev libxinerama-dev libxcursor-dev libglx-dev libgl-dev \
        screenkey mypaint rofi liferea hexchat gimp blender imagemagick \
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
        python3-setuptools python3-babel python3-dbus \
        fonts-font-awesome slop gir1.2-ayatanaappindicator3-0.1

    sudo updatedb
}

install_vscode () {
    if $(code --version > /dev/null 2>&1); then
        msg="VSCode already installed."
        print_green "${msg}"
    elif $(locate code | grep '/usr/bin/code' | grep -v 'codepage' > /dev/null 2>&1); then
        msg="VSCode already installed."
        print_green "${msg}"
    else
        msg="INSTALLING VSCODE ..."
        print_yellow "${msg}"
        sudo apt --assume-yes install software-properties-common apt-transport-https wget
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        rm -f packages.microsoft.gpg
        sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] \
            https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
        sudo apt --assume-yes update && sudo apt --assume-yes full-upgrade
        sudo apt --assume-yes install code
    fi
}

install_rust () {
    if [[ -f /etc/profile.d/rust.sh ]]; then
        msg="Rust already installed."
        print_green "${msg}"
    else
        msg="INSTALLING RUST ..."
        print_yellow "${msg}"
        wget -qO - https://sh.rustup.rs | sudo RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/rust sh -s -- --no-modify-path -y
        echo 'export RUSTUP_HOME=/opt/rust' | sudo tee -a /etc/profile.d/rust.sh
        echo 'export PATH=$PATH:/opt/rust/bin' | sudo tee -a /etc/profile.d/rust.sh
        source /etc/profile
        source ${ME}/.bashrc
        rustc --version
    fi
}

uninstall_rust () {
    sudo rm -rf /opt/rust
    sudo rm -rf /etc/profile.d/rust.sh
    rm -rf ~/.cargo
}

install_exa () {
    if [[ -f $HOME/.cargo/bin/exa ]]; then
        msg="Exa already installed."
        print_green "${msg}"
    else
        msg="INSTALLING EXA ..."
        print_yellow "${msg}"
        cargo install exa
    fi
}

install_nvm () {
    msg="INSTALLING NVM ..."
    print_yellow "${msg}"
    if [[ -f $NVMDIR/nvm.sh ]]; then
        print_green "nvm already installed."
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    fi
}

install_node () {
    msg="INSTALLING NODEJS ..."
    print_yellow "${msg}"
    if [[ -f $NVMDIR/nvm.sh ]]; then
        if $(npm --version > /dev/null 2>&1); then
            msg="npm already installed."
            print_green "${msg}"
        else
            source $NVMDIR/nvm.sh
            VER=$(nvm ls-remote --lts | grep "Latest" | tail -n 1 | sed 's/[-/a-zA-Z]//g' | sed 's/^[ \t]*//')
            msg="Installing Latest NodeJS version found: ${VER}"
            print_yellow "${msg}"
            nvm install $VER
        fi
    else
        msg="nvm not installed."
        print_red "${msg}"
    fi
}

install_yarn_package () {
    if $(yarn --version > /dev/null 2>&1); then
        msg="Yarn already installed."
        print_green "${msg}"
    else
        msg="Installing Yarn package..."
        print_yellow "${msg}"
        sudo apt update && sudo apt -y install yarn
    fi
}

install_yarn () {
    msg="Installing Yarn..."
    print_yellow "${msg}"
    if [[ -f /etc/apt/trusted.gpg.d/yarn.gpg ]]; then
        msg="Yarn GPG key already added to system."
        print_green "${msg}"
    else
        msg="Adding Yarn GPG key to system..."
        print_yellow "${msg}"
        curl https://dl.yarnpkg.com/debian/pubkey.gpg \
            | gpg --dearmor \
            | sudo tee /etc/apt/trusted.gpg.d/yarn.gpg > /dev/null
    fi
    if [[ -f /etc/apt/sources.list.d/yarn.list ]]; then
        msg="Yarn sources list already added to system."
        print_green "${msg}"
        install_yarn_package
    else
        msg="Adding yarn.list to sources.list.d..."
        print_yellow "${msg}"
        echo "deb https://dl.yarnpkg.com/debian/ stable main" \
            | sudo tee /etc/apt/sources.list.d/yarn.list
        install_yarn_package
    fi
}

install_docker () {
    if $(docker --version > /dev/null 2>&1); then
        msg="Docker already installed."
        print_green "${msg}"
    else
        msg="INSTALLING DOCKER ..."
        print_yellow "${msg}"
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo aptitude -y update
        sudo aptitude -y install docker-ce docker-ce-cli containerd.io
        sudo updatedb
        sudo usermod -a -G docker $USER
    fi
}

install_docker_compose () {
    if $(docker-compose --version > /dev/null 2>&1); then
        msg="Docker-compose already installed."
        print_green "${msg}"
    else
        msg="INSTALLING DOCKER-COMPOSE ..."
        print_yellow "${msg}"
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

install_obs_studio () {
    PPA=`ls /etc/apt/sources.list.d/obs* 2>/dev/null | wc -l`
    if [ $PPA != 0 ]; then
        msg="OBS Studio PPA already configured."
        print_green "${msg}"
    else
        sudo add-apt-repository -y ppa:obsproject/obs-studio
        sudo apt update
    fi
    if $(obs --version > /dev/null 2>&1); then
        msg="OBS Studio alteady installed."
        print_green "${msg}"
    else
        install_with_aptitude obs-studio
    fi
}

install_extra_packages () {
    msg="INSTALLING EXTRA PACKAGES ..."
    print_yellow "${msg}"
    if $(cat /etc/os-release | head -n 1 | grep "Pop" > /dev/null 2>&1); then
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

install_fd () {
    if $(fd --version > /dev/null 2>&1); then
        msg="fd already installed."
        print_green "${msg}"
    else
        msg="Installing fd package..."
        print_yellow "${msg}"
        cargo install fd-find
    fi
}

setup_fonts () {
    msg="SETTING UP FONTS ..."
    print_yellow "${msg}"
    rm -rf $ME/.fonts > /dev/null 2>&1 \
        && ln -s $DOTDIR/fonts $ME/.fonts \
        || ln -s $DOTDIR/fonts $ME/.fonts
    fc-cache -f
}

install_i3 () {
    msg="Building i3-wm ..."
    print_yellow "${msg}"
    cd $DOTDIR
    mkdir -p build
    git clone https://github.com/i3/i3 build/i3
    cd build/i3
    mkdir -p build && cd build
    meson -Ddocs=true -Dmans=true ..
    ninja
    sudo ninja install
    cd $DOTDIR
}

install_i3_status () {
    msg="Building i3-status ..."
    print_yellow "${msg}"
    cd $DOTDIR
    mkdir -p build
    git clone https://github.com/i3/i3status build/i3status
    cd build/i3status
    mkdir -p build && cd build
    meson ..
    ninja
    sudo ninja install
    cd $DOTDIR
}

install_picom () {
    msg="Building picom ..."
    print_yellow "${msg}"
    cd $DOTDIR
    mkdir -p build
    git clone https://github.com/yshui/picom.git build/picom
    cd build/picom
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
    cd $DOTDIR
}

install_polybar () {
    msg="Building polybar ..."
    print_yellow "${msg}"
    cd $DOTDIR
    mkdir -p build
    git clone --recursive https://github.com/polybar/polybar build/polybar
    cd build/polybar
    mkdir -p build && cd build
    cmake ..
    make -j$(nproc)
    sudo make install
    cd $DOTDIR
}

install_alacritty () {
    msg="Building alacritty ..."
    print_yellow "${msg}"
    cargo install alacritty
}

customize_vscode () {
    msg="Customizing vscode ..."
    print_yellow "${msg}"
    sudo rm -rf ${CFG}/Code/User/settings.json > /dev/null 2>&1 \
        && ln -s ${DOTDIR}/vscode/settings.json ${CFG}/Code/User/settings.json \
        || ln -s ${DOTDIR}/vscode/settings.json ${CFG}/Code/User/settings.json
}

install_reaper () {
    if [[ -f $ME/.gnome/apps/cockos-reaper.desktop ]]; then
        msg="Reaper already installed."
        print_green "${msg}"
    else
        msg="Installing Reaper ..."
        print_yellow "${msg}"
        cd $DOTDIR/software
        tar -xf reaper707_linux_x86_64.tar.xz
        cd $DOTDIR/software/reaper_linux_x86_64
        ./install-reaper.sh --integrate-user-desktop
        cd $DOTDIR
    fi
}

install_opera () {
    if $(opera --version > /dev/null 2>&1); then
        msg="Opera already installed."
        print_green "${msg}"
    else
        msg="Installing Opera ..."
        print_yellow "${msg}"
        wget -O- https://deb.opera.com/archive.key \
            | sudo gpg --dearmor \
            | sudo tee /usr/share/keyrings/opera.gpg
        echo deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free \
            | sudo tee /etc/apt/sources.list.d/opera.list
        sudo apt --assume-yes update
        sudo apt --assume-yes install opera-stable
    fi
}

update_system
# choose_fastest_mirror
# protect_hosts

install_basic_packages
install_extra_packages
make_caps_super

link_dotfiles

install_nvm
install_node
install_yarn
install_rust
install_exa

install_docker
install_docker_compose
install_fd
setup_fonts
install_with_pip PyOpenGL
install_with_pip numpy

# install_neovim

install_i3
install_i3_status
install_picom
install_polybar
install_alacritty
restore_xorg

customize_vscode

install_reaper
install_opera

source ${ME}/.bashrc
sudo updatedb

msg="CONFIG COMPLETE"
print_cyan "${msg}"

# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# chsh -s $(which zsh)
#
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
# echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
# p10k configure

# sudo apt install jackd qjackctl pulseaudio-module-jack
# pactl load-module module-jack-sink client_name=discord_sink connect=no
# pactl load-module module-jack-source client_name=discord_source connect=no
