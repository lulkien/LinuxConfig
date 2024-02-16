#!/usr/bin/env bash

# Set alacritty as default terminal for nemo
gsettings set org.cinnamon.desktop.default-applications.terminal exec alacritty

# Set nemo as default file manager
xdg-mime default nemo.desktop inode/directory

