#!/usr/bin/env bash

script_path=$(dirname "$(realpath "$0")")

options=('All open-source' 'AMD/ATI (open-source)' 'Intel (open-source)' 'Nvidia (open kernel module for newer GPUs, Turing+ or 16xx+)' 'Nvidia (open-source nouveau driver)' 'Nvidia (proprietary)' 'VMware/VirtualBox (open-source)' 'Cancel')

packages=('xorg-server' 'xorg-xinit')
additional_packages=('vulkan-icd-loader' 'vulkan-tools')
blender_packages=('hip-runtime-amd')

is_amd=false
is_nvidia=false

COLUMNS=30

# Selection
echo -e '\e[1;32m# Please select an options:\e[00m'
select opt in "${options[@]}"; do
    case $REPLY in
    1)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        packages+=('mesa' 'libva-mesa-driver' 'libva-intel-driver' 'intel-media-driver' 'vulkan-radeon' 'vulkan-intel')
        break
        ;;
    2)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        packages+=('mesa' 'libva-mesa-driver' 'vulkan-radeon')
        is_amd=true
        break
        ;;
    3)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        packages+=('mesa' 'libva-intel-driver' 'intel-media-driver' 'vulkan-intel')
        break
        ;;
    4)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        # packages+=('nvidia-open' 'dkms' 'nvidia-open-dkms')
        packages+=('nvidia-open' 'dkms')
        is_nvidia=true
        break
        ;;
    5)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        packages+=('mesa' 'libva-mesa-driver')
        is_nvidia=true
        break
        ;;
    6)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        # packages+=('nvidia-dkms' 'dkms')
        packages+=('nvidia' 'dkms')
        is_nvidia=true
        break
        ;;
    7)
        echo
        echo -e "\e[1;32m# Selected:\e[00m $opt"
        packages+=('mesa')
        break
        ;;
    8)
        echo -e "\e[1;33mExiting...\e[00m"
        exit 0
        ;;
    *) echo "Invalid option. Please select a number between 1 and ${#options[@]}" ;;
    esac
done

# Print packages name
sleep 0.5
echo
echo -e "\e[1;32m# Following packages will be installed:\e[00m"
for pkg in "${packages[@]}"; do
    echo " - ${pkg}"
done

# Ask if ready to install
sleep 1
echo
echo -e "\e[1;32m# Do you want to install the above packages?\e[00m [y/N]"
read -r -p "Answer: " response
case "$response" in
[Yy])
    sleep 0.5
    echo
    echo -e '\e[1;32mUpdate and install archlinux-keyring.\e[00m'
    sudo pacman -Sy --needed --noconfirm archlinux-keyring

    echo -e '\e[1;32mInstall packages...\e[00m'
    sudo pacman -S ${packages[@]}
    ;;
[Nn] | *)
    echo -e "\e[1;33mExiting...\e[00m"
    exit 0
    ;;
esac

# Install additional packages
sleep 1
echo
echo -e "\e[1;32m# Do you want to install some additional packages?\e[00m [y/N]"
for pkg in "${additional_packages[@]}"; do
    echo " - ${pkg}"
done
read -r -p "Answer: " response
case "$response" in
[Yy])
    sleep 0.5
    sudo pacman -S --needed --noconfirm ${additional_packages[@]}
    ;;
[Nn] | *)
    echo -e "\e[1;33mNah...\e[00m"
    ;;
esac

# For AMD
if [[ "$is_amd" = true ]]; then
    sleep 1
    echo
    echo -e "\e[1;32m# Do you want to install some packages for Blender?\e[00m [y/N]"
    for pkg in "${blender_packages[@]}"; do
        echo " - ${pkg}"
    done
    read -r -p "Answer: " response
    case "$response" in
    [Yy])
        sleep 0.5
        sudo pacman -S --needed --noconfirm ${blender_packages[@]}
        ;;
    [Nn] | *)
        echo -e "\e[1;33mNah...\e[00m"
        ;;
    esac
fi

# Note for Nvidia
if [[ "$is_nvidia" = true ]]; then
    sleep 0.5
    echo
    echo -e "\e[1;32m# Note for Nvidia:\e[00m"
    echo -e '1. Setting the Kernel Parameter:'
    echo -e ' + For GRUB user:'
    echo -e '   - Edit the GRUB configuration file: \e[1;32msudo vim /etc/default/grub\e[00m'
    echo -e '   - Find the line with \e[1;33mGRUB_CMDLINE_LINUX_DEFAULT\e[00m'
    echo -e '   - Append the words inside the quotes with \e[1;33mnvidia-drm.modeset=1\e[00m'
    echo -e '   - Example: \e[1;33mGRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"\e[00m'
    echo -e '   - Save and quit.'
    echo -e '   - Update the GRUB configuration: \e[1;32msudo grub-mkconfig -o /boot/grub/grub.cfg\e[00m'
    echo
    echo -e ' + For systemd-boot user:'
    echo -e '   - Navigate to the bootloader entries directory: \e[1;32mcd /boot/loader/entries\e[00m'
    echo -e '   - Edit the appropriate .conf file for your Arch Linux boot entry: \e[1;32msudo vim <filename>.conf\e[00m'
    echo -e '   - Append \e[1;33mnvidia-drm.modeset=1\e[00m to the options line.'
    echo -e '   - Save and quit.'

    echo
    echo -e '2. Add Early Loading of NVIDIA Modules:'
    echo -e ' - Edit the mkinitcpio configuration file: \e[1;32msudo vim /etc/mkinitcpio.conf\e[00m'
    echo -e ' - Change \e[1;33mMODULES=()\e[00m to \e[1;33mMODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)\e[00m'
    echo -e ' - Remove \e[1;33mkms\e[00m from line \e[1;33mHOOKS=(...)\e[00m if it exists.'
    echo -e ' - Save and quit.'
    echo -e ' - Regenerate the initramfs with: \e[1;32msudo mkinitcpio -P\e[00m'

    echo
    echo -e '3. Adding the Pacman Hook:'
    echo -e ' - Edit \e[1;33mnvidia.hook\e[00m file.'
    echo -e ' - Uncomment the correct driver you installed. Default driver is nvdia.'
    echo -e ' - Create directory "hooks" in /etc/pacman.d if not existed: \e[1;33msudo mkdir /etc/pacman.d/hooks\e[00m'
    echo -e " - Copy the \e[1;33mnvidia.hook\e[00m into that directory: sudo cp ${script_path}/nvidia.hook /etc/pacman.d/hooks"

    echo -e '4. Reboot and enjoy'
fi
