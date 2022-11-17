#!/usr/bin/fish

set -g DM       $argv[1]
set -g flag     $argv[2]

function check_display_manager
    echo "[check_display_manager]"
    if [ -z "$DM" ]
        echo "What is you Display Manager?"
        return 1
    else
        if [ "$DM" != "gdm" -a "$DM" != "sddm" ]
            echo "Script only support for GDM and SDDM";
            return 2
        end
        echo "Install nvidia for Display Manager: $DM"
    end
end

function install_nvidia_package
    echo "[install_nvidia_package]"
    if [ "$flag" = "debug" ]
        echo "sudo pacman -S --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader nvidia-libgl lib32-nvidia-libgl mesa-utils"
    else
        sudo pacman -S --needed nvidia nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader nvidia-libgl lib32-nvidia-libgl mesa-utils
    end
    return $status
end

function configure_driver
    echo "[configure_driver]"
    if [ "$DM" = "sddm" ]
        echo "Configure for SDDM"
        if [ "$flag" = "debug" ]
            echo "cp 10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d"
            echo "cat Xsetup >> /usr/share/sddm/scripts/Xsetup"
        else
            sudo bash -c "cp 10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d"
            sudo bash -c "cat Xsetup >> /usr/share/sddm/scripts/Xsetup"; or return 1
        end
        return 0
    else
        echo "Configure for GDM"
        if [ "$flag" = "debug" ]
            echo "cp 10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d"
            echo "cp optimus.desktop /usr/share/gdm/greeter/autostart"
            echo "cp optimus.desktop /etc/xdg/autostart"
        else
            sudo bash -c "cp 10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d"
            sudo bash -c "cp optimus.desktop /usr/share/gdm/greeter/autostart"; or return 1
            sudo bash -c "cp optimus.desktop /etc/xdg/autostart"; or return 1
        end
        return 0
    end
end

function __main__
    check_display_manager; or return 1
    echo
    install_nvidia_package; or return 2
    echo
    configure_driver; or return 3
    echo
end

__main__
echo "ExitCode: $status"
echo ">>>>>> Please reboot the system. Thanks"
