function fish_prompt --description 'Write out the prompt'
    set -l arrow \U27A4
    function branch_name
        # icon
        set -l git_behind \U2B07
        set -l git_ahead \U2B06 
        set -l git_diverged \U2753
        set -l git_dirty \U2718
        set -l git_clear \U2714
        # color palette
        set -l normal_color FC8484
        set -l branch_color 66FACB
        # variable
        set -l branch (git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    
        if not test -z $branch
            set_color $normal_color
            echo -n '(git:'
            set_color $branch_color
            echo -n $branch
            set_color $normal_color
            echo -n ')'

            set -l ah (git rev-list --count @{u}..HEAD 2>/dev/null)
            set -l bh (git rev-list --count HEAD..@{u} 2>/dev/null)
            set -l stt (git status --short 2>/dev/null)
            if test -z "$stt"
                set_color 49FF49
                echo -n " $git_clear"
            else
                set_color FF4949
                echo -n " $git_dirty"
            end

            if string match -qr '^[0-9]+$' $ah
                if test $ah -gt 0 -a $bh -eq 0
                    set_color 51FF49
                    echo -n " $git_ahead"
                else if test $bh -gt 0 -a $ah -eq 0
                    set_color 49AAFF
                    echo -n " $git_behind"
                else if test $ah -eq 0 -a $bh -eq 0
                    echo -n ""
                else
                    set_color FFFF49
                    echo -n " diverged"
                end
            end
        end
    end

    set_color -o 38E1FF
    echo -n '[ '
    set_color -o FF3838
    echo -n 'k'
    set_color -o FFBD38
    echo -n 'i'
    set_color -o FFFC57
    echo -n 'e'
    set_color -o 4BFF48
    echo -n 'n'
    set_color -o 5FFAFF
    echo -n 'l'
    set_color -o 9BA9FF
    echo -n 'h'
    set_color normal 
    echo -n '  '
    set_color -o FF52E0
    echo -n (prompt_pwd)
    set_color -o 38E1FF
    echo -n ' ] '
    echo (branch_name)
    set_color -o 67FFDF
    echo -n " $arrow  "
    set_color normal
end
