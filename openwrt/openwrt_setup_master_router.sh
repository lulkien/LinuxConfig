#!/bin/ash

################### YOUR CONFIG ######################

LAN_IP='192.168.1.1'
DNS_1='1.1.1.1'
DNS_2='8.8.8.8'

################### MAIN SCRIPT ######################

echo "Setup NTP server"
uci set system.@system[0].zonename='Asia/Ho Chi Minh'
uci set system.@system[0].timezone='<+07>-7'

uci del system.@timeserver[0].enabled
uci del system.@timeserver[0].enable_server
uci set system.@timeserver[0].enable_server='1'
uci set system.@timeserver[0].interface='lan'

echo "Setup Local Area Network"
uci del dhcp.lan.ra_slaac

uci set network.lan.ipaddr=$LAN_IP
uci add_list network.lan.dns=$DNS_1
uci add_list network.lan.dns=$DNS_2

uci set dhcp.lan.start='20'
uci set dhcp.lan.limit='200'
uci set dhcp.lan.force='1'

echo "Setup firewall"
uci del firewall.@defaults[0].syn_flood
uci set firewall.@defaults[0].synflood_protect='1'
uci set firewall.@defaults[0].flow_offloading='1'

uci commit

reboot
