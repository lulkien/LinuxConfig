" check file type to enable auto make tags when save
let g:enable_tags = 'False'
autocmd BufNewFile,BufRead,BufReadPost *.h,*.c,*.cpp,*.pro let g:enable_tags = 'True'

" Disable auto comment in new line
autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Set working root diretory
let g:working_root_dir = getcwd()
