if status is-interactive
    #===================================== Variables =====================================#
    set -g fish_color_valid_path
    set -g fish_prompt_pwd_dir_length 0
    set -g fish_term24bit 1

    #=================================== Abbreviations ===================================#
    # General
    abbr -a mkd     'mkdir'
    abbr -a rmkd    'sudo mkdir'

    abbr -a rmd     'rm -r'
    abbr -a rrm     'sudo rm'
    abbr -a rrmd    'sudo rm -r'

    abbr -a cpd     'cp -r'
    abbr -a rcp     'sudo cp'
    abbr -a rcpd    'sudo cp -r'
    abbr -a scpd    'scp -r'

    abbr -a rvim    'sudo vim'

    abbr -a lsa     'ls -a'
    abbr -a lla     'll -a'

    # Navigate folder
    abbr -a ...     'cd ../..'
    abbr -a ccf     'cd ~/.config/fish'                                 # cd config fish
    abbr -a ccc     'cd $PREFIX'

    # Fast edit config
    abbr -a efc     'vim ~/.config/fish/config.fish'                    # edit fish config
    abbr -a efg     'vim ~/.config/fish/functions/fish_greeting.fish'
    abbr -a efp     'vim ~/.config/fish/functions/fish_prompt.fish'
    abbr -a evi     'vim ~/.vimrc'

    # Git
    abbr -a gco     'git checkout'
    abbr -a gcm     'git commit'
    abbr -a gca     'git commit --amend'
    abbr -a grs     'git clean -f -d && git reset --hard HEAD^ && git pull'
    abbr -a gpo     'git push origin'
    abbr -a gpl     'git pull'
    abbr -a gcl     'git clone'
    abbr -a gst     'git status'
    abbr -a gdf     'git diff'
    abbr -a gad     'git add'
    abbr -a gpom    'git push origin master'

    # Apt
    abbr -a aud     'sudo apt-get update'
    abbr -a aug     'sudo apt-get upgrade -y'
    abbr -a ait     'sudo apt-get install -y'
    abbr -a acl     'sudo apt autoremove && sudo apt autoclean'
    abbr -a arm     'sudo apt remove --purge'
    abbr -a asr     'apt-cache search'

    #===================================== Aliases =====================================#
    alias q='exit'
    alias cls='clear'
    alias pls='sudo'
end
