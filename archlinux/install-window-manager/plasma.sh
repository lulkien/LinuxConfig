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
