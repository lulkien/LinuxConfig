" auto update tags when save file

fu! auto_tags#UpdateTags()
    if g:enable_tags ==# 'True'
        execute 'silent !ctags -R ' g:working_root_dir
    endif
endf


autocmd BufWritePost * call auto_tags#UpdateTags()
