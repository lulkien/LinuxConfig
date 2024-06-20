#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

install_kde_plasma() {
	msg_ok '[install_kde_plasma]'
	local packages=(
		'xorg' 'xorg-xwayland'
		'sddm' 'plasma'
		'konsole' 'dolphin' 'kwallet5' 'kwalletmanager' 'kate' 'spectacle'
		'kdeconnect' 'elisa' 'gwenview' 'ark' 'partitionmanager'
		'kitty' 'gamemode' 'discord' 'steam-native-runtime'
	)
	isntall_list_package "${packages[@]}"
	return $?
}

# Main
validate_user || exit
update_keyring || exit
install_package_manager || exit
install_kde_plasma || exit
install_general_applications || exit
install_dev_tools || exit
install_lsp || exit
install_fonts || exit
install_input_method || exit
install_other_services || exit
install_firmware || exit
pacman_clean_up || exit
clone_dotfiles || exit
