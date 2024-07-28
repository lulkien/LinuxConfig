#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

install_hyprland() {
    msg_ok '[install_hyprland]'
    local packages=(
        'seatd'
        'hyprland' 'hyprpaper'
        'hyprlock' 'hyprpicker'
        'hyprcursor' 'hyprdim' 'hypridle'
        'xdg-desktop-portal-hyprland'
        'dunst' 'anyrun-git' 'eww'
        'nemo' 'loupe' 'seahorse' 'nemo-seahorse'
        'polkit-gnome' 'gnome-keyring'
        'thorium-browser'
        'grimblast' 'nwg-look-bin'
        'qogir-gtk-theme'
        'papirus-icon-theme'
        'catppuccin-cursors-macchiato'
        'networkmanager'
        'network-manager-applet'
        'dhcpcd' 'iwd'
    )

    isntall_list_package "${packages[@]}"

    sudo systemctl enable seatd
    sudo usermod -aG seat $USER

    sudo systemctl enable NetworkManager
}

post_install() {
    msg_ok '[post_install]'

    local XDG_LIST=('Downloads' 'Documents' 'Pictures')
    for item in $XDG_LIST; do
        [[ ! -d $HOME/$item ]] && mkdir $HOME/$item
    done

    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' | tee $HOME/.config/user-dirs.dirs
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs

    gsettings set org.gnome.desktop.interface gtk-theme 'Qogir-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-macchiato-light-cursors'
    gsettings set org.gnome.desktop.interface cursor-size 30
}

# Process arguments
NO_CONFIRM=false
NO_FIRMWARE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
    --no-confirm)
        NO_CONFIRM=true
        shift
        ;;
    --no-firmware)
        NO_FIRMWARE=true
        shift
        ;;
    *)
        echo "Warning: Ignoring invalid argument: $1"
        shift
        ;;
    esac
done

# MAIN
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
post_install || exit
