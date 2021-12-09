#------------------------------------- Variables -------------------------------------#
set -g fish_prompt_pwd_dir_length 0         

#----------------------------------- Abbreviations -----------------------------------#

# General
    abbr -a md 'mkdir'
    abbr -a cls 'clear'
# Navigate folder
    abbr -a ccf 'cd ~/.config/fish'                 # cd config fish
# Fast edit config
    abbr -a efc 'vim ~/.config/fish/config.fish'  # edit fish config
    abbr -a efg 'vim ~/.config/fish/functions/fish_greeting.fish'
    abbr -a efp 'vim ~/.config/fish/functions/fish_prompt.fish'
# Git
    abbr -a gco 'git checkout'
    abbr -a gcm 'git commit'
    abbr -a grs 'git clean -f -d && git reset --hard HEAD^ && git pull'
    abbr -a gpo 'git push origin'
    abbr -a gpl 'git pull'
    abbr -a gcl 'git clone'
    abbr -a gst 'git status'
    abbr -a gdf 'git diff'
# Apt
    abbr -a aud 'sudo apt-get update'
    abbr -a aug 'sudo apt-get upgrade -y'
    abbr -a ait 'sudo apt-get install -y'
    abbr -a aac 'sudo apt-get autoclean'
    abbr -a aar 'sudo apt-get autoremove'
    abbr -a arm 'sudo apt remove'
