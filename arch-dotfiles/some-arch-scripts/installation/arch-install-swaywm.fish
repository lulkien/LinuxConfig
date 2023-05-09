#!/usr/bin/fish

echo "Update database"
sudo pacman -Sy

echo "Install seatd"
sudo pacman -S seatd
echo "Enable seatd"
sudo systemctl enable --now seatd
echo "Please add user to group seat"

echo "Install sway"
sudo pacman -S sway swayidle swaybg

echo "Install fonts"
sudo pacman -S ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji

echo "Install audio controller"
sudo pacman -S pamixer

echo "Install ranger and optional"
sudo pacman -S ranger

echo "Install credentials manager"
sudo pacman -S gnome-keyring seahorse

echo "Install services and applications"
sudo pacman -S kitty rofi python python-pip bluez bluez-utils htop dhcpcd iwd firefox neovim xorg-xrandr xorg-xwayland
echo "Enable services"
sudo systemctl enable --now dhcpcd
sudo systemctl enable --now bluetooth

echo "Clone configurations"
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
