#!/usr/bin/env bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source ${SCRIPT_PATH}/shared.sh

# MAIN SCRIPT
validate_user || exit
update_keyring || exit
install_package_manager || exit
install_command_line_tool || exit
install_dev_tools || exit
install_general_applications || exit
install_lsp || exit
install_fonts || exit
install_other_services || exit
install_firmware || exit
pacman_clean_up || exit
clone_dotfiles || exit
