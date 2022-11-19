#!/usr/bin/fish

set NVIM_CFG_D (dirname (status --current-filename))

if test -e ~/.config/nvim/init.vim
    printf "Remove old init\n"
    rm -rf ~/.config/nvim/init.vim
end

if test -e ~/.config/nvim/plugin
    printf "Remove old plugin\n"
    rm -rf ~/.config/nvim/plugin
end

ln -sf $NVIM_CFG_D/nvim/init.vim ~/.config/nvim/init.vim
ln -sf $NVIM_CFG_D/nvim/plugin ~/.config/nvim/plugin
