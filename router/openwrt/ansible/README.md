# OpenWRT Ansible

OpenWRT dumb AP + VLAN management for Xiaomi CR660x (MT7981).

## Playbooks

| Playbook | What | When |
|---|---|---|
| `bootstrap.yml` | Factory → trunk AP | Fresh/reset router, fresh OpenWRT |
| `setup-wireless.yml` | WiFi radios + SSIDs | After bootstrap, reachable via VLAN trunk |
| `backup.yml` | Pull config tarball | Before risky changes |
| `restore.yml` | Push + apply config | Rollback |

## Quickstart

```bash
# After factory reset, router at 192.168.1.1:
ansible-playbook bootstrap.yml -e ansible_host=192.168.1.1

# Unplug LAN, plug trunk into WAN. Router gets DHCP on VLAN 20:
ansible-playbook setup-wireless.yml -e ansible_host=<dhcp_ip>

# Backup:
ansible-playbook backup.yml -e ansible_host=<ip>

# Restore:
ansible-playbook restore.yml -e ansible_host=<ip> -e backup_file=/path/to/backup.tar.gz
```

## Bootstrap order

1. System — hostname, timezone, NTP
2. Dropbear — SSH keys, key-only auth
3. Attended sysupgrade — disable login nag
4. Firewall — ACCEPT all, unassign zones, stop + disable
5. Services — stop + disable firewall, odhcpd
6. Network — remove WAN, bridge VLANs, DHCP on VLAN 20, strip LAN
7. Reboot

## VLAN layout

| VLAN | Name | ID | Purpose |
|---|---|---|---|
| HOME | VLAN_HOME | 20 | Management (DHCP) + LAN clients |
| SERVER | VLAN_SERVER | 50 | Servers |
| CAMERA | VLAN_CAMERA | 100 | Cameras |
| IOT | VLAN_IOT | 110 | IoT devices |
| GUEST | VLAN_GUEST | 150 | Guest network |

## Directory structure

```
ansible/
├── bootstrap.yml
├── setup-wireless.yml
├── backup.yml
├── restore.yml
├── inventory.yml
├── ansible.cfg
├── group_vars/
│   └── all.yml          # shared: timezone, NTP, VLANs, WiFi
├── host_vars/
│   └── cr660x.yml       # per-device: SSIDs, radio config
└── files/
    └── authorized_keys
```
