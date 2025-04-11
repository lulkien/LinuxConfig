#!/usr/bin/env bash

printf "Setup apt-fast.\n"
if $(command -v apt-fast &>/dev/null); then
  printf "Bruh, you already have it.\n"
else
  printf "First, I'm gonna add the ppa.\n"
  sudo add-apt-repository ppa:apt-fast/stable
  sudo apt update

  printf "Then, installing apt-fast for ya.\n"
  sudo apt -y install apt-fast

  printf "\n"
  if $(command -v apt-fast &>/dev/null); then
    printf "Good, now we proceed the next step.\n"
  else
    printf "Why can't I install it? No idea, try figure it out yourself.\n"
    exit 1
  fi
fi

printf "\n"
printf "Now, Imma fish shell for modern human :D\n"
if $(command -v fish &>/dev/null); then
  printf "Damn bro, it's right there. NEXT!!!\n"
else
  printf "Ye, add the goddamn ppa.\n"
  sudo apt-add-repository ppa:fish-shell/release-4
  sudo apt update

  printf "Fish shell is comming...\n"
  sudo apt-fast install fish

  printf "\n"
  if $(command -v fish &>/dev/null); then
    printf "Here you go, fish in the shell.\n"
  else
    printf "Weird. Can't install. Try figure it out yourself.\n"
    exit 2
  fi
fi

printf "\n"
printf "Every body need a good text editor. And I choose neovim <3\n"
if $(command -v nvim &>/dev/null); then
  printf "Wow, already used it? 10 out of 10, no cap.\n"
else
  printf "Take the ppa, put it there...\n"
  sudo add-apt-repository ppa:neovim-ppa/unstable
  sudo apt update

  printf "Get neovim right now, fr fr\n"
  sudo apt-fast install neovim

  printf "\n"
  if $(command -v nvim &>/dev/null); then
    printf "Good bye, vi. Good bye, vim. AND FUCK YOU, NANO.\n"
    if [[ ! -d /usr/local/bin ]]; then
      sudo mkdir /usr/local/bin
    fi

    sudo ln -sf /usr/bin/nvim /usr/local/bin/vi
    sudo ln -sf /usr/bin/nvim /usr/local/bin/vim
  else
    printf "OMG, I can't, why????\n"
    exit 3
  fi
fi

printf "\n"
printf "Now we do some serious stuffs: Firewall\n"
printf "Remove iptables and ufw garbage\n"
sudo apt purge iptables

printf "\n"
printf "And install nftables"
sudo apt-fast install nftables

printf "\n"
printf "REMEMBER TO SETUP YOUR FIREWALL. DO NOT FORGET.\n"
printf "REMEMBER TO SETUP YOUR FIREWALL. DO NOT FORGET.\n"
printf "REMEMBER TO SETUP YOUR FIREWALL. DO NOT FORGET.\n"

printf "\n"
printf "Okay. Almost done. Now we do some less serious stuffs.\n"
sudo apt-fast install build-essential python3-venv unzip npm

printf "\n"
printf "All good. Now, let's have fun my friend.\n"
