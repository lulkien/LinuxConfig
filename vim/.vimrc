" PLUGINS
call plug#begin('~/.vim/bundle')

" Icons
    Plug 'ryanoasis/vim-devicons'

" Status bar
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

" Systax highlighting
    Plug 'dag/vim-fish'
    Plug 'vim-python/python-syntax'

" Intellisense
    Plug 'jiangmiao/auto-pairs'

" Colorscheme
    Plug 'joshdick/onedark.vim'

call plug#end()

" SETTING 
" Theme
colorscheme onedark

" Highlight the current line
set cursorline
:highlight Cursorline cterm=bold ctermbg=black

" highlight search pattern
set hlsearch

" Path include
set path+=**

" General Setting
set number
set relativenumber
set encoding=utf-8
set autoindent
set ignorecase

" Tab width
set tabstop=4
set shiftwidth=4
set expandtab

" Disable arrow keys
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Disable backup
set nobackup
set noswapfile
set nowb

" Disable auto comment in newline
autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Other function
for funct_file in split(glob('~/.vim/functions/*.vim'))
    execute 'source' funct_file
endfor
