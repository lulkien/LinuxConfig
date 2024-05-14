function install_logger
    set_color ECEB7B
    echo "$argv[1]"
    set_color normal
end

function validate_user
    install_logger "[Validate user]"
    if test "$USER" = root
        echo "Please run with non-root user!"
        return 1
    else
        return 0
    end
end

function update_keyring
    install_logger "[Update keyring]"
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
    return $status
end

function install_paru
    set -g AUR_HELPER paru
    if not command -sq paru
        echo "$AUR_HELPER is not installed. Do you wanna install it? [Y/n]"
        read -p 'set_color green; printf "Answer: "; set_color normal' ans

        # If the answer is yes or empty, install paru
        if test -z "$ans" -o "$ans" = Y -o "$ans" = y
            sudo pacman -S --needed base-devel rustup
            rustup default nightly
            git clone https://aur.archlinux.org/paru.git /tmp/paru
            cd /tmp/paru
            makepkg -si
        end
    else
        echo "$AUR_HELPER was installed."
    end

end

function install_yay
    set -g AUR_HELPER yay
    if not command -sq $AUR_HELPER
        echo "$AUR_HELPER is not installed. Do you wanna install it? [Y/n]"
        read -p 'set_color green; printf "Answer: "; set_color normal' ans

        # If the answer is yes or empty, install paru
        if test -z "$ans" -o "$ans" = Y -o "$ans" = y
            git clone https://aur.archlinux.org/yay-bin.git /tmp/yay
            cd /tmp/yay
            makepkg -si
        end
    else
        echo "$AUR_HELPER was installed."
    end
end

function install_aur_helper
    install_logger "[Install aur helper]"

    echo "Select an aur helper:"
    echo "1. paru (default)"
    echo "2. yay (recommend for low-end device)"
    read -p 'set_color green; printf "Answer: "; set_color normal' ans
    if test $status -ne 0
        echo "Interupted!"
        return 1
    end

    if test "$ans" = 2
        install_yay
    else
        install_paru
    end
end

function install_general_applications
    install_logger "[Install general applications]"
    $AUR_HELPER -S --needed \
        git fish vim neovim \
        htop neofetch lsb-release openssh \
        wget curl openssh rsync wl-clipboard \
        unzip unarchiver xdg-user-dirs \
        pipewire pipewire-pulse lib32-pipewire wireplumber \
        ffmpeg flatpak firefox \
        libdbusmenu-gtk3
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function install_dev_tools
    install_logger "[Install development tools]"
    $AUR_HELPER -S --needed \
        base-devel clang rustup \
        python python-pip dbus-python python-gobject \
        lua luajit \
        dart-sass
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function install_lsp
    install_logger "[Install language server]"
    $AUR_HELPER -S --needed \
        tree-sitter ripgrep \
        clang astyle \
        bash-language-server shfmt \
        lua-language-server stylua \
        rust-analyzer slint-lsp-bin \
        pyright python-black \
        cmake-language-server \
        typescript-language-server \
        vscode-css-languageserver \
        vscode-json-languageserver \
        prettierd \
        yamlfmt
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function install_fonts
    install_logger "[Install fonts]"
    $AUR_HELPER -S --needed \
        ttf-jetbrains-mono-nerd \
        ttf-liberation \
        noto-fonts \
        noto-fonts-cjk \
        noto-fonts-emoji \
        noto-fonts-extra \
        otf-codenewroman-nerd \
        ttf-cascadia-code-nerd
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function install_icons
    install_logger "[Install icons]"
    $AUR_HELPER -S --needed \
        paper-icon-theme \
        arc-icon-theme
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function install_input_method
    install_fonts "[Install input method]"
    $AUR_HELPER -S --needed fcitx5-im fcitx5-bamboo
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end

    echo "QT_IM_MODULE=fcitx" | sudo tee -a /etc/environment
    echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment
    echo "SDL_IM_MODULE=fcitx" | sudo tee -a /etc/environment
    echo "GLFW_IM_MODULE=ibus" | sudo tee -a /etc/environment
end

function install_other_services
    install_logger "[install bluetooth service]"
    echo "Do you wanna install bluetooth? [y/N]"
    read -p 'set_color green; printf "Answer: "; set_color normal' ans
    if test "$ans" = Y -o "$ans" = y
        $AUR_HELPER -S --needed \
            bluez bluez-utils blueman \
            gnome-bluetooth-3.0
        set helper_status $status
        if test $helper_status -ne 0
            echo ">>>>>> FAILED <<<<<<"
            return $helper_status
        end
    end

    # install_logger "[install iwd service]"
    # echo "Do you wanna install iwd? [y/N]"
    # read -p 'set_color green; printf "Answer: "; set_color normal' ans
    # if test "$ans" = Y -o "$ans" = y
    #     $AUR_HELPER -S --needed iwd
    #     set helper_status $status
    #     if test $helper_status -ne 0
    #         echo ">>>>>> FAILED <<<<<<"
    #         return $helper_status
    #     end
    #     sudo systemctl enable --now iwd
    # end
end

function install_firmware
    install_logger "[install firmware]"
    $AUR_HELPER -S --needed mkinitcpio-firmware
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function pacman_clean_up
    install_logger "[Clean up]"
    sudo pacman -Rns (pacman -Qdttq)
end

function clone_dotfiles
    install_logger "[Clone dotfiles]"
    echo "Do you want to clone dotfiles? [Y/n] "
    read -p 'set_color green; printf "Answer: "; set_color normal' ans
    if test -z "$ans" -o "$ans" = Y -o "$ans" = y
        rm -rf $HOME/.dotfiles
        git clone https://github.com/lulkien/dotfiles.git $HOME/.dotfiles
        echo "Please run the setup script in $HOME/.dotfiles"
    end
end
