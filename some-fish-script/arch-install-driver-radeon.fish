#!/usr/bin/fish

echo "install lib for mesa, vulkan, etc."
sudo pacman -S --noconfirm --needed lib32-vulkan-radeon libva-mesa-driver vulkan-radeon mesa mesa-demos mesa-vdpau lib32-libva-mesa-driver lib32-mesa lib32-mesa-demos lib32-mesa-vdpau

echo "install driver"
sudo pacman -S --noconfirm --needed lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader

echo "remove amdvlk"
sudo pacman -Rns amdvlk

