#!/usr/bin/env fish

function install_mesa
    sudo pacman -S mesa lib32-mesa \
        mesa-demos lib32-mesa-demos \
        mesa-vdpau lib32-mesa-vdpau \
        libva-mesa-driver lib32-libva-mesa-driver
end

function install_vulkan_driver
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon \
        vulkan-mesa-layers lib32-vulkan-mesa-layers \
        vulkan-icd-loader lib32-vulkan-icd-loader
end

# MAIN SCRIPT
install_mesa && install_vulkan_driver
