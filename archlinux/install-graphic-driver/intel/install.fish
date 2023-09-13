#!/usr/bin/fish

function install_mesa
    echo "Is the generation of this processor equal or above gen 8? [Y/n]"
    read answer
    if test -z "$answer" -o "$answer" = 'Y' -o "$answer" = 'y'
        sudo pacman -S --needed mesa lib32-mesa
    else
        sudo pacman -S --needed mesa-amber lib32-mesa-amber
    end
    
    sudo pacman -S \
        mesa-demos lib32-mesa-demos \
        mesa-vdpau lib32-mesa-vdpau \
        libva-mesa-driver lib32-libva-mesa-driver
end

function install_vulkan_driver
    sudo pacman -S \
        vulkan-intel lib32-vulkan-intel \
        vulkan-mesa-layers lib32-vulkan-mesa-layers
end

# MAIN SCRIPT
install_mesa && install_vulkan_driver
