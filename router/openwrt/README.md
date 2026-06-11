# OpenWRT Dumb AP — Ansible Automation

Converts a factory-fresh OpenWRT router into a VLAN-aware dumb access point.
Four WiFi networks on separate VLANs, trunked to a core switch via the WAN port.

## What you get

```
                    ┌─────────────────────┐
   Core Switch ─── trunk ─── WAN port     │
                    │                     │
                    │  br-lan bridge      │
                    │  ├─ lan1,lan2,lan3  │── untagged VLAN 20 (HOME)
                    │  ├─ br-lan.20       │── DHCP client (management)
                    │  ├─ br-lan.100      │── CAMERA VLAN (WiFi only)
                    │  ├─ br-lan.110      │── IOT VLAN (WiFi only)
                    │  └─ br-lan.150      │── GUEST VLAN (WiFi only)
                    │                     │
                    │  WiFi SSIDs:        │
                    │  ├─ OpenWrt_Home    │── 5GHz WPA3 → VLAN 20
                    │  ├─ OpenWrt_IoT     │── 2.4GHz → VLAN 110
                    │  ├─ OpenWrt_Guest   │── 2.4GHz → VLAN 150
                    │  └─ OpenWrt_Camera  │── 2.4GHz → VLAN 100
                    └─────────────────────┘
```

## Files

```
openwrt/
├── backup/                     # source of truth — 5 config files
│   └── etc/
│       ├── config/
│       │   ├── network         # bridge, VLANs, trunk, DHCP on VLAN 20
│       │   ├── wireless        # 4 SSIDs mapped to VLANs
│       │   ├── dhcp            # dnsmasq (DHCP server disabled)
│       │   └── system          # hostname, timezone, NTP
│       └── dropbear/
│           └── authorized_keys # your SSH public key
│
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.yml           # router list + groups
│   ├── group_vars/
│   │   ├── all.yml             # timezone, VLAN IDs
│   │   └── mt7981.yml          # radio PCI paths (per chipset)
│   ├── host_vars/
│   │   └── openwrtf1.yml       # hostname, SSIDs, WiFi passwords
│   ├── bootstrap.yml           # factory → trunk AP (one shot)
│   ├── deploy.yml              # idempotent sync (ongoing)
│   └── backup.yml              # pull config snapshot from router
└── .gitignore
```

## First-time setup (bootstrap)

Do this ONCE per router, after factory reset.

```
1. Factory reset the router (hold reset button, or first boot)
2. Plug your machine into a LAN port (lan1/2/3)
3. The router serves 192.168.1.1 — SSH in to confirm:
     ssh root@192.168.1.1
4. Install the Ansible collection:
     ansible-galaxy collection install community.openwrt
5. Run bootstrap:
     ansible-playbook ansible/bootstrap.yml -e ansible_host=192.168.1.1
6. Playbook deploys everything, restarts network, SSH drops
7. Unplug your machine from LAN port
8. Plug trunk link (from core switch) into WAN port
9. Router gets DHCP on VLAN 20 — check core switch for the new IP
```

## Ongoing management (deploy)

Run anytime to sync config changes from backup/ to the router.

```
ansible-playbook ansible/deploy.yml -e ansible_host=<router_ip>
```

Safe to run repeatedly — only applies what changed.

Dry-run to see what would change:
```
ansible-playbook ansible/deploy.yml -e ansible_host=<router_ip> --check --diff
```

Deploy specific parts:
```
ansible-playbook ansible/deploy.yml -e ansible_host=<ip> --tags wireless
ansible-playbook ansible/deploy.yml -e ansible_host=<ip> --tags network
```

## Pull backup from router

Save current router config as a snapshot:
```
ansible-playbook ansible/backup.yml -e ansible_host=<router_ip>
```

Saves to `backups/<hostname>/<timestamp>/`.

## Adding a new router

1. Add to `ansible/inventory.yml`:
   ```yaml
   cr660x-f4:
     ansible_user: root
   ```

2. Create `ansible/host_vars/cr660x-f4.yml`:
   ```yaml
   hostname: "OpenWrtF4"
   wifi_home:
     radio: "radio1"
     ssid: "MySSID"
     encryption: "sae"
     key: "my-password"
     network: "VLAN_HOME"
     ...
   ```

3. Bootstrap it.

## Encrypting secrets

WiFi passwords are in `host_vars/*.yml`. Encrypt with:
```
ansible-vault encrypt ansible/host_vars/openwrtf1.yml
ansible-playbook ... --ask-vault-pass
```

## Requirements

- Ansible core >= 2.18
- `community.openwrt` collection
- OpenWRT 23.05+ on the router
- No Python needed on the router
