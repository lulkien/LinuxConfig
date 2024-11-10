#!/usr/bin/env bash

WIREPLUMBER_CONFIG_DIR=/etc/wireplumber/wireplumber.conf.d
BLUEZ_PROPERTIES=${WIREPLUMBER_CONFIG_DIR}/80-bluez-properties.conf

[[ -f $WIREPLUMBER_CONFIG_DIR ]] && sudo mkdir -p $WIREPLUMBER_CONFIG_DIR

echo -e "monitor.bluez.properties = {\n    bluez5.enable-hw-volume = false\n}" | sudo tee $BLUEZ_PROPERTIES
