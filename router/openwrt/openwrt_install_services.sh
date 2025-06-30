#!/bin/ash

################ YOUR CONFIG ################

IPERF3=false
SSH_SERVER=false

################### MAIN SCRIPT ####################

echo "==========================================="
echo "Update list package"
opkg update

if [ $? -ne 0 ]; then
  echo "Failed to update package. Reconfig datetime, reboot then retry."
  exit 1
fi

################### INSTALL IPERF3 ####################

if [ "$IPERF3" = true ]; then
  echo "==========================================="
  echo "Install iperf3"
  opkg install iperf3

  echo "-------------------------------------------"
  echo "Now try to run iperf3."
  echo "If everything is ok, put this line before exit 0 in /etc/rc.local"
  echo "    /usr/bin/iperf3 --server --daemon --logfile /tmp/iperf3.log"
fi

################### INSTALL SSH SERVER ####################

if [ "$SSH_SERVER" = true ]; then
  echo "==========================================="
  echo "Set dropbear port = 2222"
  uci set dropbear.@dropbear[0].Port=2222
  uci commit dropbear
  /etc/init.d/dropbear restart

  echo "-------------------------------------------"
  echo "Install openssh-server and openssh-sftp-server"
  opkg install openssh-server openssh-sftp-server

  echo "-------------------------------------------"
  echo "Allow root login"
  sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

  echo "-------------------------------------------"
  echo "Link authorized_keys"
  mkdir /root/.ssh/
  ln -s /etc/dropbear/authorized_keys /root/.ssh/

  echo "-------------------------------------------"
  echo "Enable sshd"
  /etc/init.d/sshd enable
  /etc/init.d/sshd restart

  echo "-------------------------------------------"
  echo "Disable dropbear"
  /etc/init.d/dropbear disable
  /etc/init.d/dropbear stop
fi
