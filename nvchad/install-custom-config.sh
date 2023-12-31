#/usr/bin/env bash

config_nvim=$HOME/.config/nvim
config_nvim_lua=$config_nvim/lua
nvchad_conf_dir=$(realpath "$(dirname "$0")")

echo "Create symlink for nvchad custom configs"

if [[ ! -d $config_nvim || ! -d $config_nvim_lua ]]; then
  echo "NvChad not existed! Installing..."
  bash $nvchad_conf_dir/install-nvchad.sh
  if [[ $? -ne 0 ]]; then
      echo "Failed to install NvChad. Exiting..."
      exit 1
  fi
fi

test -L $config_nvim_lua/custom && unlink $config_nvim_lua/custom || rm -rf $config_nvim_lua/custom

ln -s $nvchad_conf_dir/custom $config_nvim_lua/custom
