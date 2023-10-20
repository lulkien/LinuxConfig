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
    sudo pacman -S --needed \
        xorg-xwayland hyprland hyprpaper \
        xdg-desktop-portal xdg-desktop-portal-hyprland

    set_color ECEB7B; echo "[Install common components of any window manager]"; set_color normal
    sudo pacman -S --needed \
        git fish vim \
        kitty wofi dunst \
        wget curl openssh rsync \
        htop neofetch lsb-release \
        wl-clipboard unzip unarchiver \
        nemo loupe gnome-keyring seahorse polkit-gnome \
        pipewire pipewire-pulse lib32-pipewire wireplumber
    yay -S swaylock-effects swaync eww-wayland

    set_color ECEB7B; echo "[Install input method]"; set_color normal
    sudo pacman -S --needed fcitx5-im fcitx5-bamboo
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
        breeze breeze-gtk \
        grim slurp jq ffmpeg \
        xorg-xrandr flatpak
    yay -S brave-bin nwg-look-bin hyprpicker

    set_color ECEB7B; echo "[Install development tools]"; set_color normal
    sudo pacman -S --needed python python-pip base-devel rustup npm clang
    sudo pacman -S --needed dbus-python python-gobject
end

function enable_services
    set_color ECEB7B; echo "[Install network service]"; set_color normal
    sudo pacman -S --needed dhcpcd
    sudo systemctl enable --now dhcpcd

    # sudo pacman -S --needed networkmanager nm-connection-editor
    # sudo systemctl enable --now NetworkManager

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

        echo ">>> Clone QSingularisRicer/eww"
        rm -rf ~/.config/eww
        git clone "https://github.com/QSingularisRicer/eww" ~/.config/eww

        echo ">>> Clone QSingularisRicer/swaylock"
        rm -rf ~/.config/swaylock
        git clone "https://github.com/QSingularisRicer/swaylock" ~/.config/swaylock

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
