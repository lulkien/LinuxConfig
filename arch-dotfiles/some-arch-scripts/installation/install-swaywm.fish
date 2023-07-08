#!/usr/bin/fish

echo "Update pacman database"
sudo pacman -Sy
sudo pacman -S --needed archlinux-keyring

# Check if yay is available
if not command -sq yay
    # Ask the user for confirmation
    read -p "yay is not installed. Do you want to install it? [Y/n] " answer
    # If the answer is yes or empty, install yay
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        # Install yay using pacman
        sudo pacman -S --needed git base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si
    end
end

echo "Install seatd, enable and add current use to group seat. Swaywm need that."
sudo pacman -S --needed seatd
sudo systemctl enable --now seatd
sudo usermod -aG seat $USER

echo "Install Swaywm and sway related packages"
# sway
# swayidle
# swaybg
# swaylock-effects
sudo pacman -S --needed sway swayidle swaybg
yay -S swaylock-effects

echo "Install nerdfonts for better icons"
# ttf-jetbrains-mono-nerd
# ttf-liberation
# noto-fonts-cjk
# noto-fonts-emoji
# otf-codenewroman-nerd
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd

echo "Install pipewire and pipewire session manager"
# pipewire
# pipewire-pulse
# wireplumber
# lib32-pipewire
sudo pacman -S --needed pipewire pipewire-pulse lib32-pipewire wireplumber

echo "Install ranger files manager"
# ranger
sudo pacman -S --needed ranger

echo "Install credentials manager"
# gnome-keyring
# seahorse
sudo pacman -S --needed gnome-keyring seahorse

echo "Install other applications and services"
sudo pacman -S --needed \
    kitty rofi ffmpeg python \
    python-pip bluez bluez-utils \
    htop dhcpcd iwd firefox neovim \
    xorg-xrandr xorg-xwayland lxappearance \
    wl-color-picker grim slurp net-tools

echo "Install imagemagick and its dependencies"
sudo pacman -S --needed imagemagick ghostscript libheif libjxl libraw librsvg libwebp libwmf libxml2 libzip ocl-icd openexr openjpeg2 djvulibre pango

echo "Install input method"
# fcitx5-im
# fcitx5-bamboo
sudo pacman -S --needed fcitx5-im fcitx5-bamboo

echo "Enable services"
sudo systemctl enable --now dhcpcd
sudo systemctl enable --now bluetooth

echo "Install xdg-desktop-portal (base and wlr)"
sudo pacman -S --needed xdg-desktop-portal xdg-desktop-portal-wlr

read -p "Do you want to clone configuration? [Y/n] " answer
if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
    read -p "Using SSH? [Y/n] " answer
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        echo "Clone QSingularisRicer/fish.git"
        git clone "git@github.com:QSingularisRicer/fish.git" ~/.config/fish
        echo "Clone QSingularisRicer/sway.git"
        git clone "git@github.com:QSingularisRicer/sway.git" ~/.config/sway
        echo "Clone QSingularisRicer/swaylock.git"
        git clone "git@github.com:QSingularisRicer/swaylock.git" ~/.config/swaylock
        echo "Clone QSingularisRicer/waybar"
        git clone "git@github.com:QSingularisRicer/waybar.git" ~/.config/waybar
        echo "Clone QSingularisRicer/kitty.git"
        git clone "git@github.com:QSingularisRicer/kitty.git" ~/.config/kitty
    else
        # do other things
    end
end
