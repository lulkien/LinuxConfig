#------------------------------------- Variables -------------------------------------#
set -g fish_prompt_pwd_dir_length 0         
set -g fish_term24bit 1

#----------------------------------- Abbreviations -----------------------------------#

# Navigate folder
    abbr -a ... 'cd ../..'
    abbr -a ccf 'cd ~/.config/fish'                                 # cd config fish
    abbr -a ccc 'cd $PREFIX'
# Fast edit config
    abbr -a efc 'vim ~/.config/fish/config.fish'                    # edit fish config
    abbr -a efg 'vim ~/.config/fish/functions/fish_greeting.fish'
    abbr -a efp 'vim ~/.config/fish/functions/fish_prompt.fish'
# Git
    abbr -a gco 'git checkout'
    abbr -a gcm 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a grs 'git clean -f -d && git reset --hard HEAD^ && git pull'
    abbr -a gpo 'git push origin '
    abbr -a gpl 'git pull'
    abbr -a gcl 'git clone'
    abbr -a gst 'git status'
    abbr -a gdf 'git diff'
    abbr -a gpom 'git push origin master'
# Apt
    abbr -a aud 'apt update'
    abbr -a aug 'apt upgrade -y'
    abbr -a ait 'apt install -y'
    abbr -a aac 'apt autoclean'
    abbr -a aar 'apt autoremove'
    abbr -a arm 'apt remove'
# Pkg
    abbr -a pud 'pkg update'
    abbr -a pug 'pkg upgrade -y'
    abbr -a pit 'pkg install -y'

#------------------------------------- Aliases -------------------------------------#
    alias q='exit'
    alias md='mkdir'
    alias cls='clear'
