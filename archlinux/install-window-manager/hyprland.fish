#!/usr/bin/env fish

set -l SCRIPT_PATH (realpath (status dirname))
source $SCRIPT_PATH/shared.fish

function install_hyprland
    install_logger "[Install Hyprland]"
    $AUR_HELPER -S --needed seatd
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end

    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    $AUR_HELPER -S --needed \
        hyprland hyprpaper \
        hyprlock hyprpicker \
        hyprdim hypridle \
        xdg-desktop-portal-hyprland
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end

    $AUR_HELPER -S --needed \
        alacritty wofi dunst \
        breeze breeze-gtk \
        nemo loupe seahorse nemo-seahorse \
        polkit-gnome gnome-keyring \
        grimblast nwg-look-bin \
        paper-icon-theme
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function intall_dhcpcd
    install_logger "[Install dhcpcd] DEPRECATED!!!"
    return

    $AUR_HELPER -S --needed dhcpcd
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end

    sudo systemctl enable --now dhcpcd
end

function install_networkmanager
    install_logger "[Install Network Manager]"
    $AUR_HELPER -S networkmanager
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end

    sudo systemctl enable --now NetworkManager
end

function install_ags_misc
    install_logger "[Install ags and stuffs]"
    $AUR_HELPER -S --needed \
        aylurs-gtk-shell \
        gnome-bluetooth-3.0
    set helper_status $status
    if test $helper_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $helper_status
    end
end

function setup_home_dir
    install_logger "[Setup HOME directory]"

    set XDG_LIST Downloads Documents Pictures
    for xdg_item in $XDG_LIST
        if not test -d $HOME/$xdg_item
            mkdir $HOME/$xdg_item
        end
    end

    echo 'XDG_DOWNLOAD_DIR="$HOME/Downloads"' | tee $HOME/.config/user-dirs.dirs
    echo 'XDG_DOCUMENTS_DIR="$HOME/Documents"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_PICTURES_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
    echo 'XDG_SCREENSHOTS_DIR="$HOME/Pictures"' | tee -a $HOME/.config/user-dirs.dirs
end

# MAIN SCRIPT
validate_user
and update_keyring
and install_aur_helper
and install_hyprland
and install_ags_misc
and install_general_applications
and install_dev_tools
and install_lsp
and install_fonts
and install_icons
and install_input_method
# and intall_dhcpcd
and install_firmware
and install_networkmanager
and install_other_services
and pacman_clean_up
and setup_home_dir
and clone_dotfiles
