#!/bin/sh

echo "===================================================="
echo " Starting OpenWrt Smart Switch / AP Conversion Script"
echo "===================================================="

# --------------------------------------------------
# ATTENDEDSYSUPGRADE
# --------------------------------------------------
echo "--> NOT allow attended sysupgrade"
uci set attendedsysupgrade.client.login_check_for_upgrades='0'
uci commit attendedsysupgrade

# --------------------------------------------------
# FIREWALL & SECURITY TEARDOWN
# --------------------------------------------------
echo "--> Configuring Firewall Zone 1 (WAN) to ACCEPT all traffic..."
uci set firewall.@zone[1].input='ACCEPT'
uci set firewall.@zone[1].forward='ACCEPT'

echo "--> Unassigning physical interfaces from WAN and LAN firewall zones..."
uci del firewall.@zone[1].network 2>/dev/null
uci del firewall.@zone[0].network 2>/dev/null

echo "--> Committing firewall UCI changes..."
uci commit firewall

echo "--> Stopping and permanently disabling firewall service..."
service firewall stop
service firewall disable

echo "--> Stopping and permanently disabling IPv6 RA/DHCPv6 daemon (odhcpd)..."
service odhcpd stop
service odhcpd disable

# --------------------------------------------------
# WAN INTERFACE REMOVAL & PHYSICAL BRIDGING
# --------------------------------------------------
echo "--> Removing traditional WAN and WAN6 interface definitions from configuration..."
uci del dhcp.wan 2>/dev/null
uci del network.wan 2>/dev/null
uci del network.wan6 2>/dev/null

echo "--> Adding the physical 'wan' port into the main bridge (br-lan)..."
uci add_list network.@device[0].ports='wan'

echo "--> Committing initial network and DHCP alterations..."
uci commit network
uci commit dhcp

# --------------------------------------------------
# LAN DHCP SERVER DISABLE
# --------------------------------------------------
echo "--> Disabling DHCP Server, Router Advertisements, and SLAAC on the default LAN..."
uci del dhcp.lan.ra_slaac 2>/dev/null
uci set dhcp.lan.ignore='1'
uci set dhcp.lan.dhcpv4='disabled'
uci set dhcp.lan.ra_preference='medium'

# --------------------------------------------------
# VLAN BRIDGE CREATION (802.1q)
# --------------------------------------------------
echo "--> Creating Bridge VLAN 20 (HOME)..."
echo "    Ports: lan1, lan2, lan3, br-lan.20 (Untagged/Access), wan (Tagged/Trunk)"
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='br-lan'
uci set network.@bridge-vlan[-1].vlan='20'
uci add_list network.@bridge-vlan[-1].ports='br-lan.20:t'
uci add_list network.@bridge-vlan[-1].ports='lan1'
uci add_list network.@bridge-vlan[-1].ports='lan2'
uci add_list network.@bridge-vlan[-1].ports='lan3'
uci add_list network.@bridge-vlan[-1].ports='wan:t'

echo "--> Creating Bridge VLAN 50 (SERVER)..."
echo "    Ports: br-lan.50 (Untagged/Access), wan (Tagged/Trunk)"
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='br-lan'
uci set network.@bridge-vlan[-1].vlan='50'
uci add_list network.@bridge-vlan[-1].ports='br-lan.50:t'
uci add_list network.@bridge-vlan[-1].ports='wan:t'

echo "--> Creating Bridge VLAN 100 (CAMERA)..."
echo "    Ports: br-lan.100 (Untagged/Access), wan (Tagged/Trunk)"
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='br-lan'
uci set network.@bridge-vlan[-1].vlan='100'
uci add_list network.@bridge-vlan[-1].ports='br-lan.100:t'
uci add_list network.@bridge-vlan[-1].ports='wan:t'

echo "--> Creating Bridge VLAN 110 (IOT)..."
echo "    Ports: br-lan.110 (Untagged/Access), wan (Tagged/Trunk)"
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='br-lan'
uci set network.@bridge-vlan[-1].vlan='110'
uci add_list network.@bridge-vlan[-1].ports='br-lan.110:t'
uci add_list network.@bridge-vlan[-1].ports='wan:t'

echo "--> Creating Bridge VLAN 150 (GUEST)..."
echo "    Ports: br-lan.150 (Untagged/Access), wan (Tagged/Trunk)"
uci add network bridge-vlan
uci set network.@bridge-vlan[-1].device='br-lan'
uci set network.@bridge-vlan[-1].vlan='150'
uci add_list network.@bridge-vlan[-1].ports='br-lan.150:t'
uci add_list network.@bridge-vlan[-1].ports='wan:t'

# --------------------------------------------------
# ATTACHING VLAN INTERFACES TO THE BRIDGE
# --------------------------------------------------
echo "--> Attaching logical VLAN sub-interfaces to the br-lan device structure..."
uci add_list network.@device[0].ports='br-lan.20'
uci add_list network.@device[0].ports='br-lan.50'
uci add_list network.@device[0].ports='br-lan.100'
uci add_list network.@device[0].ports='br-lan.110'
uci add_list network.@device[0].ports='br-lan.150'

# --------------------------------------------------
# INTERFACE LOGICAL DEFINITIONS
# --------------------------------------------------
echo "--> Provisioning logical interface: VLAN_HOME (VLAN 20) via DHCP..."
uci set network.VLAN_HOME=interface
uci set network.VLAN_HOME.proto='dhcp'
uci set network.VLAN_HOME.device='br-lan.20'

echo "--> Provisioning logical interface: VLAN_SERVER (VLAN 50) [Unmanaged]..."
uci set network.VLAN_SERVER=interface
uci set network.VLAN_SERVER.proto='none'
uci set network.VLAN_SERVER.device='br-lan.50'

echo "--> Provisioning logical interface: VLAN_CAMERA (VLAN 100) [Unmanaged]..."
uci set network.VLAN_CAMERA=interface
uci set network.VLAN_CAMERA.proto='none'
uci set network.VLAN_CAMERA.device='br-lan.100'

echo "--> Provisioning logical interface: VLAN_IOT (VLAN 110) [Unmanaged]..."
uci set network.VLAN_IOT=interface
uci set network.VLAN_IOT.proto='none'
uci set network.VLAN_IOT.device='br-lan.110'

echo "--> Provisioning logical interface: VLAN_GUEST (VLAN 150) [Unmanaged]..."
uci set network.VLAN_GUEST=interface
uci set network.VLAN_GUEST.proto='none'
uci set network.VLAN_GUEST.device='br-lan.150'

# --------------------------------------------------
# STRIPPING DEFAULT LAN MANAGEMENT IP
# --------------------------------------------------
echo "--> Stripping default Static IP/IPv6 configuration from base 'lan' interface..."
echo "    Warning: The device will no longer be accessible via its old IP address!"
uci del network.lan.ipaddr 2>/dev/null
uci del network.lan.multipath 2>/dev/null
uci del network.lan.ip6assign 2>/dev/null
uci set network.lan.proto='none'
uci set network.lan.multipath='off'

# --------------------------------------------------
# COMMIT AND YOLO APPLY
# --------------------------------------------------
echo "--> Committing all network and DHCP configurations to flash memory..."
uci commit network
uci commit dhcp

echo "===================================================="
echo " CONFIGURATION COMPLETE - NO SAFETY NET "
echo "===================================================="
echo " [!] CRITICAL WARNING [!]"
echo " We are applying changes with zero rollback capabilities."
echo " If you lose connectivity to the device after this step,"
echo " there is NO automatic reversion."
echo ""
echo " If you get locked out, you will need to use OpenWrt FAILSAFE MODE:"
echo " 1. Power cycle the router."
echo " 2. As soon as the status LED starts blinking rapidly,"
echo "    press and hold the Reset button for 2 seconds."
echo " 3. Set your computer's IP manually to 192.168.1.2."
echo " 4. SSH/Telnet into 192.168.1.1 to fix your config."
echo " 5. Run this command to factory reset: firstboot && reboot"
echo "===================================================="
echo " Sending it... Restarting network now."
echo " Good luck. Plug trunk uplink to WAN port and check your lease on VLAN 20"

# No safety checks. Direct restart.
/etc/init.d/network restart

