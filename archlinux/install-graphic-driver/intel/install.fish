#!/usr/bin/fish

echo "Install mesa, vulkan, libs, etc."
echo "Is the generation of this processor equal or above gen 8? [Y/n]"
read answer
if test -z "$answer" -o "$answer" = 'Y' -o "$answer" = 'y'
    sudo pacman -S --needed mesa lib32-mesa
else
    sudo pacman -S --needed mesa-amber lib32-mesa-amber
end

sudo pacman -S --needed \
    mesa-demos lib32-mesa-demos \
    mesa-vdpau lib32-mesa-vdpau \
    libva-mesa-driver lib32-libva-mesa-driver \
    vulkan-icd-loader lib32-vulkan-icd-loader \
    vulkan-mesa-layers lib32-vulkan-mesa-layers

sudo pacman -S --needed vulkan-intel lib32-vulkan-intel 
