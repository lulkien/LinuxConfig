#!/usr/bin/env bash

options=('All open-source' 'AMD/ATI (open-source)' 'Intel (open-source)' 'Nvidia (open kernel module for newer GPUs, Turing+)' 'Nvidia (open-source nouveau driver)' 'Nvidia (proprietary)' 'VMware/VirtualBox (open-source)' 'Cancel')

packages=('xorg-server' 'xorg-xinit')

# Selection
echo -e '\e[1;32mPlease select an options:\e[00m'
select opt in "${options[@]}"; do
	case $REPLY in
	1)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('mesa' 'xf86-video-amdgpu' 'xf86-video-ati' 'xf86-video-nouveau' 'xf86-video-vmware' 'libva-mesa-driver' 'libva-intel-driver' 'intel-media-driver' 'vulkan-radeon' 'vulkan-intel')
		break
		;;
	2)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('mesa' 'xf86-video-amdgpu' 'xf86-video-ati' 'libva-mesa-driver' 'vulkan-radeon')
		break
		;;
	3)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('mesa' 'libva-intel-driver' 'intel-media-driver' 'vulkan-intel')
		break
		;;
	4)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('nvidia-open' 'dkms' 'nvidia-open-dkms')
		break
		;;
	5)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('mesa' 'libva-mesa-driver' 'xf86-video-nouveau')
		break
		;;
	6)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('nvidia-dkms' 'dkms')
		break
		;;
	7)
		echo
		echo -e "\e[1;32mSelected:\e[00m $opt"
		packages+=('mesa' 'xf86-video-vmware')
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
echo -e "\e[1;32mFollowing packages will be installed:\e[00m"
for pkg in "${packages[@]}"; do
	echo " - ${pkg}"
done

# Ask if ready to install
sleep 1
echo
echo -e "\e[1;32mDo you want to install the above packages?\e[00m"
read -r -p "[y/N] " response
case "$response" in
[Yy])
	sleep 0.5
	echo
	echo -e "\e[1;32mInstalling...\e[00m"
	;;
[Nn] | *)
	echo -e "\e[1;33mExiting...\e[00m"
	exit 0
	;;
esac

# Start install
echo "Install archlinux-keyring"
sudo pacman -Sy archlinux-keyring

echo "Install driver packages"
sudo pacman -S "${packages[@]}"
