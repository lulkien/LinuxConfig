# Some useful commands to setup RouterOS for the first time

Example information:

- 1 device runs RouterOS with 4 ethernet ports.
  - ether1
  - ether2
  - ether3
  - ether4

- Create 2 logical interfaces: WAN and LAN
  - WAN: ether1 -> DHCP client, connected to upstream router (IPS's router)
  - LAN: ether2, ether3, ether4 -> DHCP server, connected to home's network

- Timezone: Asia/Ho_Chi_Minh

- Home network define
  - Gateway: 192.168.88.1 (This router)
  - Subnet: 192.168.88.0/24
  - Dynamic IP range: 192.168.88.50 - 192.168.88.200
  - Dynamic IP lease time: 12h
  - DNS server: 1.1.1.1, 8.8.8.8

- Firewall rule:
  - INPUT: Accept traffic to local loopback
  - INPUT: Accept traffic from LAN
  - INPUT: Accept ICMP protocol traffic in all interfaces
  - INPUT: Drop other traffic from WAN
  - FORWARD: Accept traffic from LAN to WAN
  - FORWARD: Drop traffic from WAN to LAN
  - NAT: Masquerade traffic go out from WAN

## First time setup

### Enable WebFig service

```console
/ip service set www port=80 disabled=no
```

## Secure your router

### Turn off neighbor discovery

```console
/ip neighbor discovery-settings set discover-interface-list=none
```

### Disable bandwidth server

```console
/tool bandwidth-server set enabled=no
```

### Disable other client services

```console
/ip proxy set enabled=no
/ip socks set enabled=no
/ip upnp set enabled=no
/ip cloud set ddns-enabled=no update-time=no
```

### More Secure SSH access

```console
/ip ssh set strong-crypto=yes
```

## NTP

### Set timezone

```console
/system clock set time-zone-autodetect=no
/system clock set time-zone-name=<TIMEZONE>

# Example
/system clock set time-zone-name=Asia/Ho_Chi_Minh
```

### Setup NTP client

```console
/system clock set time-zone-autodetect=no
/system clock set time-zone-name=Asia/Ho_Chi_Minh
```

### Setup NTP server

```console
/system ntp server set enabled=yes
```

## Interfaces

### Show all interfaces

```console
/interface print
```

### Set auto flow control for ethernet interfaces

```console
/interface ethernet set ether1 tx-flow-control=auto rx-flow-control=auto
/interface ethernet set ether2 tx-flow-control=auto rx-flow-control=auto
/interface ethernet set ether3 tx-flow-control=auto rx-flow-control=auto
/interface ethernet set ether4 tx-flow-control=auto rx-flow-control=auto
```

## Bridge

### Print bridge info

```console
/interface bridge print
/interface bridge port print
```

### Create new bridge

```console
/interface bridge add name=<BRIDGE_NAME>

# Example
/interface bridge add name=WAN
/interface bridge add name=LAN
```

Note: Bridge can be used as an interface.

### Add interfaces to bridge

```console
/interface bridge port add bridge=<BRIDGE_NAME> interface=<INTERFACE_NAME>

# Example
/interface bridge port add bridge=WAN interface=ether1

/interface bridge port add bridge=LAN interface=ether2
/interface bridge port add bridge=LAN interface=ether3
/interface bridge port add bridge=LAN interface=ether4
```

### Assign IP address to bridge
```console
/ip address add address=<ROUTER_IP_CIDR> interface=<BRIDGE_NAME>

# Example
/ip address add address=192.168.88.1/24 interface=LAN
```

## DNS

### Set DNS servers for router

```console
/ip dns set servers=<DNS_IP_ADDRESSES> allow-remote-requests=yes

# Example
/ip dns set servers=1.1.1.1,8.8.8.8 allow-remote-requests=yes
```

## DHCP client

### Check if have any DHCP client already bind to any interfaces

```console
/ip dhcp-client print
```

### Setup DHCP client

```console
/ip dhcp-client add interface=<INTERFACE_NAME> disable=no

# Example
# We will create a DHCP client binded with WAN bridge
# to request IP address from upstream router.

/ip dhcp-client add interface=WAN disable=no
```

## DHCP Server

### Create an DHCP pool

```console
/ip pool add name=<POOL_NAME> ranges=<IP_START_RANGE>-<IP_END_RANGE>

# Example
/ip pool add name=dhcp_pool ranges=192.168.88.50-192.168.88.200
```

### Create an DHCP server

```console
/ip dhcp-server add \
    interface=<INTERFACE_NAME> \
    server-address=<ROUTER_ADDRESS> \
    address-pool=<POOL_NAME> \
    lease-time=<LEASE_TIME> \
    disabled=no
    
# Example
/ip dhcp-server add \
    interface=LAN \
    server-address=192.168.88.1 \
    address-pool=dhcp_pool \
    lease-time=12h \
    disabled=no
```

Field `server-address` is optional if you are using interface with only 1 IP to be an DHCP server.
But it is recommend to be able to work with my static DNS entry script later on.

### Create DHCP network

```console
/ip dhcp-server network add \
	address=<LOCAL_NETWORK_CIDR> \
	gateway=<ROUTER_IP> \
	dns-server=<ROUTER_IP> \
	domain=<YOUR_LOCAL_DOMAIN>
	
# Example
/ip dhcp-server network add \
    address=192.168.88.0/24 \
    gateway=192.168.88.1 \
    dns-server=192.168.88.1 \
    domain=lan
```

This router will act as an DNS server.

### Add static lease

```console
/ip dhcp-server lease add \
    mac-address=<CLIENT_MAC_ADDRESS> \
    address=<CLIENT_IP_ADDRESS> \
    comment=<COMMENT>

# Example
/ip dhcp-server lease add \
    mac-address=00:11:22:aa:bb:cc \
    address=192.168.88.10 \
    comment="Media server"
```

Note: Static lease should be outside of the pool to prevent conflic.

### Manually create DNS entry for static lease

```console
/ip dns static add \
	address=<IP_ADDRESS> \
	name=<DOMAIN_NAME> \
	ttl=<TIME_TO_LIVE> \
	disabled=no

# Example
/ip dns static add \
	address=192.168.88.10 \
	name=mediaserver.lan \
	ttl=12h \
	disabled=no
```

### Auto create DNS entries for static leases

```console
T.B.D
```

## Firewall

### Input chain

```console
/ip firewall filter add \
	chain=input \
	connection-state=established,related,untracked \
	action=accept \
	comment="Accept established,related,untracked"

/ip firewall filter add \
	chain=input \
	connection-state=invalid \
	action=drop \
	comment="Drop invalid"

/ip firewall filter add \
	chain=input \
	protocol=icmp \
	action=accept \
	comment="Accept ICMP"

/ip firewall filter add \
	chain=input \
	dst-address=127.0.0.1 \
	action=accept \
	comment="Accept to local loopback"

/ip firewall filter add \
	chain=input \
	in-interface=WAN \
	action=drop \
	comment="Drop all traffic from WAN"
```

### Forward chain

```console
/firewall filter add \
	chain=forward \
	connection-state=established,related \
	action=fasttrack-connection \
	comment="Fasttrack for established,related"

/firewall filter add \
	chain=forward \
	connection-state=established,related \
	action=accept \
	comment="Accept established,related"

/firewall filter add \
	chain=forward \
	connection-state=invalid \
	action=drop \
	comment="Drop invalid"

/firewall filter add \
	chain=forward in-interface=WAN \
	action=drop \
	comment="Drop all traffic from WAN not DSTNATed"
```

### NAT

```console
/ip firewall nat add \
	chain=srcnat \
	action=masquerade \
	out-interface=WAN \
	comment="NAT for local network connected to internet"
```
