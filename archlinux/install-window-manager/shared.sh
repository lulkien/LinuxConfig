msg_ok() {
    echo -e "\e[1;32m$1\e[00m"
}

msg_noti() {
    echo -e "\e[1;33m$1\e[00m"
}

msg_err() {
    echo -e "\e[1;31m$1\e[00m"
}

validate_user() {
    msg_ok '[validate_user]'
    if [[ $(whoami) = 'root' ]]; then
        echo "Please run this script with non-root user"
        return 1
    else
        return 0
    fi
}

update_keyring() {
    msg_ok '[update_keyring]'
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
    sudo pacman -Sy
    sudo pacman -S --needed archlinux-keyring
}

install_aur_helper() {
    AUR_HELPER="$1"
    if [[ -z "${AUR_HELPER}" ]]; then
        return 1
    fi

    msg_ok "[install_${AUR_HELPER}]"
    if ! command -v ${AUR_HELPER} &>/dev/null; then
        echo "$AUR_HELPER is not installed. Do you wanna install it? [Y/n]"
        read -p 'Answer: ' answer
        # Lowercase answer
        answer=${answer,,}

        # If the answer is yes or empty, install AUT_HELPER
        if [[ -z "${answer}" ]] || [[ "${answer}" =~ ^(yes|y)$ ]]; then
            sudo rm -rf /tmp/${AUR_HELPER}
            git clone https://aur.archlinux.org/${AUR_HELPER}-bin.git /tmp/${AUR_HELPER}
            cd /tmp/${AUR_HELPER}
            makepkg -si
            return $?
        fi
    else
        echo "${AUR_HELPER} was installed"
        return 0
    fi
}

install_package_manager() {
    msg_ok '[install_package_manager]'
    local options=('paru' 'yay')
    select opt in "${options[@]}"; do
        case "${REPLY}" in
        1 | 2)
            break
            ;;
        *)
            echo "Canceled"
            return 1
            ;;
        esac
    done

    echo -e "\e[1;33mSelected:\e[00m ${opt}"
    install_aur_helper ${opt}
    return $?
}

print_list_package() {
    local packages=("$@")
    msg_noti 'These packages will be installed:'
    for package in "${packages[@]}"; do
        echo " - ${package}"
    done
}

isntall_list_package() {
    local packages=("$@")
    print_list_package "${packages[@]}"
    ${AUR_HELPER} -S --needed "${packages[@]}"
    if [[ $? -ne 0 ]]; then
        msg_err ">>>>>> FAILED <<<<<<"
        return 1
    else
        return 0
    fi
}

install_command_line_tool() {
    msg_ok '[install_command_line_tool]'
    local packages=(
        'git' 'fish' 'vim' 'neovim'
        'htop' 'fastfetch' 'lsb-release'
        'openssh' 'wget' 'curl' 'rsync'
        'wl-clipboard' 'unzip' 'unarchiver'
        'less' 'jq'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

install_general_applications() {
    msg_ok "[install_general_applications]"
    local packages=(
        'xdg-user-dirs' 'pipewire' 'pipewire-pulse'
        'lib32-pipewire' 'wireplumber'
        'ffmpeg' 'flatpak' 'firefox'
        'thorium-browser' 'libdbusmenu-gtk3'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

install_dev_tools() {
    msg_ok '[install_dev_tools]'
    local packages=(
        'base-devel' 'clang' 'rustup'
        'python' 'python-pip' 'dbus-python' 'python-gobject'
        'lua' 'luajit' 'dart-sass'
    )
    isntall_list_package "${packages[@]}"
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    rustup default stable
}

install_lsp() {
    msg_ok '[install_language_servers]'
    local packages=(
        'tree-sitter' 'ripgrep'
        'bash-language-server' 'shfmt'
        'lua-language-server' 'stylua'
        'rust-analyzer' 'slint-lsp-bin'
        'pyright' 'python-black'
        'typescript-language-server'
        'vscode-css-languageserver'
        'vscode-json-languageserver'
        'prettierd'
        'yamlfmt' 'taplo-cli'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

install_fonts() {
    msg_ok "[Install fonts]"
    local packages=(
        'ttf-jetbrains-mono-nerd'
        'ttf-liberation'
        'noto-fonts'
        'noto-fonts-cjk'
        'noto-fonts-emoji'
        'noto-fonts-extra'
        'otf-codenewroman-nerd'
        'ttf-cascadia-code-nerd'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

install_icons() {
    msg_ok '[install_icons]'
    local packages=(
        'paper-icon-theme'
        'arc-icon-theme'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

install_input_method() {
    msg_ok '[install_input_method]'
    local packages=(
        'fcitx5-im'
        'fcitx5-bamboo'
    )
    isntall_list_package "${packages[@]}"
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    echo "Do you want to append environment for input method? [Y/n]"
    read -p 'Answer: ' answer
    # Lowercase answer
    answer=${answer,,}

    # If the answer is yes or empty, install AUT_HELPER
    if [[ -z "${answer}" ]] || [[ "${answer}" =~ ^(yes|y)$ ]]; then
        echo "QT_IM_MODULE=fcitx" | sudo tee -a /etc/environment
        echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment
        echo "SDL_IM_MODULE=fcitx" | sudo tee -a /etc/environment
        echo "GLFW_IM_MODULE=ibus" | sudo tee -a /etc/environment
    fi
}

install_other_services() {
    msg_ok "[install_other_services]"
    echo "Do you wanna install bluetooth? [y/N]"
    read -p 'Answer: ' answer
    # Lowercase answer
    answer=${answer,,}

    # If the answer is yes or empty, install AUT_HELPER
    if [[ "${answer}" =~ ^(yes|y)$ ]]; then
        local packages=(
            'bluez'
            'bluez-utils'
        )
        isntall_list_package "${packages[@]}"
        systemctl enable --now bluetooth
    fi
}

install_firmware() {
    msg_ok '[install_firmware]'
    local packages=(
        'mkinitcpio-firmware'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

pacman_clean_up() {
    msg_ok '[pacman_clean_up]'
    sudo pacman -Rns $(pacman -Qdttq)
    return 0
}

clone_dotfiles() {
    msg_ok "[clone_dotfiles]"
    if [[ ! -d $HOME/.dotfiles ]]; then
        echo "Do you want to clone dotfiles? [Y/n]"
        read -p 'Answer: ' answer
        # Lowercase answer
        answer=${answer,,}

        # If the answer is yes or empty, install AUT_HELPER
        if [[ -z "${answer}" ]] || [[ "${answer}" =~ ^(yes|y)$ ]]; then
            rm -rf $HOME/.dotfiles
            git clone https://github.com/lulkien/dotfiles.git $HOME/.dotfiles
            echo "Please run the setup script in $HOME/.dotfiles"
        fi
    else
        echo "$HOME/.dotfiles existed."
    fi
}
