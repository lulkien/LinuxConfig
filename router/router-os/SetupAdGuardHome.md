# How to setup AdGuardHome on Router OS

## Enable container

```
/system/device-mode/update container=yes

# Now unplug power or press power button and wait until router is up

/system/package/enable container
```

## Create bridge for dockers

```
# Create new bridge
/interface bridge add name=dockers

# Add ip address for the bidge
/ip address add address=10.244.0.1/24 network=10.244.0.0 interface=dockers

# Create virtual ethernet interface
/interface veth add name=veth1-agh address=10.244.0.2/24 gateway=10.244.0.1

# Add it into our bridge
/interface bridge port add bridge=dockers interface=veth1-agh
```

## Setup container

```
# Setup location to put dockers
/file add type=directory name=dockers

# Config the container
/container config set ram-high=2G registry-url="https://registry.hub.docker.com"

# Add AdGuardHome image
/container add remote-image="adguard/adguardhome:latest" interface=veth1-agh root-dir=dockers/adguardhome start-on-boot=yes logging=yes 

# Print the container (the AdGuardHome container should have status=stopped)
/container print

# Assume the index of AdGuardHome is 0, we can start it
/container/start number=0
```

## Config firewall

Add firewall rules for dockers bridge

```
/ip firewall filter add chain=input in-interface=dockers comment="Allow traffic from dockers bridge"
/ip firewall filter add chain=forward in-interface=dockers comment="Forward traffic to dockers"
/ip firewall filter add chain=forward out-interface=dockers comment="Forward traffic from dockers"
```

## Use the new DNS

```
/ip dns set servers="10.244.0.2"
```
