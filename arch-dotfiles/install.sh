#!/bin/bash

# Install package
#pacman -Sy fish git neovim

rm -r ~/.config/fish
cp -r fish ~/.config

rm -r ~/.config/kitty/
cp -r kitty ~/.config

#rm -rf ~/.config/nvim
#rm -rf ~/.local/share/nvim
#git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
