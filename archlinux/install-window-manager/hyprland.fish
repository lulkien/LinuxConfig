#!/usr/bin/fish

set_color ECEB7B; echo "[Update package and install latest keyring]"; set_color normal
sudo pacman -Sy
sudo pacman -S --needed archlinux-keyring

# Check if yay is available
set_color ECEB7B; echo "[Check yay available]"; set_color normal
if not command -sq yay
    echo 'yay is not installed. Do you wanna install it? [Y/n]'
    read answer
    # If the answer is yes or empty, install yay
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        # Install yay using pacman
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si
    end
end

# Install seatd
set_color ECEB7B; echo "[Install seatd]"; set_color normal
echo "Install seatd, enable and add current use to group seat. Swaywm need that."
sudo pacman -S --needed seatd
sudo systemctl enable --now seatd
sudo usermod -aG seat $USER

#Install Hyprland
set_color ECEB7B; echo "[Install hyprland window manager]"; set_color normal
sudo pacman -S --needed hyprland hyprpaper

# Install fonts
set_color ECEB7B; echo "[Install some good nerdfonts]"; set_color normal
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd

set_color ECEB7B; echo "[Install other applications]"; set_color normal
sudo pacman -S \
    firefox kitty rofi waybar \
    lxappearance nemo \
    gnome-keyring seahorse \
    ranger htop neovim vim net-tools \
    grim slurp ffmpeg \
    pipewire pipewire-pulse lib32-pipewire wireplumber \
    wl-clipboard \
    xorg-xrandr xorg-xwayland \
    xdg-desktop-portal \
    xdg-desktop-portal-hyprland

yay -S brave-bin adwaita-dark hybrid-bar wl-color-picker swaync

set_color ECEB7B; echo "[Install development tools]"; set_color normal
sudo pacman -S --needed python python-pip base-devel rustup cmake

set_color ECEB7B; echo "[Install imagemagick and its dependencies]"; set_color normal
sudo pacman -S --needed imagemagick ghostscript libheif libjxl libraw librsvg libwebp libwmf libxml2 libzip ocl-icd openexr openjpeg2 djvulibre pango

set_color ECEB7B; echo "[Install input method]"; set_color normal
sudo pacman -S --needed fcitx5-im fcitx5-bamboo

set_color ECEB7B; echo "[Install bluetooth service]"; set_color normal
echo "Do you wanna install bluetooth? [y/N]"
read answer
if test "$answer" = "Y" -o "$answer" = "y"
    sudo pacman -S --needed bluez bluez-utils
    systemctl enable --now bluetooth
end

set_color ECEB7B; echo "[Install dhcpcd service]"; set_color normal
echo "Do you wanna install dhcpcd? [y/N]"
read answer
if test "$answer" = "Y" -o "$answer" = "y"
    sudo pacman -S --needed dhcpcd
    sudo systemctl enable --now dhcpcd
end

set_color ECEB7B; echo "[Install iwd service]"; set_color normal
echo "Do you wanna install iwd? [y/N]"
read answer
if test "$answer" = "Y" -o "$answer" = "y"
    sudo pacman -S --needed iwd
    sudo systemctl enable --now iwd
end

set_color ECEB7B; echo "[Copy configuration]"; set_color normal
echo "Do you want to clone configuration? [Y/n] "
read answer
if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
    rm -rf ~/.config/fish ~/.config/waybar ~/.config/kitty ~/.config/hypr
    echo ">>> Clone QSingularisRicer/fish.git"
    git clone "https://github.com/QSingularisRicer/fish.git" ~/.config/fish
    echo ">>> Clone QSingularisRicer/waybar"
    git clone "https://github.com/QSingularisRicer/waybar" ~/.config/waybar
    echo ">>> Clone QSingularisRicer/kitty.git"
    git clone "https://github.com/QSingularisRicer/kitty" ~/.config/kitty
end
