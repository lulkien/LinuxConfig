# LinuxConfig

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](http://unlicense.org/)

A bunch of scripts to do various things.

## Table of scripts

### ArchLinux

Install graphic drivers:
  - Intel
  - AMD
  - Nvdia (WIP, not recommend to use)

Install desktop environments:
  - Hyprland
  - KDE Plasma
  - Minimal setup

### NixOS

Just a default configuration to enable some handy services and tools for my homelab.
Use as a reference, you should create a private config for yourself.

### Ubuntu Server

A few scripts to do some repeated work when setup a new ubuntu server.

#### adguard-update.sh

  A script to update AdGuardHome.

#### install-stuffs.sh

  This script will install: apt-fast, fishshell, neovim, nftables and a few handy tools.
  It will also remove ufw and iptables, because of we are going to use nftables.

#### ssh-create-tunnel-user.sh

  Create an user to allow other machine create a ssh reverse tunnel.

#### wireguard-create-client.sh

  Script to create a new WireGuard client and export its configuration.

#### wireguard-installer.sh

  Like its name, installing WireGuard and some nftables rules.

### A few other things

- Windows Terminal configuration
- Commonly used clang-format
- And some random things
  

## Usage

Clone this repository and run the script you want.

## Disclaimer

**Kindly take a moment, read through any of the scripts carefully before executing them.
While the script can be called short and simple, a nearby understanding of its behavior
and what it does to your system is a requisite. Use these scripts at your own risk.
In every case, be extra careful and check through any script before running it.**

