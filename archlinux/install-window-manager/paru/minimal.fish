#!/usr/bin/env fish

set -l SCRIPT_PATH (realpath (status dirname))
source $SCRIPT_PATH/shared.fish

# MAIN SCRIPT
validate_user
and update_keyring
and install_aur_helper
and install_general_applications
and install_dev_tools
and install_lsp
and install_fonts
# and install_input_method
and install_other_services
and install_firmware
and pacman_clean_up
and clone_dotfiles
