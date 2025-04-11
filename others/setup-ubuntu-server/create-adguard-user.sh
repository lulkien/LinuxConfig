#!/usr/bin/env bash

ADGUARD_DIR=/opt/AdGuardHome

if [[ ! -d $ADGUARD_DIR ]]; then
  printf "Why create adguard user when not install AdguardHome?\n"
  printf "Or I'm wrong? Then feel free to set ADGUARD_DIR yourself.\n"
  exit 1
fi

if $(id adguard &>/dev/null); then
  printf "User adguard existed.\n"
  exit 2
fi

printf "Create user adguard.\n"

sudo useradd -r -s /usr/sbin/nologin -M -d $ADGUARD_DIR adguard

printf "\n"
if $(id adguard &>/dev/null); then
  printf "It's all done.\n"
else
  printf "I can't do it, sorry.\n"
  exit 3
fi

printf "\n"
printf "Now set ownership for ${ADGUARD_DIR}.\n"
sudo chown -R adguard:adguard $ADGUARD_DIR

printf "\n"
printf "And set some magic stuff for the AdguardHome binary too.\n"
sudo setcap 'cap_net_bind_service=+ep' ${ADGUARD_DIR}/AdGuardHome

printf "\n"
printf "Now, please add these line to your AdGuardHome service file in [Service] section:\n"
printf "    User=adguard\n"
printf "    Group=adguard\n"
printf "\n"
printf "Your service should be found in /etc/systemd/system.\n"
printf "Or you can figure it out yourself.\n"

printf "\n"
printf "Very well.\n"
printf "\n"
printf "Now, please reload daemon and restart service.\n"
printf "Good luck, my friend.\n"
