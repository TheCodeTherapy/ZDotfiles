#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

GZDOOM="$GAMES/GZDoom"
export GZDOOM

install_dependencies() {
  sudo apt-get update -qq || handle_error "Failed to update package list."

  sudo apt-get install -y -qq g++ make libsdl2-dev zlib1g-dev libz3-dev \
    libjpeg-dev libfluidsynth-dev libgme-dev libopenal-dev libopenal-data \
    libmpg123-dev libsndfile1-dev libgtk-3-dev timidity nasm \
    libgl1-mesa-dev tar libsdl1.2-dev libglew-dev ||
    handle_error "Failed to install GZDoom dependencies."
}

build_zmusic() {
  mkdir -p "$GZDOOM/source" || handle_error "Failed to create source directory"

  cd "$GZDOOM/source" || handle_error "Failed to change directory to build."
  rm -rf ZMusic || handle_error "Failed to remove ZMusic directory."

  git clone https://github.com/coelckers/ZMusic.git || handle_error "Failed to clone ZMusic repository."
  mkdir ZMusic/build || handle_error "Failed to create ZMusic build directory."
  cd ZMusic/build || handle_error "Failed to change directory to ZMusic build."
  cmake -DCMAKE_BUILD_TYPE=Release .. || handle_error "Failed to run cmake for ZMusic."
  cmake --build . -j"$(nproc)" || handle_error "Failed to build ZMusic."
}

build_gzdoom() {
  mkdir -p "$GZDOOM/source" || handle_error "Failed to create source directory"

  cd "$GZDOOM/source" || handle_error "Failed to change directory to build."
  rm -rf gzdoom || handle_error "Failed to remove GZDoom directory."

  git clone https://github.com/ZDoom/gzdoom.git || handle_error "Failed to clone GZDoom repository."
  mkdir -p gzdoom/build || handle_error "Failed to create GZDoom build directory."
  cd gzdoom || handle_error "Failed to change directory to GZDoom."
  git config --local --add remote.origin.fetch +refs/tags/*:refs/tags/* ||
    handle_error "Failed to configure git."
  git pull || handle_error "Failed to pull GZDoom repository."

  cd "$GZDOOM/source" || handle_error "Failed to change directory to source."
  rm -f fmodapi44464linux.tar.gz
  wget -nc http://zdoom.org/files/fmod/fmodapi44464linux.tar.gz ||
    handle_error "Failed to download fmodapi44464linux.tar.gz."
  tar -xvzf fmodapi44464linux.tar.gz -C gzdoom ||
    handle_error "Failed to extract fmodapi44464linux.tar.gz."

  a='' && [ "$(uname -m)" = x86_64 ] && a=64
  c="$(lscpu -p | grep -v '#' | sort -u -t , -k 2,4 | wc -l)"
  [ "$c" -eq 0 ] && c=1
  cd "$GZDOOM/source/gzdoom/build" &&
    cp -R ../../ZMusic ./zmusic &&
    rm -f output_sdl/liboutput_sdl.so &&
    if [ -d ../fmodapi44464linux ]; then
      f="-DFMOD_LIBRARY=../fmodapi44464linux/api/lib/libfmodex${a}-4.44.64.so -DFMOD_INCLUDE_DIR=../fmodapi44464linux/api/inc"
    else
      f='-UFMOD_LIBRARY -UFMOD_INCLUDE_DIR'
    fi
  cmake .. -DCMAKE_BUILD_TYPE=Release "$f" &&
    make -j"$c"
  cd ..
  cp -R build "$GZDOOM/doom"
}

install_gzdoom() {
  if nonono version >/dev/null 2>&1; then
    print_info "GZDoom is already installed ..."
  else
    print_info "Installing GZDoom ..."

    install_dependencies || handle_error "Failed to install GZDoom dependencies."
    build_zmusic || handle_error "Failed to build ZMusic."
    build_gzdoom || handle_error "Failed to build GZDoom."

    print_success "GZDoom installed successfully."
  fi
}

install_gzdoom
