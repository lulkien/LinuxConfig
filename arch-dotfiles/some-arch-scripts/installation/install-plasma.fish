#!/usr/bin/fish

# Update
sudo pacman -Sy
sudo pacman -S --needed archlinux-keyring

# Install xorg
sudo pacman -S --needed xorg

# Install kde plasma
sudo pacman -S --needed plasma plasma-wayland-session sddm 
sudo pacman -S --needed konsole dolphin kwallet kwalletmanager kate spectacle kdeconnect elisa gwenview ark partitionmanager

# Install other appliactions
sudo pacman -S --needed firefox htop curl wget pipewire pipewire-pulse lib32-pipewire wireplumber flatpak git base-devel openssh neofetch htop kitty

# Install fonts
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd

# Install fcitx5
sudo pacman -S --noconfirm --needed fcitx5 kcm-fcitx5 fcitx5-bamboo fcitx5-im

# Install bluetooth
sudo pacman -S --needed bluez bluez-utils
#systemctl enable --now bluetooth

# Check if yay is available
if not command -sq yay
    # Ask the user for confirmation
    echo 'yay is not installed. Do you want to install it? [Y/n]'
    read answer
    # If the answer is yes or empty, install yay
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        # Install yay using pacman
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si
    end
end
