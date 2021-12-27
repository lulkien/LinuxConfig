function deploy-home
    # input
    set -g ip_addr "10.35.55.$argv[1]"
    set -g opt $argv[2]
    set -g is_strip $argv[3]

    # system variable
    set -g source_qml '/home/kienlh4ivi/working/source-code/AppHomeScreen/qml'
    set -g release_bin '/home/kienlh4ivi/working/build/AppHomeScreen/app/bin/AppHomeScreen'
    set -g release_share '/home/kienlh4ivi/working/build/AppHomeScreen/app/share/AppHomeScreen'
    set -g strip_path '/usr/local/oecore-x86_64/sysroots/x86_64-oesdk-linux/usr/bin/x86_64-oe-linux/x86_64-oe-linux-strip'
    set -g hu_bin '/app/bin/AppHomeScreen'
    set -g hu_share '/app/share/AppHomeScreen'
    set -l working_dir (pwd)

    # color
    set -g bad 'FF7676'
    set -g medium 'EBE769'
    set -g good '84FF76'
    set -g reset 'normal'

    set_color $good; echo "========================= BEGIN OF SCRIPT ========================="; set_color $reset
    # validate ip
    set -g ip_validate '^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$'
    if not string match -qr $ip_validate $ip_addr
        set_color $bad; echo "Need a valid ip address"; set_color $reset
        return
    else
        set_color $medium; echo -n "IP: "; set_color $good; echo -n $ip_addr; set_color $medium; echo " OK"; set_color $reset
    end

    # validate options
    set -g list_argv '-all' '-bin' '-share' '-qml'
    set -g list_argv_ns '-ns' '--non-strip'
    if not contains -- "$opt" $list_argv
        set_color $bad
        echo "Wrong argument at index 2"
        echo "List arguments at index 2: -all | -bin | -share | -qml"
        set_color $reset
        return
    end

    function copy_binary
        if not test -e $release_bin
            set_color $bad
            echo "File not found: $release_bin"
            set_color $reset
            abort
        end
        if contains -- "$is_strip" $list_argv_ns
            set_color $medium; echo "Deploy non-strip binary to device"; set_color $reset
        else
            set_color $medium; echo "Deploy striped binary to device"; set_color $reset
            $strip_path $release_bin
        end
        ssh root@$ip_addr "mv $hu_bin $hu_bin.bak"
        scp $release_bin root@$ip_addr:/app/bin
    end

    function copy_share
        if not test -d $release_share
            set_color $bad
            echo "Directory not found: $release_share"
            set_color $reset
            return
        end
        
        # log
        set_color $medium; echo "Copy share folder to device"; set_color $reset

        cd $release_share
        tar -czf share.tar.gz *
        scp share.tar.gz root@$ip_addr:$hu_share
        rm -f share.tar.gz
        ssh root@$ip_addr "cd $hu_share; tar --touch -xzf share.tar.gz; rm -f share.tar.gz"
    end

    function copy_qml
        if not test -d $source_qml
            set_color $bad
            echo "Directory not found: $source_qml"
            set_color $reset
            return
        end

        # log
        set_color $medium; echo "Copy qml folder to device"; set_color $reset
        
        cd $source_qml
        tar -czf qml.tar.gz *
        scp qml.tar.gz root@$ip_addr:$hu_share/qml
        rm -f qml.tar.gz
        ssh root@$ip_addr "cd $hu_share/qml; tar --touch -xzf qml.tar.gz; rm -f qml.tar.gz"
    end

    ssh root@$ip_addr 'mount -o remount, rw /'

    if test '-all' = "$opt"
        copy_binary
        copy_share
    else if test '-bin' = "$opt"
        copy_binary
    else if test '-share' = "$opt"
        copy_share
    else if test '-qml' = "$opt"
        copy_qml
    end

    set_color $medium; echo "killall AppHomeScreen"; set_color $reset
    ssh root@$ip_addr "killall AppHomeScreen"
    set_color $good; echo "========================== END OF SCRIPT =========================="; set_color $reset

    cd $working_dir
end
