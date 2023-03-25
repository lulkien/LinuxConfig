function fish_prompt --description 'Write out the prompt'
    # import color
    eval (cat ~/.config/fish/functions/__qEnv/colors)

    # Set variables
    set -l start_cmd    ' >> '

    # Print
    __qPrintColorB $cl_blueL      -n  '[ '
    __qPrintColorB $cl_hostname   -n  $USER@(prompt_hostname) ' '
    __qPrintColor  $cl_pwd        -n  (prompt_pwd)
    __qPrintColorB $cl_blueL      -n  ' ]'
    __qGitInfo
    __qPrintColorB $cl_cyanL      -n  $start_cmd
end
status is-interactive || exit

