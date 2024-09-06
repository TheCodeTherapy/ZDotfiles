#!/bin/bash

# Define configuration variables
ME="/home/$(whoami)"
export ME
export DOTDIR="${ME}/ZDotfiles"
export DOTDOT="${DOTDIR}/dotfiles"

export BINDIR="${DOTDIR}/bin"
export SCRIPTS="${DOTDIR}/scripts"
export SETUPSCRIPTS="${DOTDIR}/z_setup_scripts"

export NVMDIR="${ME}/.nvm"
export DOTLOCAL="${ME}/.local"
export CFG="$ME/.config"
export GAMES="$ME/Games"

export HOSTSBACKUP=/etc/hosts.bak
export HOSTSDENYBACKUP=/etc/hostsdeny.bak
export HOSTSSECURED="${DOTDIR}/hostssecured"

# Create necessary directories
mkdir -p "$ME/Storage/NAS/volume1/"
mkdir -p "${DOTLOCAL}"
mkdir -p "${ME}/.local/share/applications"
