#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_helpers.sh"
source "$SCRIPT_DIR/_config.sh"

EMSCRIPTENPATH="$HOME/.emsdk"
export EMSCRIPTENPATH=$EMSCRIPTENPATH

install_emscripten() {
  if [[ -d $EMSCRIPTENPATH ]]; then
    print_info "Emscripten source already cloned. Updating ..."

    cd $EMSCRIPTENPATH || handle_error "Failed to change directory to $EMSCRIPTENPATH"

    git pull || handle_error "Failed to pull Emscripten source"

    ./emsdk install latest || handle_error "Failed to install Emscripten"

    ./emsdk activate latest || handle_error "Failed to activate Emscripten"

    export PATH=$PATH:$EMSCRIPTENPATH
    if [ -d "$EMSCRIPTENPATH/upstream/emscripten" ]; then
      export PATH=$PATH:$EMSCRIPTENPATH/upstream/emscripten
    fi

    source $EMSCRIPTENPATH/emsdk_env.sh || handle_error "Failed to source emsdk_env.sh"

    print_success "Emscripten updated successfully."
  else
    print_info "Cloning Emscripten source ..."

    cd "$HOME" || handle_error "Failed to change directory to $HOME"

    git clone https://github.com/emscripten-core/emsdk.git $EMSCRIPTENPATH || handle_error "Failed to clone Emscripten source"

    cd $EMSCRIPTENPATH || handle_error "Failed to change directory to $EMSCRIPTENPATH"

    git pull || handle_error "Failed to pull Emscripten source"

    ./emsdk install latest || handle_error "Failed to install Emscripten"

    ./emsdk activate latest || handle_error "Failed to activate Emscripten"

    export PATH=$PATH:$EMSCRIPTENPATH
    if [ -d "$EMSCRIPTENPATH/upstream/emscripten" ]; then
      export PATH=$PATH:$EMSCRIPTENPATH/upstream/emscripten
    fi

    source $EMSCRIPTENPATH/emsdk_env.sh || handle_error "Failed to source emsdk_env.sh"

    print_success "Emscripten installed successfully."
  fi
}

install_emscripten
