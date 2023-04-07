function l --description 'Implementation for command l'
    source $HOME/.config/fish/addons/include/ls/__fish_ls.fish
    __fish_ls -ohA $argv
end
