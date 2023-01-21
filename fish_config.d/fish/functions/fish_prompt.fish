function fish_prompt --description 'Write out the prompt'
    # Variable
    set -g host_name        (prompt_hostname)
    set -g path_str         (prompt_pwd)
    set -g prompt_name      "$USER@$host_name"
    set -g open_bracket     '[ '
    set -g close_bracket    ' ] '
    set -g prefix           ' $ '
    test "$USER" = "root"; and set prefix " # "
    set -g git_time_out     1s
    # Prompt color palette
    set -g color_bracket    '38E1FF'
    set -g color_name       '7FED7F'
    set -g color_pwd        'FF6BB8'
    set -g color_prefix     '67FFDF'
    # Check git installed
    set -g git_installed    'false'
    if test -e /usr/bin/git
        set git_installed 'true'
    end

    function is_str_contain_substr
        set -l str      $argv[1]
        set -l substr   $argv[2]
        if test -z "$str" -o -z "$substr"
            return 1
        end
        string match -rq "$substr" "$str"
        return $status
    end

    function branch_name
        # Validate git directory
        if test "$git_installed" != 'true'
            return   # break if git is not installed
        end

        # icon
        set -l git_bh       '-'
        set -l git_ah       '+'
        set -l git_dirty    '[!]'
        set -l git_clean    '[OK]'
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
        set -l branch   (git branch --show-current 2>/dev/null)
        set -l detached (git branch 2>/dev/null | grep 'detached' | sed -r 's/\* |\(|\)//g')
        #set -l detached (git branch 2>/dev/null | grep 'detached' | sed -r 's/\* |\(|\)//g' | tr ' ' '\n' | tail -n1)

        if test ! -z "$branch"
            # Write branch name
            set_color $color_label;     echo -n '(git:';
            set_color $color_branch;    echo -n $branch;
            set_color $color_label;     echo -n ')';

            # Write status
            set -l git_status   (git status --short 2>/dev/null)
            if test -z "$git_status"
                set_color $color_clear;  echo -n " $git_clean";
            else
                set_color $color_dirty;  echo -n " $git_dirty";
            end

            # In case of not enable full git info
            if test ! -z "$GIT_INFO_ENABLED"
                set -l after_head   (git rev-list --count @{u}..HEAD 2>/dev/null)
                set -l before_head  (git rev-list --count HEAD..@{u} 2>/dev/null)
                if test $after_head -gt 0 -a $before_head -eq 0
                    set_color $color_ahead; echo -n "[$git_ah$after_head]"
                else if test $after_head -eq 0 -a $before_head -gt 0
                    set_color $color_behind; echo -n "[$git_bh$before_head]"
                else if test $after_head -eq 0 -a $before_head -eq 0
                    echo -n ''
                else
                    set_color $color_akw; echo -n "$git_awk"
                end
            end
            return
        else if test ! -z "$detached"
            set -l tag_id   (echo $detached | tr ' ' '\n' | tail -n1)
            set_color $color_label;     echo -n '(HEAD:'
            set_color $color_branch;    echo -n $tag_id
            if is_str_contain_substr "$detached" "at"
                set_color $color_label;     echo -n ')'
            else if is_str_contain_substr "$detached" "from"
                set -l curr_id  (git rev-parse --short HEAD)
                set_color $color_label;     echo -n ' | current:'
                set_color $color_behind;    echo -n $curr_id
                set_color $color_label;     echo -n ')'
            else
                set_color $color_label;     echo -n ' | current: '
                set_color $color_akw;       echo -n "$git_awk"
                set_color $color_label;     echo -n ' )'
            end
            return
        else
            # do nothing
            return
        end
    end

    # Main process
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
