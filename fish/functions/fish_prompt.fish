function fish_prompt --description 'Write out the prompt'
    # Variable
    set -g host_name        (prompt_hostname)
    set -g path_str         (prompt_pwd)
    set -g prompt_name      "$USER@$host_name"
    set -g open_bracket     '[ '
    set -g close_bracket    ' ] '
    set -g prefix           ' $ '
    test "$USER" = "root"; and set prefix " # "

    # Prompt color palette
    set -g color_bracket    '38E1FF'
    set -g color_name       '7FED7F'
    set -g color_pwd        'FF6BB8'
    set -g color_prefix     '67FFDF'

    # Check git installed
    set -g git_installed    'false'
    test -e /usr/bin/git; and set git_installed 'true'

    function branch_name
        # validate git directory 
        test "$git_installed" = 'true'; or return   # break if git is not installed
        
        # icon
        set -l git_bh       '-' 
        set -l git_ah       '+'
        set -l git_dirty    '[!]'
        set -l git_clear    '[OK]'
        set -l git_awk      '[?]'

        # color palette
        set -l color_label  'FC8484'
        set -l color_branch '66FACB'
        set -l color_clear  '49FF49'
        set -l color_dirty  'FF4949'
        set -l color_ahead  '51FF49'
        set -l color_behind '49AAFF'
        set -l color_akw    'FFFF49'
        
        # Branch name checking
        set -l branch (git branch --show-current 2>/dev/null)
        test -z "$branch"; and return   # break if not git directory

        # additional variables
        set -l ah (git rev-list --count @{u}..HEAD 2>/dev/null)
        set -l bh (git rev-list --count HEAD..@{u} 2>/dev/null)
        set -l stt (git status --short 2>/dev/null)

        # Write branch name
        set_color normal
        set_color $color_label;     echo -n '(git:';
        set_color $color_branch;    echo -n $branch;
        set_color $color_label;     echo -n ')';
    
        # Write status
        test -z "$stt" 
        and begin; set_color $color_clear;  echo -n " $git_clear"; end
        or begin;  set_color $color_dirty;  echo -n " $git_dirty"; end

        string match -qr '^[0-9]+$' $ah
        and begin
            if test $ah -gt 0 -a $bh -eq 0
                set_color $color_ahead; echo -n "[$git_ah$ah]"
            else if test $bh -gt 0 -a $ah -eq 0
                set_color $color_behind; echo -n "[$git_bh$bh]"
            else if test $ah -eq 0 -a $bh -eq 0
                echo -n ""
            else
                set_color $color_akw; echo -n "$git_awk"
            end
        end
    end

    set_color -o $color_bracket; echo -n "$open_bracket"
    set_color    normal
    set_color    $color_name;    echo -n "$prompt_name  "
    set_color    $color_pwd;     echo -n "$path_str" 
    set_color -o $color_bracket; echo -n "$close_bracket"
    echo (branch_name)
    set_color    normal
    set_color    $color_prefix;  echo -n "$prefix"
    set_color    normal
end
