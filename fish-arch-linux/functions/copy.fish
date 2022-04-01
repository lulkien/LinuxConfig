function copy
    set -g SRC              $argv[1]
    set -g DEST             $argv[2]
    set -g OPTIONS          ''
    set -g DEFAULT_INFO     '--info=progress2'
    
    # color palette
    set -g bad              'FF7676'
    set -g medium           'EBE769'
    set -g good             '84FF76'
    set -g reset            'normal'

    #--------------------- FUNCTION ---------------------#

    # Check arguments
    test -z $SRC; and begin
        set_color $bad; echo -n "[ERROR] "; set_color $reset; echo "Missing source argument"
        return 1     # error code 1
    end
    test -z $DEST; and begin
        set_color $bad; echo -n "[ERROR] "; set_color $reset; echo "Missing destination argument"
        return 1     # error code 1
    end

    # Check source, destination valid
    test -e $SRC; or begin
        set_color $bad; echo -n "[ERROR] "; set_color $reset; echo "$SRC is not exist"
        return 2    # error code 2
    end

    test -e $DEST; or begin
        set_color $bad; echo -n "[ERROR] "; set_color $reset; echo "$DEST is not exist"
        return 2
    end
    
    # Check source type
    test -d $SRC; and begin
        set_color $medium; echo -n "[INFO] "; set_color $reset; echo "$SRC is a directory"
        set OPTIONS '-rz'
    end
    or begin
        set_color $medium; echo -n "[INFO] "; set_color $reset; echo "$SRC is not a directory"
        set OPTIONS '-z'
    end

    set_color $good; echo -n "[START] "; set_color $reset;
    echo "rsync $DEFAULT_INFO $OPTIONS $SRC $DEST"
    rsync $DEFAULT_INFO $OPTIONS $SRC $DEST
    test $status -eq 0; and begin
        set_color $good; echo "[FINISH]"; set_color $reset
        return $status
    end
    or begin
        set_color $bad; echo "[FAIL]"; set_color $reset
        return $status
    end

end

