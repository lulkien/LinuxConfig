#!/usr/bin/env bash

BACKUP_DIR=/tmp/AdGuardHome.bak

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

if [[ $EUID -ne 0 ]]; then
  echo "ERROR: This script must be run as root (or with sudo)." >&2
  exit 1
fi

echo_green "Download latest AdGuardHome binary"
wget -O '/tmp/AdGuardHome_linux_amd64.tar.gz' 'https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz'

echo_green "Stop AdGuardHome service"
systemctl stop AdGuardHome.service

echo_green "Backup AdGuardHome data"
if [[ ! -d ${BACKUP_DIR} ]]; then
  mkdir -p ${BACKUP_DIR}
fi

cp /opt/AdGuardHome/AdGuardHome.yaml ${BACKUP_DIR}
cp -r /opt/AdGuardHome/data ${BACKUP_DIR}

echo_green "Extract new AdGuardHome package"
tar -C /tmp/ -f /tmp/AdGuardHome_linux_amd64.tar.gz -x -v -z

echo_green "Copy new AdGuardHome binary to /opt/AdGuardHome"
cp /tmp/AdGuardHome/AdGuardHome /opt/AdGuardHome/
cp /tmp/AdGuardHome/AdGuardHome.sig /opt/AdGuardHome/
cp /tmp/AdGuardHome/CHANGELOG.md /opt/AdGuardHome/
cp ${BACKUP_DIR}/AdGuardHome.yaml /opt/AdGuardHome/
cp -r ${BACKUP_DIR}/data /opt/AdGuardHome/

echo_green "Start AdGuardHome service"
systemctl start AdGuardHome.service
