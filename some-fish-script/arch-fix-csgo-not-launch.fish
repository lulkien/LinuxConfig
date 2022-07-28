#!/usr/bin/fish

set -g lib_name         'libtcmalloc_minimal.so.*'

# color palette
set -g bad              'FF7676'
set -g medium           'EBE769'
set -g good             '84FF76'
set -g norm             'normal'

function logger_nl
    set_color $argv[1]; echo $argv[2]; set_color normal
end

function logger
    set_color $argv[1]; echo -n $argv[2]; set_color normal
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
    test -e /usr/lib/$lib_name
    and begin #{
        logger_nl   $good   "[check_libtcmalloc_minimal] libtcmalloc_minimal.so is existed"
        return 0
    end #}
    or begin #{
        logger_nl   $bad    "[check_libtcmalloc_minimal] libtcmalloc_minimal.so is not existed"
        logger      $bad    "[check_libtcmalloc_minimal]"
        logger_nl   $norm   "Please run: sudo pacman -S gperftools"
        return 1
    end #}
end

function process
    #cp /usr/lib/libtcmalloc_minimal.so.4.5.9 '/media/Storage/SteamLibrary/steamapps/common/Counter-Strike Global Offensive/bin/libtcmalloc_minimal.so.0' 
    logger_nl $medium "Now find the libtcmalloc_minimal.so.* in directory /usr/lib and copy it to [steam_common_dir]/Counter-Strike Global Offensive/bin"
end

function main
    check_distro or return 1
    check_libtcmalloc_minimal or return 1
    process
end

#============================ MAIN ===========================#
main

