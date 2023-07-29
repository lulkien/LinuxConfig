#!/usr/bin/fish

echo "Clone configurations"
cd ~/.config
# fish shell
rm -r ~/.config/fish
git clone https://github.com/QSingularisRicer/fish.git ~/.config/fish --depth 1
