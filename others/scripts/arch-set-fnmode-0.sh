#!/usr/bin/env bash

echo 'options hid_apple fnmode=0' | sudo tee /etc/modprobe.d/hid_apple.conf
ls -l /etc/mkinitcpio.d

echo "Now, please run mkinitcpio with your linux preset"
echo "Hint: sudo mkinitcpio -p linuxXYZ"
