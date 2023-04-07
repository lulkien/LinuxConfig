function cd
    # Import
    set -l import_dir $HOME/.config/fish/addons/include/cd
    for file in $import_dir/*.fish
        source $file
    end

    # Init cd_history in new shell
    set -q cd_history; or set -g cd_history

    # Remove -- things
    set argv (remove_shit $argv)

    # Parse arguments
    set -l options (fish_opt -s l -l list)
    set -a options (fish_opt -s i -l index --required-val)
    argparse $options -- $argv; or return 1

    # Check if using 2 options
    if set -q _flag_index; and set -q _flag_list
        echo "cd: Only use one option at a time"
        return 1
    end

    if set -q _flag_list        # Using list option
        test (count $argv) -gt 0; and echo "cd: Print dir history only, ignore other arguments"
        set -l index 1
        for dir in (string split ' ' $cd_history)
            echo "$index - $dir"
            set index (math $index + 1)
        end
        return 0
    else if set -q _flag_index  # If using index option
        if not is_integer $_flag_index
            echo "cd: $_flag_index is not an integer"
            return 1
        end
        if test $_flag_index -lt 1; or test $_flag_index -gt (count (string split ' ' $cd_history))
            echo "cd: Invalid history index"
            return 1
        end
        test (count $argv) -gt 0; and echo "cd: Change directory to index $_flag_index, ignore other arguments"
        set -l list_dir (string split ' ' $cd_history)
        set argv $list_dir[$_flag_index]
    else # default case
        set argv (set_explicit_path "$argv")
        set argv (remove_trailing_slash "$argv")
    end

    __fish_cd $argv
    set -l cd_status $status
    if test $cd_status -eq 0
        set cd_history (remove_existed "$argv" "$cd_history")
        set cd_history "$argv $cd_history"
        set cd_history (string trim -c ' ' $cd_history)
    end
    return $cd_status
end
