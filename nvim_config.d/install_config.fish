#!/usr/bin/fish

if test -e ~/.config/nvim/init.vim
    printf "Remove old init\n"
    rm -rf ~/.config/nvim/init.vim
end

if test -e ~/.config/nvim/plugin
    printf "Remove old plugin\n"
    rm -rf ~/.config/nvim/plugin
end

ln -s ./nvim/init.vim ~/.config/nvim/init.vim
ln -s ./nvim/plugin ~/.config/nvim/plugin
