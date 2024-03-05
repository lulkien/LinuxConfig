#!/usr/bin/env fish

set -l SCRIPT_PATH (realpath (status dirname))
source $SCRIPT_PATH/shared.fish

function install_hyprland
    install_logger "[Install Hyprland]"
    paru -S --needed seatd
    set paru_status $status
    if test $paru_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $paru_status
    end

    sudo systemctl enable --now seatd
    sudo usermod -aG seat $USER

    paru -S --needed \
        hyprland hyprpaper \
        hyprlock hyprpicker \
        hyprdim xdg-desktop-portal-hyprland
    set paru_status $status
    if test $paru_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $paru_status
    end

    paru -S --needed \
        alacritty wofi dunst \
        breeze breeze-gtk \
        nemo loupe seahorse nemo-seahorse \
        polkit-gnome gnome-keyring \
        eww grimblast nwg-look-bin
    set paru_status $status
    if test $paru_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $paru_status
    end
end

function intall_dhcpcd
    install_logger "[Install dhcpcd]"
    paru -S --needed dhcpcd
    set paru_status $status
    if test $paru_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $paru_status
    end

    sudo systemctl enable --now dhcpcd
end

function install_login_mamanger
    install_logger "[Install login manager]"
    echo "Do you wanna install sddm? [y/N]"
    read answer
    if not test "$answer" = Y -o "$answer" = y
        return
    end

    paru -S --needed sddm qt5-graphicaleffects qt5-svg qt5-quickcontrols2
    set paru_status $status
    if test $paru_status -ne 0
        echo ">>>>>> FAILED <<<<<<"
        return $paru_status
    end

    git clone https://github.com/catppuccin/sddm.git /tmp/catppuccin-sddm
    sudo cp -r /tmp/catppuccin-sddm/src/catppuccin-mocha /usr/share/sddm/themes
    if not test -e /etc/sddm.conf
        echo "[Theme]" | sudo tee /etc/sddm.conf
        echo "Current=catppuccin-mocha" | sudo tee -a /etc/sddm.conf
    else
        echo "[Theme]"
        echo "Current=catppuccin-mocha"
        echo "Put this config into file /etc/sddm.conf"
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
and install_login_mamanger
and pacman_clean_up
and setup_home_dir
and clone_dotfiles
