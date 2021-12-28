" auto update tags when save file

fu! auto_tags#UpdateTags()
    if g:enable_tags ==# 'True'
        execute 'silent !ctags -R ' g:working_root_dir
    endif
endf

fu! TagThisFile()
    let g:enable_tags = 'True'
endf


autocmd BufWritePost * call auto_tags#UpdateTags()
