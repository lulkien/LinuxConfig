function remove_existed
    set -l remove_item  "$argv[1]"
    set -l from_list    "$argv[2]"
    set -l tmp_list

    set from_list (echo $from_list | sed "s`[[:space:]]\+` `g")
    for item in (string split ' ' $from_list)
        if not test $item = $remove_item
            set -a tmp_list $item
        end
    end
    echo "$tmp_list"
end
