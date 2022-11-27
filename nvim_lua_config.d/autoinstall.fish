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

# Copy everything else
echo "Copy nvim to config folder"
if test -d ~/.config/nvim
    rm -rf ~/.config/nvim
    cp -r $nvim_lua_cfg_dir/nvim ~/.config
end

