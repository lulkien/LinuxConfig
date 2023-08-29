#!/usr/bin/fish

function prepare_keyring
    set_color ECEB7B; echo "[Update package and install latest keyring]"; set_color normal
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
end

function install_yay
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
end

function install_seatd
    set_color ECEB7B; echo "[Install seatd]"; set_color normal
    echo "Install seatd, enable and add current use to group seat. Swaywm need that."
    sudo pacman -S --needed seatd
    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER
end

function install_hyprland
    set_color ECEB7B; echo "[Install hyprland window manager]"; set_color normal
    sudo pacman -S --needed hyprland hyprpaper
end

function install_fonts
    set_color ECEB7B; echo "[Install some good nerdfonts]"; set_color normal
    sudo pacman -S --needed ttf-jetbrains-mono-nerd ttf-liberation noto-fonts-cjk noto-fonts-emoji otf-codenewroman-nerd
end

function install_applications
    set_color ECEB7B; echo "[Install other applications]"; set_color normal
    sudo pacman -S \
    firefox kitty wofi waybar \
    lxappearance nemo gnome-keyring seahorse \
    ranger htop neovim vim net-tools man unzip \
    rsync wget curl grim slurp ffmpeg \
    pipewire pipewire-pulse lib32-pipewire wireplumber \
    wl-clipboard xorg-xrandr xorg-xwayland \
    xdg-desktop-portal xdg-desktop-portal-hyprland \
    fcitx5-im fcitx5-bamboo \
    python python-pip base-devel rustup cmake npm

    yay -S brave-bin adwaita-dark wl-color-picker swaync
end

function enable_services
    set_color ECEB7B; echo "[Install bluetooth service]"; set_color normal
    echo "Do you wanna install bluetooth? [y/N]"
    read answer
    if test "$answer" = "Y" -o "$answer" = "y"
        sudo pacman -S --needed bluez bluez-utils blueman
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

        echo ">>> Clone QSingularisRicer/kitty.git"
        rm -rf ~/.config/kitty
        git clone "https://github.com/QSingularisRicer/kitty" ~/.config/kitty
    end
end



# MAIN
prepare_keyring && install_yay && install_seatd && install_hyprland && install_fonts && install_applications && enable_services && clone_configuations
