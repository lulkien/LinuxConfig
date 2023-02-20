#!/usr/bin/fish

# Enable Network
sudo systemctl enable --now NetworkManager

# Update package
sudo pacman -Syy
sudo pacman -S archlinux-keyring

# Plasma installation
sudo pacman -S --needed xorg plasma dolphin konsole partitionmanager kwalletmanager spectacle

# Font installation
sudo pacman -S --needed ttf-liberation noto-fonts-cjk

# App installation
sudo pacman -S --needed fish git vim alacritty vlc htop neofetch unzip 

# Some services
sudo pacman -S --needed openssh blueman bluez ibus

# Enable services
sudo systemctl enable --now sshd
sudo systemctl enable --now bluetooth

# Install yay
cd
mkdir Packages
cd Packages
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install ibus-bamboo
yay -S ibus-bamboo
