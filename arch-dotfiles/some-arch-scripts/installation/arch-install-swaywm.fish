#!/usr/bin/fish

echo "Update database"
sudo pacman -Sy

echo "Install seatd"
sudo pacman -S --needed seatd
echo "Enable seatd"
sudo systemctl enable --now seatd
echo "Please add user to group seat"

echo "Install sway"
sudo pacman -S --needed sway swayidle swaybg

echo "Install fonts"
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd

echo "Install audio controller"
sudo pacman -S --needed pamixer

echo "Install ranger and optional"
sudo pacman -S --needed ranger

echo "Install credentials manager"
sudo pacman -S --needed gnome-keyring seahorse

echo "Install services and applications"
sudo pacman -S --needed kitty rofi ffmpeg grim python python-pip bluez bluez-utils htop dhcpcd iwd firefox neovim xorg-xrandr xorg-xwayland

echo "Install imagemagick and its dependencies"
sudo pacman -S --needed imagemagick ghostscript libheif libjxl libraw librsvg libwebp libwmf libxml2 libzip ocl-icd openexr openjpeg2 djvulibre pango

echo "Enable services"
sudo systemctl enable --now dhcpcd
sudo systemctl enable --now bluetooth

echo "Install xdg-desktop-portal (base and wlr)"
sudo pacman -S --needed xdg-desktop-portal xdg-desktop-portal-wlr

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
