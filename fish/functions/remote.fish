function remote
    if test -z $argv[1]
        ssh root@10.35.55.60
    else
        ssh root@10.35.55.$argv[1]
    end
end

