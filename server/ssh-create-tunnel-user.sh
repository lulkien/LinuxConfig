#!/usr/bin/env bash

# Default configuration (can be overridden by environment variables)
: "${TUNNEL_USER:=trencher}"
: "${TUNNEL_SHELL:=/usr/bin/true}"
: "${TUNNEL_HOME:=/var/lib/${TUNNEL_USER}}"
: "${TUNNEL_SSH_GROUP:=${TUNNEL_USER}}"
: "${TUNNEL_SSHD_CONFIG_DIR:=/etc/ssh/sshd_config.d}"
: "${TUNNEL_LIMITS_DIR:=/etc/security/limits.d}"
: "${TUNNEL_MAX_LOGINS:=10}"
: "${TUNNEL_NPROC:=50}"

echo_red() {
    echo -e '\e[1;31m'"$@"'\e[00m' >&2
}

echo_green() {
    echo -e '\e[1;32m'"$@"'\e[00m' >&2
}

echo_yellow() {
    echo -e '\e[1;33m'"$@"'\e[00m' >&2
}

# Show configuration
echo_green "=== Configuration ===" >&2
echo "  USERNAME:        $TUNNEL_USER"
echo "  SHELL:           $TUNNEL_SHELL"
echo "  HOME_DIR:        $TUNNEL_HOME"
echo "  SSH_GROUP:       $TUNNEL_SSH_GROUP"
echo "  MAX_LOGINS:      $TUNNEL_MAX_LOGINS"
echo "  NPROC:           $TUNNEL_NPROC"
echo "  SSHD_CONFIG_DIR: $TUNNEL_SSHD_CONFIG_DIR"
echo "  LIMITS_DIR:      $TUNNEL_LIMITS_DIR"
echo ""

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo_red "This script must be run as root"
    exit 1
fi

# Check if user existed
if id "$TUNNEL_USER" &>/dev/null; then
    echo_red "User $TUNNEL_USER already exists. Exit"
    exit 1
fi

# Show what will be created
echo_yellow "The following actions will be performed:" >&2
echo "  • Create system user: $TUNNEL_USER"
echo "  • Create home directory: $TUNNEL_HOME"
echo "  • Set up SSH directory: $TUNNEL_HOME/.ssh"
echo "  • Create SSH config: ${TUNNEL_SSHD_CONFIG_DIR}/sshtunuser.conf"
echo "  • Create limits config: ${TUNNEL_LIMITS_DIR}/sshtunuser.conf"
echo "  • Restart SSH service"
echo ""

# Confirmation prompt (prompt goes to stderr, but we need to read from stdin)
echo_yellow "Do you want to continue? (y/N) " >&2
read -n 1 -r
echo >&2
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo_red "Operation cancelled by user"
    exit 0
fi

echo_green "Proceeding with setup..." >&2
echo ""

# Create system user
echo_green "Creating system user $TUNNEL_USER..." >&2
if ! useradd --system --shell "$TUNNEL_SHELL" --home-dir "$TUNNEL_HOME" --create-home "$TUNNEL_USER"; then
    echo_red "Failed to create user $TUNNEL_USER"
    exit 1
fi

# Lock the password (force key-based auth)
passwd -l "$TUNNEL_USER" >/dev/null 2>&1
echo "  ✓ Password locked" >&2

# Set up SSH directory
echo_green "Configuring SSH environment..." >&2
mkdir -p "$TUNNEL_HOME/.ssh"
chown "$TUNNEL_USER:$TUNNEL_USER" "$TUNNEL_HOME/.ssh"
chmod 700 "$TUNNEL_HOME/.ssh"
echo "  ✓ Created .ssh directory" >&2

touch "$TUNNEL_HOME/.ssh/authorized_keys"
chown "$TUNNEL_USER:$TUNNEL_USER" "$TUNNEL_HOME/.ssh/authorized_keys"
chmod 600 "$TUNNEL_HOME/.ssh/authorized_keys"
echo "  ✓ Created authorized_keys file" >&2

# Configure sshd restrictions
echo_green "Adding SSH restrictions..." >&2

# Create sshd_config.d directory if it doesn't exist
mkdir -p "$TUNNEL_SSHD_CONFIG_DIR"

SSHD_CONFIG="${TUNNEL_SSHD_CONFIG_DIR}/sshtunuser.conf"
cat >"$SSHD_CONFIG" <<EOF
# Restrictions for $TUNNEL_USER - Created $(date)
Match User $TUNNEL_USER
    AuthorizedKeysFile ${TUNNEL_HOME}/.ssh/authorized_keys
    PermitTTY no
    X11Forwarding no
    AllowTcpForwarding yes
    PermitTunnel yes
    GatewayPorts yes
    ForceCommand /bin/false
EOF
echo "  ✓ Created SSH config: $SSHD_CONFIG" >&2

# Set resource limits
echo_green "Setting resource limits..." >&2

# Create limits.d directory if it doesn't exist
mkdir -p "$TUNNEL_LIMITS_DIR"

LIMITS_CONFIG="${TUNNEL_LIMITS_DIR}/sshtunuser.conf"
cat >"$LIMITS_CONFIG" <<EOF
# Limits for $TUNNEL_USER - Created $(date)
$TUNNEL_USER hard maxlogins $TUNNEL_MAX_LOGINS
$TUNNEL_USER hard nproc $TUNNEL_NPROC
EOF
echo "  ✓ Created limits config: $LIMITS_CONFIG" >&2

# Test SSH configuration before restarting
echo_green "Testing SSH configuration..." >&2
if ! sshd -t; then
    echo_red "SSH configuration test failed! Aborting restart."
    echo_yellow "Please check: $SSHD_CONFIG" >&2
    exit 1
fi
echo "  ✓ SSH configuration test passed" >&2

# Restart SSH service
echo_green "Restarting SSH service..." >&2
if systemctl is-active --quiet ssh.service; then
    systemctl restart ssh.service
    echo "  ✓ Restarted ssh.service" >&2
elif systemctl is-active --quiet sshd.service; then
    systemctl restart sshd.service
    echo "  ✓ Restarted sshd.service" >&2
else
    echo_red "Could not detect SSH service name. Please restart SSH manually."
    exit 1
fi

echo "" >&2
echo_green "=== Setup Complete! ===" >&2
echo "  User: $TUNNEL_USER" >&2
echo "  Home: $TUNNEL_HOME" >&2
echo "" >&2
echo_yellow "Next steps:" >&2
echo "  1. Add public keys to: $TUNNEL_HOME/.ssh/authorized_keys" >&2
echo "  2. Test the connection: ssh $TUNNEL_USER@localhost" >&2
echo "" >&2
echo_green "Done." >&2
