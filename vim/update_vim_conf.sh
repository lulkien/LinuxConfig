#!/usr/bin/env bash

echo "mkdir -p ~/.vim/autoload"
mkdir -p ~/.vim/autoload/
echo '--------------------------------'

echo "wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ~/.vim/autoload/plug.vim"
wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ~/.vim/autoload/plug.vim
echo '--------------------------------'

echo "Copy .vimrc and .vim/ to ~"
cp -r .vim/ ~/
cp .vimrc ~/
echo '--------------------------------'

echo "Done"
