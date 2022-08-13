#!/usr/bin/fish

set -g lib_name         'libtcmalloc_minimal.so'
set -g list_lib_found   ''

# color palette
set -g bad              'FF7676'
set -g medium           'EBE769'
set -g good             '84FF76'
set -g norm             'CACACA'

function log
    set -l  func_name   $argv[1]
    set -l  log_color   $argv[2]
    set -l  message     $argv[3]
    set_color $medium; echo -n "[$func_name]";
    if [ ! -z "$log_color" ]
        set_color "$log_color"; echo " $message";
    else
        echo
    end
    set_color normal;
end

function check_distro
    if string match -qr 'arch' (uname -r)
        log "check_distro" $good "This is ArchLinux"
        return 0
    else
        log "check_distro" $bad "This is not ArchLinux!"
        return 1
    end
end

function check_libtcmalloc_minimal
    log "check_libtcmalloc_minimal" $norm "ls -l /usr/lib | grep \"$lib_name\""
    ls -l /usr/lib | grep "$lib_name"
    set list_lib_found (ls -l /usr/lib | grep "$lib_name")
    if test -z "$list_lib_found"
        log "check_libtcmalloc_minimal" $bad "$lib_name is not existed! Please install gperftools."
        log "check_libtcmalloc_minimal" $norm "sudo pacman -S gperftools"
        return 1
    else
        log "check_libtcmalloc_minimal" $good "$lib_name is installed."
        return 0
    end
end

function set_csgo_binary_path
    log "set_csgo_binary_path" $norm "Give the path to CSGO folder."
    read -g CSGO_PATH

    if [ -z "$CSGO_PATH" ]
        log "set_csgo_binary_path" $bad "Enter the damn path to CSGO folder, fuck you!"
        return 1
    end

    if [ -d $CSGO_PATH/bin ]
        log "set_csgo_binary_path" $good "$CSGO_PATH/bin exists."
        return 0
    else
        log "set_csgo_binary_path" $bad "$CSGO_PATH/bin not exists!"
        return 1
    end
end

function make_symbolic_link
    log "make_symbolic_link" $norm "Which one? Give fullname of the lib."
    read -g fullib

    if [ -z "$fullib" ]
        log "make_symbolic_link" $bad "Enter the lib's name god dammit!"
        return 1
    end

    if [ ! -e "/usr/lib/$fullib" ]
        log "make_symbolic_link" $bad "Can you enter the correct lib's name asshole?"
        return 2
    end

    log "make_symbolic_link" $norm "ln -sf /usr/lib/$fullib \"$CSGO_PATH/bin/libtcmalloc_minimal.so.0\""
    ln -sf /usr/lib/$fullib "$CSGO_PATH/bin/libtcmalloc_minimal.so.0"

    set -l      ext_code    $status
    if [ $ext_code -eq 0 ]
        log "make_symbolic_link" $good "ln return code 0"
        ls -l | grep "$lib_name"
        return 0
    else
        log "make_symbolic_link" $bad "ln return code $ext_code"
        return  $ext_code
    end
end

function main
    clear
    log "main"
    echo
    check_distro; or return 1
    echo
    check_libtcmalloc_minimal; or return 1
    echo
    set_csgo_binary_path; or return 1
    echo
    make_symbolic_link; or return 1
    echo
    log "main" $good "Exit code 0"
    return 0
end

#============================ MAIN ===========================#
main
set -l ext_code $status
if [ ! $ext_code -eq 0 ]
    echo
    log "main" $bad "Exit code $ext_code"
end

