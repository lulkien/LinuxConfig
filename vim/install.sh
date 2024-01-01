#!/usr/bin/env bash

echo "mkdir -p ~/.vim/autoload"
mkdir -p ~/.vim/autoload/
echo '--------------------------------'

echo "wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ~/.vim/autoload/plug.vim"
wget https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -O ~/.vim/autoload/plug.vim
echo '--------------------------------'

echo "Install .vimrc"
cp vimrc ~/.vimrc
echo '--------------------------------'

echo "Done"
