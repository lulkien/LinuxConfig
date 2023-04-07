function ls --description 'Custom implementation for command ls'
    /usr/bin/ls --ignore=lost+found --color $argv
end
