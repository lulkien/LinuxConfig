#!/usr/bin/fish

echo "Clone configurations"
cd ~/.config
# kitty
rm -r ~/.config/kitty
git clone https://github.com/QSingularisRicer/kitty.git ~/.config/kitty --depth 1

# waybar
rm -r ~/.config/waybar
git clone https://github.com/QSingularisRicer/waybar.git ~/.config/waybar --depth 1

# sway
rm -r ~/.config/sway
git clone https://github.com/QSingularisRicer/sway.git ~/.config/sway --depth 1

# fish shell
rm -r ~/.config/fish
git clone https://github.com/QSingularisRicer/fish.git ~/.config/sway --depth 1
