#------------------------------------- Variables -------------------------------------#
set -g fish_prompt_pwd_dir_length 0         
set -g fish_term24bit 1

#----------------------------------- Abbreviations -----------------------------------#

# General
    abbr -a rmd 'rm -r'
    abbr -a cpd 'cp -r'
    abbr -a scpd 'scp -r'
    abbr -a lsa 'ls -a'
    abbr -a lla 'll -a'
# Navigate folder
    abbr -a ... 'cd ../..'
    abbr -a ccf 'cd ~/.config/fish'                                 # cd config fish
    abbr -a ccc 'cd $PREFIX'
# Fast edit config
    abbr -a efc 'vim ~/.config/fish/config.fish'                    # edit fish config
    abbr -a efg 'vim ~/.config/fish/functions/fish_greeting.fish'
    abbr -a efp 'vim ~/.config/fish/functions/fish_prompt.fish'
    abbr -a evi 'vim ~/.vimrc' 
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
    abbr -a gad 'git add'
    abbr -a gpom 'git push origin master'
# Apt
    abbr -a aud 'apt-get update'
    abbr -a aug 'apt-get upgrade -y'
    abbr -a ait 'apt-get install -y'
    abbr -a aac 'apt autoclean'
    abbr -a aar 'apt autoremove'
    abbr -a arm 'apt remove'

#------------------------------------- Aliases -------------------------------------#
    alias q='exit'
    alias md='mkdir'
    alias cls='clear'
    alias pls='sudo'
