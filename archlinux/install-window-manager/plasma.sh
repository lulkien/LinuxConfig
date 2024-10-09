#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

install_kde_plasma() {
    msg_ok '[Install KDE Plasma]'
    local packages=(
        'xorg' 'xorg-xwayland'
        'sddm' 'plasma'
        'konsole' 'dolphin' 'kwallet5' 'kwalletmanager' 'kate' 'spectacle'
        'kdeconnect' 'elisa' 'gwenview' 'ark' 'partitionmanager'
        'gamemode' 'discord' 'steam-native-runtime'
    )
    isntall_list_package "${packages[@]}"
    return $?
}

setup_sddm_catppuccin() {
    echo "Do you want to setup catppuccin for SDDM? [Y/n]"
    read -p 'Answer: ' answer
    answer=${answer,,}
    if [[ -z "${answer}" ]] || [[ "${answer}" =~ ^(yes|y)$ ]]; then
        wget https://github.com/catppuccin/sddm/releases/download/v1.0.0/catppuccin-mocha.zip -O /tmp/catppuccin-mocha.zip
        cd /tmp
        unzip catppuccin-mocha.zip

        sudo cp -r /tmp/catppuccin-mocha /usr/share/sddm/themes
        if [[ ! -e /etc/sddm.conf ]]; then
            sudo touch /etc/sddm.conf
            echo "[Theme]" | sudo tee -a /etc/sddm.conf
            echo "Current=catppuccin-mocha" | sudo tee -a /etc/sddm.conf
        else
            echo 'Please make sure you have this in /etc/sddm.conf:'
            echo '[Theme]'
            echo 'Current=catppuccin-mocha'
        fi
    fi
}

NO_CONFIRM=false # Process arguments
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

# Main
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
install_kde_plasma || exit
pacman_clean_up || exit
clone_dotfiles || exit
setup_sddm_catppuccin
