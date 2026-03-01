#!/usr/bin/env bash

# Install ethtool
apt install -y ethtool

# Create ethtool-tailscale service for tailscale
NETDEV=$(ip -o route get 8.8.8.8 | cut -f 5 -d " ")

cat >/etc/systemd/system/ethtool-tailscale.service <<EOF
[Unit]
Description=Set UDP GRO forwarding options for Tailscale
Before=network-pre.target tailscaled.service
Wants=network-pre.target
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/usr/sbin/ethtool -K ${NETDEV} rx-udp-gro-forwarding on rx-gro-list off
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Set kernel parameter for tailscale traffic
cat >/etc/sysctl.d/99-tailscale.conf <<EOF
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sysctl -p /etc/sysctl.d/99-tailscale.conf

# Make nftables depend on tailscale
if [[ ! -d /etc/systemd/system/nftables.service.d ]]; then
    mkdir -p /etc/systemd/system/nftables.service.d
fi

cat >/etc/systemd/system/nftables.service.d/override.conf <<EOF
[Unit]
After=tailscaled.service network-pre.target
Requires=tailscaled.service
EOF

# Make tailscale depend on ethtool-tailscale
if [[ ! -d /etc/systemd/system/tailscaled.service.d ]]; then
    mkdir -p /etc/systemd/system/tailscaled.service.d
fi

cat >/etc/systemd/system/tailscaled.service.d/override.conf <<EOF
[Unit]
After=ethtool-tailscale.service
Requires=ethtool-tailscale.service
EOF

# Reload daemon
systemctl daemon-reload
