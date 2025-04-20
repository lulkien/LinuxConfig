#!/usr/bin/env bash

WIREGUARD_CONF_DIR=/etc/wireguard
WIREGUARD_CONF_FILE=${WIREGUARD_CONF_DIR}/wg0.conf
WIREGUARD_NFTABLES_DIR=${WIREGUARD_CONF_DIR}/nftables
WIREGUARD_POSTUP=${WIREGUARD_NFTABLES_DIR}/nftable_up.sh
WIREGUARD_PREDOWN=${WIREGUARD_NFTABLES_DIR}/nftable_down.sh

SERVER_IP=
SERVER_PORT=
SERVER_PRIVATE_KEY=
SERVER_CONFIGURATION=

WIREGUARD_NETWORK=
WIREGUARD_IFACE=wg0
EXTERNAL_IFACE=$(ip route | awk '/default/ {print $5}' | head -1)

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'}
}

check_run_as_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (or with sudo)." >&2
    return 1
  fi
}

check_wireguard_configurated() {
  echo_green "Validating existed Wireguard configuration..."

  if [[ -f ${WIREGUARD_CONF_FILE} ]]; then
    echo "Wireguard configuration file existed. Please remove it manually to run this script."
    return 1
  fi
}

install_wireguard() {
  echo_green "Install Wireguard and tools"

  apt update
  apt install wireguard wireguard-tools qrencode nftables
}

enable_ipv4_forwarding() {
  echo "net.ipv4.ip_forward=1" | tee /etc/sysctl.d/10-wireguard.conf
}

generate_server_configuration() {
  echo_green "Generating server configuration..."

  local server_ip port

  read -p "Enter the WireGuard address (Default: 10.8.0.1): " server_ip
  SERVER_IP=${server_ip:-"10.8.0.1"}

  if [[ ! "$SERVER_IP" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
    echo "ERROR: '$SERVER_IP' is not a valid IPv4 address" >&2
    return 1
  fi

  WG_NETWORK=$(echo "$SERVER_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')

  read -p "Enter the listen port (Default: 51820): " port
  SERVER_PORT=${port:-"51820"}

  if [[ ! "$SERVER_PORT" =~ ^[0-9]+$ ]] || ((SERVER_PORT < 1 || SERVER_PORT > 65535)); then
    echo "ERROR: Port must be between 1-65535" >&2
    return 1
  fi

  echo_green "Generating server private key..."
  SERVER_PRIVATE_KEY=$(wg genkey)

  SERVER_CONFIGURATION="[Interface]
Address = ${SERVER_IP}/24
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIVATE_KEY}
PostUp = ${WIREGUARD_POSTUP}
PreDown = ${WIREGUARD_PREDOWN}"

  if [[ ! -d /etc/wireguard ]]; then
    mkdir /etc/wireguard || return 1
  fi

  echo "$SERVER_CONFIGURATION" | tee ${WIREGUARD_CONF_FILE}
  chmod 600 -R ${WIREGUARD_CONF_DIR}
}

restart_wireguard() {
  echo_green "Restarting wireguard service..."
  systemctl enable wg-quick@wg0.service
  systemctl restart wg-quick@wg0.service
}

create_postup_script() {
  if [[ ! -d ${WIREGUARD_NFTABLES_DIR} ]]; then
    mkdir -p ${WIREGUARD_NFTABLES_DIR}
  fi

  cat >${WIREGUARD_POSTUP} <<EOF
#!/usr/bin/env bash

# NAT Masquerade rule
nft add rule inet nat postrouting ip saddr "$WIREGUARD_NETWORK" oifname "$EXTERNAL_IFACE" masquerade

# Iperf3 exception
nft add rule inet filter input iifname "$WIREGUARD_IFACE" tcp dport 5201 accept comment "Allow Wireguard client to use Iperf3"

# Flowtable configuration
nft add flowtable inet filter ft { hook ingress priority filter ; devices = { $WIREGUARD_IFACE, $EXTERNAL_IFACE } ; }

# Flowtable rule
nft add rule inet filter forward ip protocol { tcp, udp } flow add @ft

# Forwarding rules
nft add rule inet filter forward iifname "$WIREGUARD_IFACE" oifname "$EXTERNAL_IFACE" accept comment "Allow traffic from $WIREGUARD_IFACE to $EXTERNAL_IFACE"
nft add rule inet filter forward iifname "$EXTERNAL_IFACE" oifname "$WIREGUARD_IFACE" drop comment "Block traffic from $EXTERNAL_IFACE to $WIREGUARD_IFACE"
EOF

  chmod +x ${WIREGUARD_POSTUP}
}

create_predown_script() {
  if [[ ! -d ${WIREGUARD_NFTABLES_DIR} ]]; then
    mkdir ${WIREGUARD_NFTABLES_DIR}
  fi

  cat >${WIREGUARD_PREDOWN} <<EOF
#!/usr/bin/env bash

# Delete masquerade rule
nft delete rule inet nat postrouting ip saddr "$WIREGUARD_NETWORK" oifname "$EXTERNAL_IFACE" masquerade 2>/dev/null || true

# Delete iperf3 allow rule
nft delete rule inet filter input iifname "$WIREGUARD_IFACE" tcp dport 5201 accept 2>/dev/null || true

# Delete flowtable rule
nft delete rule inet filter forward ip protocol { tcp, udp } flow add @ft 2>/dev/null || true

# Delete forward allow rule
nft delete rule inet filter forward iifname "$WIREGUARD_IFACE" oifname "$EXTERNAL_IFACE" accept 2>/dev/null || true

# Delete forward block rule
nft delete rule inet filter forward iifname "$EXTERNAL_IFACE" oifname "$WIREGUARD_IFACE" drop 2>/dev/null || true

# Delete flowtable
nft delete flowtable inet filter ft 2>/dev/null || true
EOF

  chmod +x ${WIREGUARD_PREDOWN}
}

# -------------------------------------- MAIN --------------------------------------

main() {
  check_run_as_root || return 1

  check_wireguard_configurated || return 1

  install_wireguard || return 1

  enable_ipv4_forwarding || return 1

  generate_server_configuration || return 1

  create_postup_script || return 1
  create_predown_script || return 1

  restart_wireguard
}

main
