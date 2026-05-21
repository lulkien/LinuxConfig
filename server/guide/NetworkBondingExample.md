# Configurate network bond with systemd-networkd

[https://wiki.linuxfoundation.org/networking/bonding](https://wiki.linuxfoundation.org/networking/bonding)

## /etc/systemd/network/10-bond0.netdev

```
[NetDev]
Name=bond0
Kind=bond

[Bond]
Mode=balance-alb
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

## /etc/systemd/network/20-slaves.network

```
[Match]
Name=enp1s0 enp3s0

[Network]
Bond=bond0
```
