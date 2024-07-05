#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

install_hyprland() {
    msg_ok '[install_hyprland]'
    local packages=(
        'seatd'
        'hyprland' 'hyprpaper'
        'hyprlock' 'hyprpicker'
        'hyprdim' 'hypridle'
        'xdg-desktop-portal-hyprland'
        'alacritty' 'wofi' 'dunst'
        'anyrun-git' 'eww'
        'breeze' 'breeze-gtk'
        'nemo' 'loupe' 'seahorse' 'nemo-seahorse'
        'polkit-gnome' 'gnome-keyring'
        'grimblast' 'nwg-look-bin'
        'paper-icon-theme'
        'dhcpcd' 'iwd'
    )

    isntall_list_package "${packages[@]}"

    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    sudo systemctl enable --now dhcpcd
    sudo systemctl enable --now iwd
}

setup_home_dir() {
    msg_ok '[setup_home_dir]'

    local XDG_LIST=('Downloads' 'Documents' 'Pictures')
    for item in $XDG_LIST; do
        [[ ! -d $HOME/$item ]] && mkdir $HOME/$item
    done

    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' | tee $HOME/.config/user-dirs.dirs
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
}

validate_user || exit
update_keyring || exit
install_package_manager || exit
install_command_line_tool || exit
install_dev_tools || exit
install_general_applications || exit
install_lsp || exit
install_fonts || exit
install_input_method || exit
install_other_services || exit
install_firmware || exit
install_hyprland || exit # Everything is done, now install Hyprland
pacman_clean_up || exit
clone_dotfiles || exit
setup_home_dir || exit
