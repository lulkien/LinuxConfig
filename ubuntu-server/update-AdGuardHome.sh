#!/usr/bin/env bash

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

echo_green "Download latest AdGuardHome binary"
wget -O '/tmp/AdGuardHome_linux_amd64.tar.gz' 'https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz'

echo_green "Stop AdGuardHome service"
sudo systemctl stop AdGuardHome.service

echo_green "Backup AdGuardHome data"
if [[ ! -d $HOME/server_config/opt/AdGuardHome ]]; then
  mkdir -p $HOME/server_config/opt/AdGuardHome
fi

sudo cp /opt/AdGuardHome/AdGuardHome.yaml $HOME/server_config/opt/AdGuardHome
sudo cp -r /opt/AdGuardHome/data $HOME/server_config/opt/AdGuardHome

echo_green "Extract new AdGuardHome package"
tar -C /tmp/ -f /tmp/AdGuardHome_linux_amd64.tar.gz -x -v -z

echo_green "Copy new AdGuardHome binary to /opt/AdGuardHome"
sudo -u adguard cp /tmp/AdGuardHome/AdGuardHome /opt/AdGuardHome/AdGuardHome

echo_green "Start AdGuardHome service"
sudo systemctl start AdGuardHome.service
