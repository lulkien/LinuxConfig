#!/usr/bin/env bash

WIREGUARD_CONF_DIR=/etc/wireguard
WIREGUARD_CONF_FILE=${WIREGUARD_CONF_DIR}/wg0.conf
WIREGUARD_NFTABLES_DIR=${WIREGUARD_CONF_DIR}/nftables
WIREGUARD_POSTUP=${WIREGUARD_NFTABLES_DIR}/nftable_up.sh
WIREGUARD_PREDOWN=${WIREGUARD_NFTABLES_DIR}/nftable_down.sh

SERVER_IP=10.8.0.1
SERVER_PORT=51820
SERVER_PRIVATE_KEY=
SERVER_CONFIGURATION=

WIREGUARD_NETWORK=10.8.0.0/24
WIREGUARD_IFACE=wg0
EXTERNAL_IFACE=$(ip route | awk '/default/ {print $5}' | head -1)

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
PreDown = ${WIREGUARD_PREDOWN}"

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

create_postup_script() {
  if [[ ! -d ${WIREGUARD_NFTABLES_DIR} ]]; then
    mkdir -p ${WIREGUARD_NFTABLES_DIR}
  fi

  cat >${WIREGUARD_POSTUP} <<EOF
#!/usr/bin/env bash

nft list tables | grep -q 'inet default' || exit 1
nft list table inet default | grep -q 'chain input' || exit 1
nft list table inet default | grep -q 'chain forward' || exit 1
nft list table inet default | grep -q 'chain postrouting' || exit 1

nft add rule inet default postrouting ip saddr ${WIREGUARD_NETWORK} oifname "${EXTERNAL_IFACE}" masquerade

nft add rule inet default input udp dport ${SERVER_PORT} accept
nft add rule inet default input iifname "${WIREGUARD_IFACE}" tcp dport 5201 accept
nft add rule inet default input iifname "${WIREGUARD_IFACE}" tcp dport 53 accept
nft add rule inet default input iifname "${WIREGUARD_IFACE}" udp dport 53 accept

nft add flowtable inet default ft '{ hook ingress priority filter ; devices = { ${WIREGUARD_IFACE}, ${EXTERNAL_IFACE} } ; }'
nft add rule inet default forward ip protocol { tcp, udp } flow add @ft

nft add rule inet default forward iifname "${WIREGUARD_IFACE}" oifname "${EXTERNAL_IFACE}" accept
EOF

  chmod +x ${WIREGUARD_POSTUP}
}

create_predown_script() {
  if [[ ! -d ${WIREGUARD_NFTABLES_DIR} ]]; then
    mkdir ${WIREGUARD_NFTABLES_DIR}
  fi

  cat >${WIREGUARD_PREDOWN} <<EOF
#!/usr/bin/env bash

HANDLE=\$(nft -a list ruleset | grep 'ip saddr ${WIREGUARD_NETWORK} oifname "${EXTERNAL_IFACE}" masquerade' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default postrouting handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'iifname "${WIREGUARD_IFACE}" tcp dport 5201 accept' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default input handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'iifname "${WIREGUARD_IFACE}" tcp dport 53 accept' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default input handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'iifname "${WIREGUARD_IFACE}" udp dport 53 accept' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default input handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'udp dport ${SERVER_PORT} accept' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default input handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'ip protocol { tcp, udp } flow add @ft' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default forward handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'iifname "${WIREGUARD_IFACE}" oifname "${EXTERNAL_IFACE}" accept' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete rule inet default forward handle \${HANDLE}

HANDLE=\$(nft -a list ruleset | grep 'flowtable ft' | awk '{print \$NF}' | tr -d ')')
[[ -n "\${HANDLE}" ]] && nft delete flowtable inet default handle \${HANDLE}

ip link set ${WIREGUARD_IFACE} down
ip link delete ${WIREGUARD_IFACE}
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
