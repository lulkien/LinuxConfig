#!/usr/bin/env fish

echo "Remove custom directory"
rm -r ~/.config/nvim/lua/custom

echo "Apply custom config"
cp -r custom ~/.config/nvim/lua
