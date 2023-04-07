function __qGitInfo --description "Get git information"
    # import color
    eval (cat ~/.config/fish/functions/__qEnv/colors)

    # Check git installed
    if not command -sq git
        return 1
    end

    # get current branch name
    set -l git_branch_name  (git branch --show-current 2>/dev/null)
    set -l git_rev_head     (git rev-parse --short HEAD 2>/dev/null)
    if test -z "$git_branch_name"
        if test -z "$git_rev_head"
            # not a git directory
            __qPrint
            return 1
        end
        # abnormal case, can't get branch name but get a HEAD rev id
        __qPrintColorB $cl_yellowL   -n  ' ('
        __qPrintColorB $cl_redL      -n  'HEAD'
        __qPrintColor  $cl_grayL     -n  '::'
        __qPrintColorB $cl_greenL    -n  $git_rev_head
        __qPrintColorB $cl_yellowL       ')'
        return 0
    end

    # normal case, get correct branch name
    __qPrintColorB $cl_yellowL       -n  ' ('
    __qPrintColorB $cl_magentaL      -n  'git'
    __qPrintColor  $cl_grayL         -n  '::'
    __qPrintColorB $cl_blueL         -n  $git_branch_name
    __qPrintColorB $cl_yellowL           ')'
    return 0
end
