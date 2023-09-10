#!/usr/bin/fish

function prepare_keyring
    set_color ECEB7B; echo "[Update package and install latest keyring]"; set_color normal
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
end

function install_aur_helper
    set_color ECEB7B; echo "[Check yay available]"; set_color normal
    sudo pacman -S --needed go
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
end

function install_desktop_environment
    set_color ECEB7B; echo "[Install seatd]"; set_color normal
    echo "Install seatd, enable and add current use to group seat. Swaywm need that."
    sudo pacman -S --needed seatd
    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    set_color ECEB7B; echo "[Install hyprland window manager]"; set_color normal
    sudo pacman -S --needed xorg-xwayland hyprland hyprpaper
    yay -S swaylock-effects
end

function install_misc
    set_color ECEB7B; echo "[Install fonts]"; set_color normal
    sudo pacman -S --needed \
        ttf-jetbrains-mono-nerd \
        ttf-liberation \
        noto-fonts-cjk \
        noto-fonts-emoji \
        otf-codenewroman-nerd

    set_color ECEB7B; echo "[Install other applications]"; set_color normal
    sudo pacman -S \
        fish git vim neovim kitty \
        breeze breeze-gtk \
        wofi waybar \
        unzip unarchiver \
        firefox flatpak \
        nemo gnome-keyring seahorse polkit-gnome \
        htop neofetch lsb-release \
        wget curl openssh rsync \
        grim slurp ffmpeg \
        wl-clipboard xorg-xrandr \
        pipewire pipewire-pulse lib32-pipewire wireplumber \
        xdg-desktop-portal xdg-desktop-portal-hyprland

    set_color ECEB7B; echo "[Install fcitx5]"; set_color normal
    sudo pacman -S --needed fcitx5-im fcitx5-bamboo

    set_color ECEB7B; echo "[Install development tools]"; set_color normal
    sudo pacman -S --needed python python-pip base-devel rustup npm
    sudo pacman -S --needed dbus-python python-gobject

    yay -S brave-bin nwg-look-bin swaync hyprpicker eww
end

function enable_services
    set_color ECEB7B; echo "[Install network service]"; set_color normal
    sudo pacman -S --needed dhcpcd networkmanager nm-connection-editor
    sudo systemctl enable --now dhcpcd
    sudo systemctl enable --now NetworkManager

    set_color ECEB7B; echo "[Install bluetooth service]"; set_color normal
    echo "Do you wanna install bluetooth? [y/N]"
    read answer
    if test "$answer" = "Y" -o "$answer" = "y"
        sudo pacman -S --needed bluez bluez-utils blueman
        systemctl enable --now bluetooth
    end

    set_color ECEB7B; echo "[Install iwd service]"; set_color normal
    echo "Do you wanna install iwd? [y/N]"
    read answer
    if test "$answer" = "Y" -o "$answer" = "y"
        sudo pacman -S --needed iwd
        sudo systemctl enable --now iwd
    end
end

function clone_configuations
    set_color ECEB7B; echo "[Copy configuration]"; set_color normal
    echo "Do you want to clone configuration? [Y/n] "
    read answer
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        echo ">>> Clone QSingularisRicer/fish.git"
        rm -rf ~/.config/fish
        git clone "https://github.com/QSingularisRicer/fish.git" ~/.config/fish

        echo ">>> Clone QSingularisRicer/hypr"
        rm -rf ~/.config/hypr
        git clone "https://github.com/QSingularisRicer/hypr.git" ~/.config/hypr

        echo ">>> Clone QSingularisRicer/waybar"
        rm -rf ~/.config/waybar
        git clone --single-branch --branch hyprland "https://github.com/QSingularisRicer/waybar" ~/.config/waybar

        echo ">>> Clone QSingularisRicer/wofi"
        rm -rf ~/.config/wofi
        git clone "https://github.com/QSingularisRicer/wofi.git" ~/.config/wofi

        echo ">>> Clone QSingularisRicer/kitty.git"
        rm -rf ~/.config/kitty
        git clone "https://github.com/QSingularisRicer/kitty" ~/.config/kitty
    end
end

# MAIN SCRIPT
prepare_keyring && install_aur_helper && install_desktop_environment && install_misc && enable_services && clone_configuations
