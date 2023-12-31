#!/usr/bin/env bash

local_share_nvim=$HOME/.local/share/nvim
config_nvim=$HOME/.config/nvim

echo "Remove: $config_nvim"
rm -rf $config_nvim
if [[ $? -ne 0 ]]; then
  echo "Cannot remove dir: $config_nvim"
  exit 1
fi

echo "Remove: $local_share_nvim"
rm -rf $local_share_nvim
if [[ $? -ne 0 ]]; then
  echo "Cannot remove dir: $local_share_nvim"
  exit 1
fi

echo "Clone NvChad"
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
exit $?
