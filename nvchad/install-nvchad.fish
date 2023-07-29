#!/usr/bin/fish

# Remove old nchad if possible
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim

# Clone new nvchad
 git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
