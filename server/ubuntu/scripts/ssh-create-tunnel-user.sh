#!/usr/bin/env bash

echo_red() {
  echo -e '\e[1;31m'"$@"'\e[00m'
}

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

# Configuration
USERNAME="trencher"
SHELL="/usr/bin/true"
HOME_DIR="/home/$USERNAME"
SSH_GROUP="$USERNAME"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo_red "This script must be run as root"
  exit 1
fi

# Check if user existed
if id "$USERNAME" &>/dev/null; then
  echo_red "User $USERNAME existed. Exit"
  exit 1
fi

echo_green "Creating system user $USERNAME..."
if ! useradd --system --shell "$SHELL" --home-dir "$HOME_DIR" --create-home "$USERNAME"; then
  echo_red "Failed to create user $USERNAME"
  exit 1
fi

# Lock the password (force key-based auth)
passwd -l "$USERNAME"

# Set up SSH directory
echo_green "Configuring SSH environment..."
mkdir -p "$HOME_DIR/.ssh"
chown "$USERNAME:$USERNAME" "$HOME_DIR/.ssh"
chmod 700 "$HOME_DIR/.ssh"

touch "$HOME_DIR/.ssh/authorized_keys"
chown "$USERNAME:" "$HOME_DIR/.ssh/authorized_keys"
chmod 600 "$HOME_DIR/.ssh/authorized_keys"

# Configure sshd restrictions
echo_green "Adding SSH restrictions..."
echo -e "# Restrictions for $USERNAME
Match User $USERNAME
    PermitOpen localhost:*
    AllowTcpForwarding yes
    PermitTunnel yes
    X11Forwarding no
    AllowAgentForwarding no
    PermitTTY no
    ForceCommand /bin/false" >/etc/ssh/sshd_config.d/sshtunuser.conf

# Set resource limits
echo_green "Setting resource limits..."
echo -e "# Limits for $USERNAME
$USERNAME hard maxlogins 1
$USERNAME hard nproc 50" >/etc/security/limits.d/sshtunuser.conf

# Restart SSH service
echo_green "Restarting SSH service..."
systemctl restart ssh.service
