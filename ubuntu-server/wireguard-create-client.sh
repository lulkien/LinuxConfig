#!/usr/bin/env bash

# Client info
CLIENT_NAME=
CLIENT_PUBKEY=
CLIENT_PRIVATE_KEY=
CLIENT_ADDRESS=

# Wireguard server info
SERVER_ADDRESS=
SERVER_LISTEN_PORT=
SERVER_PUBKEY=
WIREGUARD_CONF_FILE=/etc/wireguard/wg0.conf

# Server info
PUBLIC_IP_ADDRESS=

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

check_run_as_root() {
  if [[ $EUID -ne 0 ]]; then
    echo "ERROR: This script must be run as root (or with sudo)." >&2
    return 1
  fi
}

get_ip_address() {
  echo_green "Get public ip address"

  local interface candidate public_ip

  while IFS= read -r candidate; do
    if ip -4 addr show dev "$candidate" >/dev/null 2>&1; then
      interface=$candidate
      break
    fi
  done < <(ip -o link show | awk -F': ' '$2 ~ /^(eth|ens|enp|eno)/ {print $2}')

  if [[ -z "$interface" ]]; then
    interface=$(ip -4 route show default | awk '/default/ {print $5; exit}')
    if [[ -z "$interface" ]]; then
      echo "ERROR: Could not determine network interface" >&2
      return 1
    fi
  fi

  public_ip=$(ip -4 addr show dev "$interface" 2>/dev/null |
    awk '/inet / {split($2, a, "/"); print a[1]; exit}')

  if [[ -z "$public_ip" ]]; then
    echo "ERROR: Could not determine IP address for interface $interface" >&2
    return 1
  fi

  PUBLIC_IP_ADDRESS=$public_ip
  return 0
}

get_server_info() {
  echo_green "Get Wireguard server information"

  if [[ ! -r "$WIREGUARD_CONF_FILE" ]]; then
    echo "ERROR: WireGuard config file not found or not readable at $WIREGUARD_CONF_FILE" >&2
    return 1
  fi

  local address_line
  local server_address
  local port_line
  local server_listen_port
  local private_key_line
  local server_pubkey

  if ! address_line=$(grep -E "^Address\s*=" "$WIREGUARD_CONF_FILE" | head -n1); then
    echo "ERROR: Could not find Address in config file" >&2
    return 1
  fi

  server_address=${address_line#*=}
  server_address=${server_address%%/*}
  server_address=${server_address//[[:space:]]/}

  if [[ -z "$server_address" ]]; then
    echo "ERROR: Could not determine server Address" >&2
    return 1
  fi

  if ! port_line=$(grep -E "^ListenPort\s*=" "$WIREGUARD_CONF_FILE"); then
    echo "ERROR: Could not find ListenPort in config file" >&2
    return 1
  fi

  server_listen_port=${port_line#*=}
  server_listen_port=${server_listen_port//[[:space:]]/}

  if [[ -z "$server_listen_port" ]]; then
    echo "ERROR: Could not determine server ListenPort" >&2
    return 1
  fi

  if ! private_key_line=$(grep -E "^PrivateKey\s*=" "$WIREGUARD_CONF_FILE"); then
    echo "ERROR: Could not find PrivateKey in config file" >&2
    return 1
  fi

  server_pubkey=${private_key_line#*=}
  server_pubkey=${server_pubkey//[[:space:]]/}

  if ! server_pubkey=$(wg pubkey <<<"$server_pubkey"); then
    echo "ERROR: Failed to generate public key from private key" >&2
    return 1
  fi

  if [[ -z "$server_pubkey" ]]; then
    echo "ERROR: Could not determine server public key" >&2
    return 1
  fi

  SERVER_ADDRESS=$server_address
  SERVER_LISTEN_PORT=$server_listen_port
  SERVER_PUBKEY=$server_pubkey

  return 0
}

ask_client_name() {
  read -rp "Enter client name: " CLIENT_NAME || return 1

  # Validate input
  if [[ -z "$CLIENT_NAME" ]]; then
    echo "ERROR: Client name cannot be empty" >&2
    return 1
  fi

  if [[ "$CLIENT_NAME" =~ [[:space:]] ]]; then
    echo "ERROR: Client name cannot contain spaces" >&2
    return 1
  fi

  if [[ "$CLIENT_NAME" =~ [^a-zA-Z0-9_-] ]]; then
    echo "ERROR: Client name can only contain letters, numbers, hyphens and underscores" >&2
    return 1
  fi

  if [[ -f "$WIREGUARD_CONF_FILE" ]] &&
    grep -qFx "# $CLIENT_NAME" "$WIREGUARD_CONF_FILE" 2>/dev/null; then
    echo "ERROR: Client '$CLIENT_NAME' already exists in config" >&2
    return 1
  fi

  return 0
}

ask_dns_server() {
  read -rp "Enter DNS server IP [Default: $PUBLIC_IP_ADDRESS]: " DNS_SERVER

  DNS_SERVER=${DNS_SERVER:-$PUBLIC_IP_ADDRESS}

  if [[ ! "$DNS_SERVER" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
    echo "ERROR: '$DNS_SERVER' is not a valid IPv4 address" >&2
    return 1
  fi

  return 0
}

generate_client_keypair() {
  echo_green "Generating keys for $CLIENT_NAME..."

  local private_key
  local public_key

  private_key=$(wg genkey)

  if ! public_key=$(wg pubkey <<<"${private_key}"); then
    echo "ERROR: Failed to generate public key" >&2
    return 1
  fi

  CLIENT_PRIVATE_KEY="${private_key}"
  CLIENT_PUBKEY="${public_key}"

  return 0
}

generate_client_ip() {
  echo_green "Generating IP address for new client..."

  local last_ip current_ip a b c d

  if [[ -f "$WIREGUARD_CONF_FILE" ]]; then
    last_ip=$(grep "AllowedIPs" "$WIREGUARD_CONF_FILE" 2>/dev/null |
      tail -n 1 |
      awk -F'=' '{print $2}' |
      tr -d ' ' |
      cut -d'/' -f1)
  fi

  current_ip="${last_ip:-$SERVER_ADDRESS}"

  if [[ ! "$current_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Invalid IP address format '$current_ip'" >&2
    return 1
  fi

  IFS='.' read -r a b c d <<<"$current_ip"

  if ((d >= 254)); then
    echo "ERROR: IP range exhausted (reached 254)" >&2
    return 1
  fi

  CLIENT_ADDRESS="$a.$b.$c.$((d + 1))"

  if [[ ! "$CLIENT_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Failed to generate valid client IP" >&2
    return 1
  fi

  return 0
}

add_client_to_server() {
  echo_green "Add new client to server"

  if [[ ! -w "$WIREGUARD_CONF_FILE" ]]; then
    echo "ERROR: Cannot write to WireGuard config file $WIREGUARD_CONF_FILE" >&2
    return 1
  fi

  if [[ ! "$CLIENT_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "ERROR: Invalid client IP address format '$CLIENT_ADDRESS'" >&2
    return 1
  fi

  if ! {
    echo
    echo "# ${CLIENT_NAME}"
    echo "[Peer]"
    echo "PublicKey = ${CLIENT_PUBKEY}"
    echo "AllowedIPs = ${CLIENT_ADDRESS}/32"
  } | tee -a "$WIREGUARD_CONF_FILE" >/dev/null; then
    echo "ERROR: Failed to write to config file" >&2
    return 1
  fi

  if ! grep -qFx "# ${CLIENT_NAME}" "$WIREGUARD_CONF_FILE"; then
    echo "ERROR: Failed to add client to config file" >&2
    return 1
  fi

  echo "Successfully added client ${CLIENT_NAME} to server config"
  return 0
}

export_client_config() {
  local client_config="[Interface]
PrivateKey = ${CLIENT_PRIVATE_KEY}
Address = ${CLIENT_ADDRESS}/24
DNS = ${DNS_SERVER}

[Peer]
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${PUBLIC_IP_ADDRESS}:${SERVER_LISTEN_PORT}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
"

  # Display configuration
  echo
  echo_green "=== Client Configuration ==="
  echo "----------------------------------------"
  echo "$client_config"
  echo "----------------------------------------"

  if command -v qrencode &>/dev/null; then
    echo
    echo "QR Code:"
    echo "$client_config" | qrencode -t ansiutf8
  fi

  local config_file="${HOME}/${CLIENT_NAME:-wireguard-client}.conf"
  if echo "$client_config" >"$config_file"; then
    echo
    echo "Configuration saved to:"
    echo "  $config_file"
    echo
    echo "You can transfer this to your client device using:"
    echo "  scp '${config_file}' user@client-machine:~/"
  else
    echo "ERROR: Failed to save configuration to $config_file" >&2
    return 1
  fi

  return 0
}

restart_wireguard() {
  echo_green "Restarting wireguard service..."
  systemctl restart wg-quick@wg0.service
}

main() {
  check_run_as_root || return 1
  get_ip_address || return 1
  get_server_info || return 1

  ask_client_name || return 1
  ask_dns_server || return 1

  generate_client_keypair || return 1
  generate_client_ip || return 1

  add_client_to_server || return 1
  export_client_config || return 1

  restart_wireguard
}

main
