#!/usr/bin/env fish

function prepare_keyring
    set_color ECEB7B
    echo "[Update package and install latest keyring]"
    set_color normal
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
end

function install_aur_helper
    set_color ECEB7B
    echo "[Check paru available]"
    set_color normal
    sudo pacman -S --needed base-devel rustup
    rustup default nightly
    if not command -sq paru
        echo 'paru is not installed. Do you wanna install it? [Y/n]'
        read answer
        # If the answer is yes or empty, install paru
        if test -z "$answer" -o "$answer" = Y -o "$answer" = y
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            cd /tmp/paru
            makepkg -si
        end
    end
end

function install_desktop_environment
    set_color ECEB7B
    echo "[Install seatd]"
    set_color normal
    echo "Install seatd, enable and add current use to group seat. Swaywm need that."
    paru -S --needed seatd
    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    set_color ECEB7B
    echo "[Install hyprland window manager]"
    set_color normal
    paru -S --needed \
        xorg-xwayland hyprland hyprpaper \
        xdg-desktop-portal xdg-desktop-portal-hyprland

    set_color ECEB7B
    echo "[Install common components of any window manager]"
    set_color normal
    paru -S --needed \
        git fish vim neovim \
        alacritty kitty wofi dunst \
        wget curl openssh rsync \
        htop neofetch lsb-release \
        wl-clipboard unzip unarchiver \
        nemo loupe gnome-keyring seahorse polkit-gnome \
        pipewire pipewire-pulse lib32-pipewire wireplumber \
        xorg-xrandr \
        eww-wayland swaylock-effects hyprdim grimblast nwg-look-bin hyprpicker

    set_color ECEB7B
    echo "[Install input method]"
    set_color normal
    paru -S --needed fcitx5-im fcitx5-bamboo
    echo "QT_IM_MODULE=fcitx" | sudo tee -a /etc/environment
    echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment
    echo "SDL_IM_MODULE=fcitx" | sudo tee -a /etc/environment
    echo "GLFW_IM_MODULE=ibus" | sudo tee -a /etc/environment

    set_color ECEB7B
    echo "[Install other applications]"
    set_color normal
    paru -S --needed breeze breeze-gtk ffmpeg flatpak floorp-bin

    set_color ECEB7B
    echo "[Install development tools]"
    set_color normal
    paru -S --needed python python-pip base-devel npm clang dbus-python python-gobject
end

function install_misc
    set_color ECEB7B
    echo "[Install fonts]"
    set_color normal
    paru -S --needed \
        ttf-jetbrains-mono-nerd \
        ttf-liberation \
        noto-fonts-cjk \
        noto-fonts-emoji \
        otf-codenewroman-nerd \
        ttf-cascadia-code-nerd
end

function install_lsp
    set_color ECEB7B
    echo "[Instal LSP and formatter]"
    set_color normal
    paru -S --needed tree-sitter ripgrep
    paru -S --needed \
        bash-language-server \
        clang \
        cmake-language-server \
        lua-language-server \
        pyright \
        rust-analyzer \
        slint-lsp-bin \
        stylua \
        typescript-language-server \
        vscode-css-languageserver \
        vscode-json-languageserver
end

function enable_services
    set_color ECEB7B
    echo "[Install network service]"
    set_color normal
    paru -S --needed dhcpcd
    sudo systemctl enable --now dhcpcd

    set_color ECEB7B
    echo "[Install bluetooth service]"
    set_color normal
    echo "Do you wanna install bluetooth? [y/N]"
    read answer
    if test "$answer" = Y -o "$answer" = y
        paru -S --needed bluez bluez-utils blueman
        systemctl enable --now bluetooth
    end

    set_color ECEB7B
    echo "[Install iwd service]"
    set_color normal
    echo "Do you wanna install iwd? [y/N]"
    read answer
    if test "$answer" = Y -o "$answer" = y
        sudo pacman -S --needed iwd
        sudo systemctl enable --now iwd
    end
end

function clone_configuations
    set_color ECEB7B
    echo "[Clone dotfiles]"
    set_color normal
    echo "Do you want to clone dotfiles? [Y/n] "
    read answer
    if test -z "$answer" -o "$answer" = Y -o "$answer" = y
        rm -rf $HOME/.dotfiles
        git clone https://github.com/lulkien/dotfiles.git $HOME/.dotfiles
        echo "Please run setup script in $HOME/.dotfiles"
    end
end

function setup_home_dir
    set_color ECEB7B
    echo "[Setup HOME directory]"
    set_color normal

    set XDG_LIST Downloads Documents Pictures Desktop
    for xdg_item in $XDG_LIST
        if not test -d $HOME/$xdg_item
            mkdir $HOME/$xdg_item
        end
    end

    echo 'XDG_DESKTOP_DIR="$HOME/Desktop"' >$HOME/.config/user-dirs.dirs
    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' >>$HOME/.config/user-dirs.dirs
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"' >>$HOME/.config/user-dirs.dirs
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"' >>$HOME/.config/user-dirs.dirs
    echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures"' >>$HOME/.config/user-dirs.dirs
end

# MAIN SCRIPT
prepare_keyring && install_aur_helper && install_desktop_environment && install_misc && install_lsp && enable_services && clone_configuations && setup_home_dir
