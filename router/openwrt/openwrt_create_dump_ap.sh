#!/bin/ash

# Turn an OpenWrt router with factory settings into a dumb access point
# as outlined in https://openwrt.org/docs/guide-user/network/wifi/dumbap

# Disable some services
for i in firewall dnsmasq odhcpd; do
  if /etc/init.d/"$i" enabled; then
    echo "Disable service: $i"
    /etc/init.d/"$i" disable
    /etc/init.d/"$i" stop
  fi
done

# Setup br-lan
echo "Set DHCP client"
uci set network.lan.proto='dhcp'

echo "Delete unused interface"
uci delete network.wan
uci delete network.wan6
uci delete network.lan.ipaddr
uci delete network.lan.netmask

echo "Ignore dhcp on LAN"
uci del dhcp.lan.ra_slaac
uci del dhcp.lan.ra_flags
uci set dhcp.lan.ignore='1'

echo "Set time zone to Asia/Ho_Chi_Minh"
uci set system.@system[0].timezone='<+07>-7'
uci set system.@system[0].zonename='Asia/Ho Chi Minh'

echo "Commit"
uci commit

echo "Rebooting..."
reboot
