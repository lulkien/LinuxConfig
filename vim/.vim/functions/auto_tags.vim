fu! auto_tags#UpdateTags()
    if g:enable_tags ==# 'True'
        execute 'silent !ctags -R .'
    endif
endf


autocmd BufWritePost * call auto_tags#UpdateTags()
