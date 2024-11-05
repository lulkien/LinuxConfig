#!/usr/bin/env bash

echo 'options hid_apple fnmode=0' | sudo tee /etc/modprobe.d/hid_apple.conf

presets=($(ls /etc/mkinitcpio.d | grep -E '^linux.*\.preset$' | awk -F'.' '{print $1}'))

select preset in "${presets[@]}"; do

    [[ "$REPLY" =~ ^[0-9]+$ ]] || break
    [[ "$REPLY" -le 0 || "$REPLY" -gt "${#presets[@]}" ]] && break

    echo -e "\e[1;32msudo mkinitcpio -p linux\e[00m"
    sudo mkinitcpio -p ${preset}

    break

done
