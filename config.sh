#!/bin/bash
#set -eu -o pipefail

#=============================================================================
# @MarcoGomezGT - https://mgz.me
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
        git clone https://github.com/MarcoGomezGT/attract-cfg.git attract
    fi

    home_link "bash/bashrc" ".bashrc"
    home_link "bash/inputrc" ".inputrc"
    home_link "x/XCompose" ".XCompose"
    home_link "themes" ".themes"
    home_link "mame" ".mame"
    home_link "darkplaces" ".darkplaces"
    home_link "lutris" ".local/share/lutris"
    home_link "attract" ".attract"

    home_link_cfg "scummvm"
    home_link_cfg "screenkey"
    home_link_cfg "nvim"
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
    sudo -H pip install --upgrade $1
}

install_neovim () {
    NVPPA=`ls /etc/apt/sources.list.d/neovim-ppa-ubuntu-unstable* 2>/dev/null | wc -l`
    if [ $NVPPA != 0 ]; then
        msg="Neovim unstable PPA already configured."
        print_green "${msg}"
    else
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        sudo apt update
    fi
    install_with_aptitude neovim
}

install_basic_packages () {
    msg="INSTALLING BASIC PACKAGES ..."
    mkdir -p ${BINDIR}
    print_yellow "${msg}"
    sudo killall packagekitd
    sudo add-apt-repository multiverse
    sudo aptitude update
    sudo aptitude -y install mlocate build-essential llvm \
        pkg-config autoconf automake cmake cmake-data \
        clang clang-tools ca-certificates curl gnupg lsb-release \
        python-is-python3 ipython3 python3-pip python3-dev \
        unzip lzma tree neofetch git zsh tmux gnome-tweaks \
        inxi most ttfautohint v4l2loopback-dkms ffmpeg \
        ranger libxext-dev ripgrep python3-pynvim xclip libnotify-bin \
        libfontconfig1-dev libfreetype-dev jq pixz hashdeep liblxc-dev \
        screenkey mypaint rofi liferea hexchat gimp blender imagemagick
    install_neovim
    install_with_pip ueberzug
    install_with_pip neovim-remote
    install_with_pip PyOpenGL
    install_with_pip numpy
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
        wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
        sudo add-apt-repository -y "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
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
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
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
        sudo flatpak -y install org.telegram.desktop
        sudo flatpak -y install com.spotify.Client
        sudo flatpak -y install com.discordapp.Discord
    else
        install_with_snap telegram-desktop
        install_with_snap discord
        install_with_snap starship
        install_with_snap kdiskmark
        install_with_snap spotify
    fi
    install_with_pip youtube-dl
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

update_system
# choose_fastest_mirror
# protect_hosts

install_basic_packages
install_extra_packages
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
setup_fzf

source ${ME}/.bashrc
curl -sS https://starship.rs/install.sh | sh
sudo updatedb

msg="CONFIG COMPLETE"
print_cyan "${msg}"
