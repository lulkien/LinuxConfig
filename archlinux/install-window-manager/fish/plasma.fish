#!/usr/bin/env fish

set -l SCRIPT_PATH (realpath (status dirname))
source $SCRIPT_PATH/shared.fish

function install_kde_plasma
    install_logger "[Install KDE Plasma]"
    $AUR_HELPER -S --needed \
        xorg xorg-xwayland \
        sddm plasma \
        konsole dolphin kwallet5 kwalletmanager kate spectacle \
        kdeconnect elisa gwenview ark partitionmanager \
        kitty gamemode discord steam-native-runtime
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

# MAIN SCRIPT
validate_user
and update_keyring
and install_aur_helper
and install_kde_plasma
and install_general_applications
and install_dev_tools
and install_lsp
and install_fonts
and install_input_method
and install_other_services
and install_firmware
and pacman_clean_up
and clone_dotfiles
