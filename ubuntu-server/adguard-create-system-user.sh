#!/usr/bin/env bash

ADGUARD_SERVICE_FILE=/etc/systemd/system/AdGuardHome.service
ADGUARD_DIR=/opt/AdGuardHome
ADGUARD_USER=adguard
BIND_GROUP=lowbind

echo_green() {
  echo -e '\e[1;32m'"$@"'\e[00m'
}

echo_red() {
  echo -e '\e[1;31m'"$@"'\e[00m' >&2
}

check_run_as_root() {
  if [[ $EUID -ne 0 ]]; then
    echo_red "ERROR: This script must be run as root (or with sudo)."
    return 1
  fi
}

validate_directory() {
  if [[ ! -d ${ADGUARD_DIR} ]]; then
    echo_red "Why create adguard user when not install AdguardHome?"
    echo_red "Or I'm wrong? Then feel free to set ADGUARD_DIR yourself."
    return 1
  fi
}

create_user() {
  echo

  if $(id ${ADGUARD_USER} &>/dev/null); then
    echo_green "User ${ADGUARD_USER} existed."
    return 0
  fi

  echo_green "Create user ${ADGUARD_USER}."

  useradd -r -s /usr/sbin/nologin -M -d ${ADGUARD_DIR} ${ADGUARD_USER}

  if $(id ${ADGUARD_USER} &>/dev/null); then
    echo_green "User ${ADGUARD_USER} is created."
    return 0
  fi

  echo_red "User ${ADGUARD_USER} can't be created."
  return 1
}

create_group() {
  echo

  if grep -q "^${BIND_GROUP}:" /etc/group; then
    echo_green "Group ${BIND_GROUP} existed."
    return 0
  fi

  echo_green "Create group ${BIND_GROUP}."

  groupadd ${BIND_GROUP}

  if grep -q "^${BIND_GROUP}:" /etc/group; then
    echo_green "Group ${BIND_GROUP} is created."
    return 0
  fi

  echo_red "Group ${BIND_GROUP} can't be created."
  return 1
}

add_user_to_group() {
  echo

  if groups ${ADGUARD_USER} | grep -q ${BIND_GROUP}; then
    echo_green "User ${ADGUARD_USER} already in group ${BIND_GROUP}."
    return 0
  fi

  echo_green "Add user ${ADGUARD_USER} to group ${BIND_GROUP}."

  usermod -aG ${BIND_GROUP} ${ADGUARD_USER}

  if groups ${ADGUARD_USER} | grep -q ${BIND_GROUP}; then
    echo_green "User ${ADGUARD_USER} is added to group ${BIND_GROUP}."
    return 0
  fi

  echo_red "User ${ADGUARD_USER} can't be added to group ${BIND_GROUP}."
  return 1
}

create_bind_rules() {
  echo

  local bind_file=/etc/authbind/byport/53

  if ! command -v authbind &>/dev/null; then
    echo_green "Install authbind."
    apt install authbind
  fi

  if [[ ! -f ${bind_file} ]]; then
    echo_green "Create ${bind_file} and set permission."
    touch ${bind_file}
    chmod 440 ${bind_file}
    chown :${BIND_GROUP} ${bind_file}
    return 0
  fi

  if [[ "$(ls -l ${bind_file} | awk '{print $4}')" != "${BIND_GROUP}" ]]; then
    echo_green "Change group for ${bind_file}."
    chown :${BIND_GROUP} ${bind_file} || return 1
  fi

  if [[ "$(ls -l ${bind_file} | awk '{print $1}')" != "-r--r-----" ]]; then
    echo_green "Set permission for ${bind_file}."
    chmod 440 ${bind_file} || return 1
  fi
}

modify_service_file() {
  echo

  if grep -q 'ExecStart=/opt/AdGuardHome/AdGuardHome' ${ADGUARD_SERVICE_FILE}; then
    echo_green "Modify service file ${ADGUARD_SERVICE_FILE}"

    sed -i 's|ExecStart=/opt/AdGuardHome/AdGuardHome|ExecStart=authbind --deep /opt/AdGuardHome/AdGuardHome|' ${ADGUARD_SERVICE_FILE}

    if ! grep -q 'ExecStart=authbind --deep /opt/AdGuardHome/AdGuardHome' ${ADGUARD_SERVICE_FILE}; then
      echo_red "Failed to modify service file ${ADGUARD_SERVICE_FILE}."
      return 1
    fi

    systemctl daemon-reload
  fi

  systemctl restart AdGuardHome
}

check_run_as_root || exit 1
validate_directory || exit 1
create_user || exit 1
create_group || exit 1
add_user_to_group || exit 1
create_bind_rules || exit 1
modify_service_file || exit 1
