#!/usr/bin/env bash

WIREGUARD_CONF_DIR=/etc/wireguard
WIREGUARD_CONF_FILE=${WIREGUARD_CONF_DIR}/wg0.conf
WIREGUARD_HOOKS=${WIREGUARD_CONF_DIR}/hooks
WIREGUARD_POSTUP=${WIREGUARD_HOOKS}/nftable_up.sh
WIREGUARD_POSTDOWN=${WIREGUARD_HOOKS}/nftable_down.sh

SERVER_IP=10.8.0.1
SERVER_PORT=51820
SERVER_PRIVATE_KEY=
SERVER_CONFIGURATION=

WIREGUARD_NETWORK=10.8.0.0/24
WIREGUARD_IFACE=wg0
EXTERNAL_IFACE=$(ip route | awk '/default/ {print $5}' | head -1)

TABLE_NAME=
ADDRESS_FAMLIFY=

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
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

install_dependencies() {
  echo_green "Install dependencies"

  apt update
  apt install nftables systemd-resolved qrencode

  if [[ ! -d /etc/systemd/resolved.conf.d ]]; then
    mkdir -p /etc/systemd/resolved.conf.d
  fi

  cat >/etc/systemd/resolved.conf.d/10-server.conf <<EOF
[Resolve]
DNS=
FallbackDNS=
DNSStubListener=no
EOF

  systemctl restart systemd-resolved
  systemctl enable systemd-resolved

}

install_wireguard() {
  echo_green "Install Wireguard"

  apt update
  apt install wireguard wireguard-tools
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

  WIREGUARD_NETWORK=$(echo "$SERVER_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')
  echo_green "WIREGUARD_NETWORK = ${WIREGUARD_NETWORK}"

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
PostDown = ${WIREGUARD_POSTDOWN}"

  if [[ ! -d /etc/wireguard ]]; then
    mkdir /etc/wireguard || return 1
  fi

  echo "$SERVER_CONFIGURATION" | tee ${WIREGUARD_CONF_FILE}
  chmod 600 -R ${WIREGUARD_CONF_DIR}
}

restart_wireguard() {
  echo_green "Restarting wireguard service..."
  systemctl restart wg-quick@wg0.service

  echo "Note: Enable 'wg-quick@wg0.service' if you want to autostart Wireguard with systemd."
}

ask_nftables_info() {
  echo_green "Getting nftables info for hooks..."

  local address_family table

  read -p "Enter your default nftables address family (Default: inet):" address_family
  ADDRESS_FAMILY=${address_family:-"inet"}

  read -p "Enter your default nftables table (Default: filter):" table 
  TABLE_NAME=${table:-"filter"}
}

create_postup_script() {
  if [[ ! -d ${WIREGUARD_HOOKS} ]]; then
    mkdir -p ${WIREGUARD_HOOKS}
  fi

  cat >${WIREGUARD_POSTUP} <<EOF
#!/usr/bin/env bash

# Create postrouting chain if not existed
if ! nft list chains | grep -q postrouting; then
  nft add chain ${ADDRESS_FAMILY} ${TABLE_NAME} postrouting '{ type nat hook postrouting priority srcnat; policy accept; }'
fi

nft list tables | grep -q '${ADDRESS_FAMILY} ${TABLE_NAME}' || exit 1
nft list table ${ADDRESS_FAMILY} ${TABLE_NAME} | grep -q 'chain input {' || exit 1
nft list table ${ADDRESS_FAMILY} ${TABLE_NAME} | grep -q 'chain forward {' || exit 1

# Add wireguard input chain
nft add chain ${ADDRESS_FAMILY} ${TABLE_NAME} wg_input
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_input udp dport ${SERVER_PORT} accept comment "Wireguard"
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_input iifname "${WIREGUARD_IFACE}" tcp dport 53 accept comment "DNS"
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_input iifname "${WIREGUARD_IFACE}" udp dport 53 accept comment "DNS"

nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} input jump wg_input

# Add wireguard forward chain and flowtable
nft add flowtable ${ADDRESS_FAMILY} ${TABLE_NAME} fastnat '{ hook ingress priority filter; devices = { ${WIREGUARD_IFACE}, ${EXTERNAL_IFACE} }; }'

nft add chain ${ADDRESS_FAMILY} ${TABLE_NAME} wg_forward
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_forward ip protocol { tcp, udp } flow add @fastnat
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_forward iifname "${WIREGUARD_IFACE}" oifname "${EXTERNAL_IFACE}" accept
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_forward iifname "${EXTERNAL_IFACE}" oifname "${WIREGUARD_IFACE}" drop

nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} forward jump wg_forward

# Add wireguard postrouting chain
nft add chain ${ADDRESS_FAMILY} ${TABLE_NAME} wg_postrouting
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_postrouting ip saddr ${WIREGUARD_NETWORK} oifname "${EXTERNAL_IFACE}" masquerade

nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} postrouting jump wg_postrouting
EOF

  chmod +x ${WIREGUARD_POSTUP}
}

create_predown_script() {
  if [[ ! -d ${WIREGUARD_HOOKS} ]]; then
    mkdir ${WIREGUARD_HOOKS}
  fi

  cat >${WIREGUARD_POSTDOWN} <<EOF
#!/usr/bin/env bash

HANDLE=\$(nft -a list ruleset | grep 'jump wg_input' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule ${ADDRESS_FAMILY} ${TABLE_NAME} input handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'jump wg_forward' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule ${ADDRESS_FAMILY} ${TABLE_NAME} forward handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'flowtable fastnat' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete flowtable ${ADDRESS_FAMILY} ${TABLE_NAME} handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'jump wg_postrouting' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule ${ADDRESS_FAMILY} ${TABLE_NAME} postrouting handle \${HANDLE}

nft delete chain ${ADDRESS_FAMLIFY} ${TABLE_NAME} wg_input
nft delete chain ${ADDRESS_FAMLIFY} ${TABLE_NAME} wg_forward
nft delete chain ${ADDRESS_FAMLIFY} ${TABLE_NAME} wg_postrouting

ip link set ${WIREGUARD_IFACE} down
ip link delete ${WIREGUARD_IFACE}
EOF

  chmod +x ${WIREGUARD_POSTDOWN}
}

# -------------------------------------- MAIN --------------------------------------

main() {
  check_run_as_root || return 1

  check_wireguard_configurated || return 1

  install_dependencies || return 1

  install_wireguard || return 1

  enable_ipv4_forwarding || return 1

  generate_server_configuration || return 1

  ask_nftables_info || return 1
  create_postup_script || return 1
  create_predown_script || return 1

  restart_wireguard
}

main
