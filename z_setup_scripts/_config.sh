#!/bin/bash

# Define configuration variables
ME="/home/$(whoami)"
export ME
export DOTDIR="${ME}/ZDotfiles"
export DOTDOT="${DOTDIR}/dotfiles"
export NVMDIR="${ME}/.nvm"
export DOTLOCAL="${ME}/.local"
export BINDIR="${DOTDIR}/bin"
export CFG="$ME/.config"
export HOSTSBACKUP=/etc/hosts.bak
export HOSTSDENYBACKUP=/etc/hostsdeny.bak
export HOSTSSECURED="${DOTDIR}/hostssecured"

# Create necessary directories
mkdir -p "$ME/Storage/NAS/volume1/"
mkdir -p "${DOTLOCAL}"
mkdir -p "${ME}/.local/share/applications"
