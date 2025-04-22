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

- adguard-create-system-user.sh

  I don't want to run AdGuardHome as root, so I create a user with minimum privilege for it.

- adguard-update.sh

  A script to update AdGuardHome

- install-stuffs.sh

  This script will install: apt-fast, fishshell, neovim, nftables and a few handy tools.
  It will remove ufw and iptables.

- ssh-create-tunnel-user.sh

  Create an user to allow other machine create a ssh reverse tunnel.

- wireguard-create-client.sh

  Script to create a new wireguard client and export config.

- wireguard-installer.sh

  Ye, for installing wireguard and some nftables rules.

### A few other things

- Windows Terminal configuration
- Commonly used clang-format
- And some random things
  

## Usage

Clone this repository and run the script you want.

## Disclaimer

**Note: Before using any of the provided scripts, please ensure to review their contents. 
While efforts have been made to keep the scripts concise and straightforward, it is essential 
to understand the actions they perform on your system. Use these scripts at your own risk, and 
make sure they align with your system configuration and requirements. The author is not responsible 
for any unintended consequences or issues that may arise from the use of these scripts. Always 
exercise caution and verify the scripts' content before execution.**

Thank you for your understanding.
