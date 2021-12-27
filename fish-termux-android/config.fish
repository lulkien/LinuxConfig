#------------------------------------- Variables -------------------------------------#
set -g fish_prompt_pwd_dir_length 0         
set -g fish_term24bit 1

#----------------------------------- Abbreviations -----------------------------------#

# General
    abbr -a md 'mkdir'
    abbr -a cls 'clear'
# Navigate folder
    abbr -a ... 'cd ../..'
    abbr -a ccf 'cd ~/.config/fish'                 # cd config fish
    abbr -a cho 'cd /home/kienlh4ivi/working/source-code/AppHomeScreen'
    abbr -a che 'cd /home/kienlh4ivi/working/source-code/AppHelp'
    abbr -a cst 'cd /home/kienlh4ivi/working/source-code/AppStandbyClock'
    abbr -a cwb 'cd /home/kienlh4ivi/working/build'
# Fast edit config
    abbr -a efc 'vim ~/.config/fish/config.fish'  # edit fish config
    abbr -a efg 'vim ~/.config/fish/functions/fish_greeting.fish'
    abbr -a efp 'vim ~/.config/fish/functions/fish_prompt.fish'
# Git
    abbr -a gco 'git checkout'
    abbr -a gcm 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a grs 'git clean -f -d && git reset --hard HEAD^ && git pull'
    abbr -a gpo 'git push origin HEAD:refs/for/'
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
