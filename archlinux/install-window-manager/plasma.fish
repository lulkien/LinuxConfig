#!/usr/bin/env fish

function prepare_keyring
    set_color ECEB7B; echo "[Update package and install latest keyring]"; set_color normal
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
end

function install_aur_helper
    set_color ECEB7B; echo "[Check paru available]"; set_color normal
    sudo pacman -S --needed base-devel rustup
    rustup default nightly
    if not command -sq paru
        echo 'paru is not installed. Do you wanna install it? [Y/n]'
        read answer
        # If the answer is yes or empty, install paru
        if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            cd /tmp/paru
            makepkg -si
        end
    end
end

function install_desktop_environment
    set_color ECEB7B; echo "[Install plasma]"; set_color normal
    sudo pacman -S --needed xorg xorg-xwayland sddm plasma plasma-wayland-session
    sudo pacman -S --needed konsole dolphin kwallet5 kwalletmanager kate spectacle kdeconnect elisa gwenview ark partitionmanager
end

function install_misc
    set_color ECEB7B; echo "[Install fonts]"; set_color normal
    sudo pacman -S --needed \
        ttf-jetbrains-mono-nerd \
        ttf-liberation \
        noto-fonts-cjk \
        noto-fonts-emoji \
        otf-codenewroman-nerd

    set_color ECEB7B; echo "[Install appliactions]"; set_color normal
    sudo pacman -S --needed \
        git fish vim neovim kitty \
        firefox flatpak \
        htop neofetch lsb-release \
        wget curl openssh rsync wl-clipboard \
        gamemode unzip unarchiver \
        pipewire pipewire-pulse lib32-pipewire wireplumber \
        discord steam-native-runtime

    set_color ECEB7B; echo "[Install fcitx5]"; set_color normal
    sudo pacman -S --needed fcitx5 kcm-fcitx5 fcitx5-bamboo fcitx5-im
    echo "GTK_IM_MODULE=fcitx"  | sudo tee -a /etc/environment
    echo "QT_IM_MODULE=fcitx"   | sudo tee -a /etc/environment
    echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment
    echo "SDL_IM_MODULE=fcitx"  | sudo tee -a /etc/environment
    echo "GLFW_IM_MODULE=ibus"  | sudo tee -a /etc/environment

    set_color ECEB7B; echo "[Install development tools]"; set_color normal
    sudo pacman -S --needed python python-pip base-devel npm clang
end


function enable_services
    set_color ECEB7B; echo "[Install bluetooth service]"; set_color normal
    echo "Do you wanna install bluetooth? [y/N]"
    read answer
    if test "$answer" = "Y" -o "$answer" = "y"
        sudo pacman -S --needed bluez bluez-utils
        systemctl enable --now bluetooth
    end
end


function clone_configuations
    set_color ECEB7B; echo "[Copy configuration]"; set_color normal
    echo "Do you want to clone configuration? [Y/n] "
    read answer
    if test -z "$answer" -o "$answer" = "Y" -o "$answer" = "y"
        echo ">>> Clone QuantaRicer/fish.git"
        rm -rf ~/.config/fish
        git clone "https://github.com/QuantaRicer/fish.git" ~/.config/fish

        echo ">>> Clone QuantaRicer/kitty.git"
        rm -rf ~/.config/kitty
        git clone "https://github.com/QuantaRicer/kitty" ~/.config/kitty
    end
end

# MAIN SCRIPT
prepare_keyring && install_aur_helper && install_desktop_environment && install_misc && enable_services && clone_configuations
