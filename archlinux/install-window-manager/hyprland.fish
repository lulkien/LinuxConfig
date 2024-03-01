#!/usr/bin/env fish

set -l SCRIPT_PATH (realpath (status dirname))
source $SCRIPT_PATH/shared.fish

function install_hyprland
    install_logger "[Install Hyprland]"
    paru -S --needed seatd
    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    paru -S --needed hyprland hyprpaper hyprlock hyprpicker hyprdim xdg-desktop-portal-hyprland
    paru -S --needed \
        alacritty wofi dunst \
        breeze breeze-gtk \
        nemo loupe seahorse nemo-seahorse \
        polkit-gnome gnome-keyring \
        eww grimblast nwg-look-bin
end

function intall_dhcpcd
    install_logger "[Install dhcpcd]"
    paru -S --needed dhcpcd
    sudo systemctl enable --now dhcpcd
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
update_keyring
and install_aur_helper
and install_hyprland
and install_general_applications
and install_dev_tools
and install_lsp
and install_fonts
and install_input_method
and intall_dhcpcd
and install_other_services
and pacman_clean_up
and setup_home_dir
and clone_dotfiles
