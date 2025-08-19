# Configurate network bridge with systemd-networkd

[https://wiki.linuxfoundation.org/networking/bridge](https://wiki.linuxfoundation.org/networking/bridge)

## /etc/systemd/network/10-br0.netdev

```
[NetDev]
Name=br0
Kind=bridge
MACAddress=12:34:56:78:90:AB
```

## /etc/systemd/network/10-br0.network

```
[Match]
Name=br0

[Network]
DHCP=yes
```

## /etc/systemd/network/20-enp1s0.network

```
[Match]
Name=enp1s0

[Network]
Bridge=br0
```

## /etc/systemd/network/20-enp3s0.network

```
[Match]
Name=enp3s0

[Network]
Bridge=br0
```
