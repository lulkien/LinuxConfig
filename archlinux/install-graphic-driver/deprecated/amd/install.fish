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

function install_package_for_blender
    sudo pacman -S hip-runtime-amd
end

# MAIN SCRIPT

sudo pacman -Sy

install_mesa
and install_vulkan_driver
and install_package_for_blender
