#!/usr/bin/fish

set nvim_lua_cfg_dir    (dirname (status --current-filename))

# Make config dir
if ! test -d ~/.config/nvim
    echo "Make nvim config directory"
    mkdir -p ~/.config/nvim
end

# Make lsp-installer.log
if ! test -d ~/.cache/nvim
    echo "Make directory ~/.cache/nvim"
    echo "Create lsp-installer.log"
    mkdir -p ~/.cache/nvim
    touch ~/.cache/nvim/lsp-installer.log
else
    if ! test -e ~/.cache/nvim/lsp-installer.log
        echo "Create lsp-installer.log"
        touch ~/.cache/nvim/lsp-installer.log
    end
end

# Copy vim-plug if not exist
if ! test -e ~/.config/nvim/autoload/plug.vim
    echo "Copy vim-plug"
    cp -r $nvim_lua_cfg_dir/nvim/autoload ~/.config/nvim
end

# Copy everything else
if test -e ~/.config/nvim/init.lua
    echo "Remove old init.lua file"
    rm ~/.config/nvim/init.lua 
end

if test -d ~/.config/nvim/lua
    echo "Remove old lua scripts folder"
    rm -r ~/.config/nvim/lua
end

echo "Copy new init.lua and lua script folder"
cp $nvim_lua_cfg_dir/nvim/init.lua ~/.config/nvim
cp -r $nvim_lua_cfg_dir/nvim/lua ~/.config/nvim
