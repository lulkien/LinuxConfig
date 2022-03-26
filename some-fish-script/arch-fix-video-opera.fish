#!/usr/bin/fish

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

function check_opera_extra_ffmpeg
    test -e /usr/lib/opera/lib_extra/libffmpeg.so
    and begin #{
        logger_nl   $good   "[check_opera_extra_ffmpeg] libffmpeg.so is existed"
        return 0
    end #}
    or begin #{
        logger_nl   $bad    "[check_opera_extra_ffmpeg] libffmpeg.so is not existed"
        logger      $bad    "[check_opera_extra_ffmpeg] "
        logger_nl   $norm   "Please run: sudo pacman -S opera-ffmpeg-codecs"
        return 1
    end #}
end

function process
    cd /usr/lib/opera
    test -e /usr/lib/opera/libffmpeg.so
    and begin #{
        test -L libffmpeg.so
        and begin #{
            logger_nl $medium "[process] Remove symlink libffmeg.so"
            sudo rm libffmpeg.so
        end #}
        or begin #{
            logger_nl $medium "[process] Backup libffmeg.so"
            sudo mv libffmpeg.so libffmpeg.so.bak
        end #}
    end #}
    sudo ln -s /usr/lib/opera/lib_extra/libffmpeg.so libffmpeg.so
end

function main
    check_distro or return 1
    check_opera_extra_ffmpeg or return 1
    process
end

#============================ MAIN ===========================#
main

