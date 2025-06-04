#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

echo_red() {
  echo -e '\e[1;31m'"$@"'\e[00m'
}

if [ "$(id -u)" -ne 0 ]; then
  echo_red "This script must be run as root"
  exit 1
fi

echo_green "Install something"
apt install -y dnsmasq nftables avahi-daemon curl wget

echo_green "Deploy"
cp ${SCRIPT_DIR}/etc/nftables.conf /etc
cp ${SCRIPT_DIR}/etc/dnsmasq.d/* /etc/dnsmasq.d
cp ${SCRIPT_DIR}/etc/systemd/network/* /etc/systemd/network
cp ${SCRIPT_DIR}/etc/systemd/resolved.conf.d/* /etc/systemd/resolved.conf.d
cp ${SCRIPT_DIR}/etc/sysctl.d/* /etc/sysctl.d
