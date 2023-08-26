#!/usr/bin/fish

echo "Install mesa, vulkan, libs, etc."
echo "Is the generation of this processor equal or above gen 8? [Y/n]"
read answer
if test -z "$answer" -o "$answer" = 'Y' -o "$answer" = 'y'
    sudo pacman -S --needed mesa lib32-mesa
else
    sudo pacman -S --needed mesa-amber lib32-mesa-amber
end
sudo pacman -S vulkan-intel lib32-vulkan-intel
