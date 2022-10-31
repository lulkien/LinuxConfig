" Auto replace word in git commit
fu! auto_replace#media()
    execute ':%s/<a>/MediaPlayer/g'
endf

fu! auto_replace#home()
    execute ':%s/<a>/AppHomeScreen/g'
endf

fu! auto_replace#help()
    execute ':%s/<a>/AppHelp/g'
endf

fu! auto_replace#stan()
    execute '%s/<a>/AppStandbyClock/g'
endf
