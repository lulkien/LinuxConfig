#!/usr/bin/fish

set -g lib_name         'libtcmalloc_minimal'
set -g list_lib_found   ''

# color palette
set -g bad              'FF7676'
set -g medium           'EBE769'
set -g good             '84FF76'
set -g norm             'normal'

function logger_nl
    set_color $argv[1]; echo $argv[2]; set_color normal;
end

function logger
    set_color $argv[1]; echo -n $argv[2]; set_color normal;
end

function check_distro
    string match -rq 'arch' (uname -r)
        and return 0
        or  begin #{
            logger_nl $bad "[check_distro] This is not Arch Linux"
            return 1
        end #}
end

function check_libtcmalloc_minimal
    logger_nl $medium "[check_libtcmalloc_minimal] ls -l /usr/lib | grep \"$lib_name\""
    ls -l /usr/lib | grep "$lib_name"
    set list_lib_found (ls -l /usr/lib | grep "$lib_name")
    if test -z "$list_lib_found"
        logger_nl   $bad    "[check_libtcmalloc_minimal] $lib_name is not existed!!!"
        logger      $bad    "[check_libtcmalloc_minimal] Install gperftools please ----> "
        logger_nl   $norm   "sudo pacman -S gperftools"
        return 1
    else
        logger_nl   $good   "[check_libtcmalloc_minimal] $lib_name is installed."
        return 0
    end
end

function final
    #cp /usr/lib/libtcmalloc_minimal.so.4.5.9 '/media/Storage/SteamLibrary/steamapps/common/Counter-Strike Global Offensive/bin/libtcmalloc_minimal.so.0' 
    logger      $good   "[final] "
    logger_nl   $norm   "Now find the libtcmalloc_minimal.so.* in directory /usr/lib and copy it to [steam_common_dir]/Counter-Strike Global Offensive/bin"
end

function main
    check_distro or return 1
    check_libtcmalloc_minimal
    if [ ! $status -eq 0 ]
        return 1
    end
    final
end

#============================ MAIN ===========================#
main

