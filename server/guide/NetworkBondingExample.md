# Configurate network bond with systemd-networkd

[https://wiki.linuxfoundation.org/networking/bonding](https://wiki.linuxfoundation.org/networking/bonding)

## /etc/systemd/network/10-bond0.netdev

```
[NetDev]
Name=bond0
Kind=bond

[Bond]
Mode=balance-alb
Primary=enp1s0
MIIMonitorSec=100ms
FailOverMacPolicy=active
```

## /etc/systemd/network/10-bond0.network

```
[Match]
Name=bond0

[Network]
DHCP=yes
```

## /etc/systemd/network/20-enp1s0.network

```
[Match]
Name=enp1s0

[Network]
Bridge=bond0
```

## /etc/systemd/network/20-enp3s0.network

```
[Match]
Name=enp3s0

[Network]
Bridge=bond0
```
