#!/usr/bin/env bash

WIREGUARD_GATEWAY=10.8.0.1
WIREGUARD_NETWORK=10.8.0.0/24
WIREGUARD_PORT=51820
WIREGUARD_IFACE=wg0
EXTERNAL_IFACE=$(ip route | awk '/default/ {print $5}' | head -1)

ADDRESS_FAMLIFY=inet
TABLE_NAME=filter

# ------------------------ DO NOT MODIFY --------------------------
WIREGUARD_CONF_DIR=/etc/wireguard                                 #
WIREGUARD_CONF_FILE=${WIREGUARD_CONF_DIR}/${WIREGUARD_IFACE}.conf #
WIREGUARD_HOOKS=${WIREGUARD_CONF_DIR}/hooks                       #
WIREGUARD_POSTUP=${WIREGUARD_HOOKS}/nftable_up.sh                 #
WIREGUARD_POSTDOWN=${WIREGUARD_HOOKS}/nftable_down.sh             #
# -----------------------------------------------------------------

DRY_RUN=false
DEFAULT=false

# -----------------------------------------

generate_server_configuration() {
    echo "Generate server configuration."

    echo "  Create server private key"
    local wg_private_key=$(wg genkey)

    if ! $DEFAULT; then
        local wg_gateway=
        local wg_port=

        read -p "  Enter the WireGuard gateway address (Default: ${WIREGUARD_GATEWAY}): " wg_gateway
        WIREGUARD_GATEWAY=${wg_gateway:-${WIREGUARD_GATEWAY}}

        if [[ ! "${WIREGUARD_GATEWAY}" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
            echo "    ERROR: '${WIREGUARD_GATEWAY}' is not a valid IPv4 address" >&2
            return 1
        fi

        WIREGUARD_NETWORK=$(echo "${WIREGUARD_GATEWAY}" | awk -F. '{print $1"."$2"."$3".0/24"}')

        read -p "  Enter the listen port (Default: ${WIREGUARD_PORT}): " wg_port
        WIREGUARD_PORT=${wg_port:-${WIREGUARD_PORT}}

        if [[ ! "${WIREGUARD_PORT}" =~ ^[0-9]+$ ]] || ((WIREGUARD_PORT < 1 || WIREGUARD_PORT > 65535)); then
            echo "    ERROR: Port must be between 1-65535" >&2
            return 1
        fi
    else
        echo "  Use default configuration:"
    fi

    echo "    Interface: ${WIREGUARD_IFACE}"
    echo "    Gateway:   ${WIREGUARD_GATEWAY}"
    echo "    Network:   ${WIREGUARD_NETWORK}"
    echo "    Port:      ${WIREGUARD_PORT}"

    if [[ ! -d /etc/wireguard ]]; then
        mkdir /etc/wireguard || return 1
    fi

    cat >${WIREGUARD_CONF_FILE} <<EOF
[Interface]
Address = ${WIREGUARD_GATEWAY}/24
ListenPort = ${WIREGUARD_PORT}
PrivateKey = ${wg_private_key}
PostUp = ${WIREGUARD_POSTUP}
PostDown = ${WIREGUARD_POSTDOWN}
EOF

    chmod 600 -R ${WIREGUARD_CONF_DIR}
}

# -----------------------------------------

ask_nftables_info() {
    echo "Get nftables info."

    if ! $DEFAULT; then
        local address_family=
        local table=

        read -p "  Enter your default nftables address family (Default: ${ADDRESS_FAMILY}):" address_family
        ADDRESS_FAMILY=${address_family:-${ADDRESS_FAMILY}}

        read -p "  Enter your default nftables table (Default: ${TABLE_NAME}):" table
        TABLE_NAME=${table:-${TABLE_NAME}}
    else
        echo "  Use default configuration:"
    fi

    echo "    Current address family: ${ADDRESS_FAMILY}"
    echo "    Current table name:     ${TABLE_NAME}"
}

# -----------------------------------------

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
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_input udp dport ${WIREGUARD_PORT} accept comment "Wireguard"
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
nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} wg_postrouting iifname "${WIREGUARD_IFACE}" ip saddr ${WIREGUARD_NETWORK} oifname "${EXTERNAL_IFACE}" masquerade

nft add rule  ${ADDRESS_FAMILY} ${TABLE_NAME} postrouting jump wg_postrouting
EOF

    chmod +x ${WIREGUARD_POSTUP}
}

# -----------------------------------------

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
    if [[ $EUID -ne 0 ]]; then
        echo "ERROR: This script must be run as root (or with sudo)." >&2
        return 1
    fi

    echo "Validate existed Wireguard configuration."
    if [[ -f ${WIREGUARD_CONF_FILE} ]]; then
        echo "  Wireguard configuration file existed."
        echo "  Please remove it manually to run this script."
        return 1
    fi

    echo "Install wireguard and dependencies."
    apt update
    apt install nftables systemd-resolved wireguard wireguard-tools

    echo "Enable ipv4 forwarding."
    echo "net.ipv4.ip_forward=1" >/etc/sysctl.d/10-wireguard.conf

    generate_server_configuration || return 1

    ask_nftables_info || return 1

    create_postup_script || return 1

    create_predown_script || return 1

    echo "Restarting wireguard service..."
    systemctl restart wg-quick@wg0.service
}

main
