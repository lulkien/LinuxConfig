# Configurate network interface enp1s0 with VLAN10 attached


## /etc/systemd/network/00-vlan10.netdev

```
[NetDev]
Name=vlan10
Kind=vlan

[VLAN]
Id=10
```

## /etc/systemd/network/10-enp1s0.network

```
[Match]
Name=enp1s0

[Network]
VLAN=vlan10
LinkLocalAddressing=no
LLDP=no
EmitLLDP=no
IPv6AcceptRA=no
IPv6SendRA=no
```

## /etc/systemd/network/20-vlan10.network

```
[Match]
Name=vlan10
Type=vlan

[Network]
Description=The interface for VLAN10
DHCP=yes
```

