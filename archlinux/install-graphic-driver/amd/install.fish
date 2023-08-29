#!/usr/bin/fish

echo "install lib for mesa, vulkan, etc."
sudo pacman -S --noconfirm --needed \
	mesa lib32-mesa \
	mesa-demos lib32-mesa-demos \
	mesa-vdpau lib32-mesa-vdpau \
	libva-mesa-driver lib32-libva-mesa-driver \
	vulkan-icd-loader lib32-vulkan-icd-loader

echo "install driver"
sudo pacman -S --noconfirm --needed vulkan-radeon lib32-vulkan-radeon
