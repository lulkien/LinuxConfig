function remove_shit
    set -l _argv
    for arg in $argv
        test $arg = '--'; or set -a _argv $arg
    end
    echo $_argv
end
