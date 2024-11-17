#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

install_hyprland() {
    msg_ok '[Install Hyprland packages]'
    local packages=(
        'seatd' 'sddm'
        'hyprland' 'hyprpaper' 'hyprlock' 'hyprpicker' 'hyprutils' 'hyprcursor' 'hyprdim' 'hypridle'
        'xdg-desktop-portal-hyprland'
        'dunst' 'anyrun-git' 'eww'
        'slurp' 'wf-recorder' 'grimblast'
        'nemo' 'loupe' 'seahorse' 'nemo-seahorse' 'nwg-look'
        'polkit-gnome' 'gnome-keyring'
        'qogir-gtk-theme' 'papirus-icon-theme' 'catppuccin-cursors-macchiato'
        'blueman' 'dhcpcd' 'iwd' 'iwgtk'
        'sound-theme-freedesktop'
    )

    isntall_list_package "${packages[@]}"

    sudo systemctl enable seatd
    sudo usermod -aG seat $USER

    sudo systemctl enable iwd
    sudo systemctl enable dhcpcd
}

post_install() {
    msg_ok '[Set up XDG dirs]'
    local XDG_LIST=('Downloads' 'Documents' 'Pictures')
    for item in $XDG_LIST; do
        [[ ! -d $HOME/$item ]] && mkdir $HOME/$item
    done

    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' | tee $HOME/.config/user-dirs.dirs
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs

    msg_ok '[Config XDG themes]'
    gsettings set org.gnome.desktop.interface gtk-theme 'Qogir-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-macchiato-light-cursors'
    gsettings set org.gnome.desktop.interface cursor-size 30

    msg_ok '[Setting Catppuccin Mocha for SDDM]'
    catppuccin_sddm_deps=('qt6-svg' 'qt6-declarative')
    isntall_list_package "${catppuccin_sddm_deps[@]}"

    wget https://github.com/lulkien/sddm/releases/download/v1.0.0/catppuccin-mocha.zip -O /tmp/catppuccin-mocha.zip
    if [[ $status -eq 0 ]]; then
        sudo unar -f /tmp/catppuccin-mocha.zip -o /usr/share/sddm/themes
        echo "Do you want to setup theme in /etc/sddm.conf? [y/N]"
        read -p 'Answer: ' answer
        answer=${answer,,}

        if [[ "${answer}" =~ ^(yes|y)$ ]]; then
            echo '[Theme]' | sudo tee -a /etc/sddm.conf
            echo 'Current=catppuccin-mocha' | sudo tee -a /etc/sddm.conf
        else
            echo 'Please make sure you have this in /etc/sddm.conf:'
            echo '[Theme]'
            echo 'Current=catppuccin-mocha'
        fi
    else
        echo "Cannot download Catppuccin theme for SDDM. Please install it manually."
    fi

    msg_ok '[Install Hyprvisor]'
    mkdir /tmp/hyprvisor
    cd /tmp/hyprvisor
    wget https://raw.githubusercontent.com/lulkien/hyprvisor/refs/heads/master/PKGBUILD
    makepkg -si

    if [[ $? -ne 0 ]]; then
        msg_err 'Something wrong with that PKGBUILD, please fix it yourself.'
    fi
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
