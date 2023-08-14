#!/usr/bin/fish

# Update
set_color ECEB7B; echo "[Update package and install latest keyring]"; set_color normal
sudo pacman -Sy
sudo pacman -S --needed archlinux-keyring

# Install xorg
set_color ECEB7B; echo "[Install xorg]"; set_color normal
sudo pacman -S --needed xorg

# Install kde plasma
set_color ECEB7B; echo "[Install plasma workplace and some handly KDE appliactions]"; set_color normal
sudo pacman -S --needed sddm plasma plasma-wayland-session
sudo pacman -S --needed konsole dolphin kwallet kwalletmanager kate spectacle kdeconnect elisa gwenview ark partitionmanager

# Install other appliactions
set_color ECEB7B; echo "[Install some GUI appliactions, some CLI appliactions, some cool stuffs, etc]"; set_color normal
sudo pacman -S --needed firefox kitty flatpak \
    htop wget curl git openssh neofetch lsb-release neovim vim gamemode \
    pipewire pipewire-pulse lib32-pipewire wireplumber \
    discord steam-native-runtime piper

# Install development tools
set_color ECEB7B; echo "[Install development tools]"; set_color normal
sudo pacman -S --needed python python-pip base-devel rustup

# Install fonts
set_color ECEB7B; echo "[Install some good nerdfonts]"; set_color normal
sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd

# Install fcitx5
set_color ECEB7B; echo "[Install fcitx5]"; set_color normal
sudo pacman -S --noconfirm --needed fcitx5 kcm-fcitx5 fcitx5-bamboo fcitx5-im
echo "GTK_IM_MODULE=fcitx"  | sudo tee -a /etc/environment
echo "QT_IM_MODULE=fcitx"   | sudo tee -a /etc/environment
echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment

# Install bluetooth
set_color ECEB7B; echo "[Install bluetooth service]"; set_color normal
echo "Do you wanna install bluetooth? [y/N]"
read answer
if test "$answer" = "Y" -o "$answer" = "y"
    sudo pacman -S --needed bluez bluez-utils
    systemctl enable --now bluetooth
end

# Check if yay is available
set_color ECEB7B; echo "[Check yay available]"; set_color normal
if not command -sq yay
    # Ask the user for confirmation
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

# Install nvchad
echo "Do you wanna install NvChad??? [y/N]"
read answer
if test "$answer" = "Y" -o "$answer" = "y"
    git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
end
