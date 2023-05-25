#!/usr/bin/fish

echo "Clone configurations"
cd ~/.config
# kitty
rm -r ~/.config/kitty
git clone git@github.com:QSingularisRicer/kitty.git

# waybar
rm -r ~/.config/waybar
git clone git@github.com:QSingularisRicer/waybar.git

# sway
rm -r ~/.config/sway
git clone git@github.com:QSingularisRicer/sway

# fish shell
rm -r ~/.config/fish
git clone git@github.com:QSingularisRicer/fish.git
