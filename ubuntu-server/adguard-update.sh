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
sudo cp /tmp/AdGuardHome/AdGuardHome /opt/AdGuardHome/
sudo cp /tmp/AdGuardHome/AdGuardHome.sig /opt/AdGuardHome/

echo_green "Reset ownership for /opt/AdGuardHome"
sudo chown adguard: -R /opt/AdGuardHome

echo_green "Almost done, but there are a few things you MUST do before you start AdGuardHome.service"
echo_green "If you run AdGuardHome as another user. You have to reset the ownership"
echo "  sudo chown <your-adguard-user>: -R /opt/AdGuardHome"
echo

echo_green "And because that user won't have permission to listen on port 53"
echo_green "This command allow AdGuardHome to listen on that port"
echo "  sudo setcap CAP_NET_BIND_SERVICE=+eip /opt/AdGuardHome/AdGuardHome"
echo

echo_green "Then, you can start AdGuardHome.service"
echo "  sudo systemctl start AdGuardHome.service"
