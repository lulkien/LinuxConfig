"----------------------------- LOAD PLUGINS -----------------------------
call plug#begin('~/.config/nvim/bundles')

" Better Syntax Support
Plug 'sheerun/vim-polyglot'

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

" Telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

" Colorscheme
Plug 'joshdick/onedark.vim'

call plug#end()

"----------------------------- POST LOAD PLUGINS -----------------------------
" Theme
colorscheme onedark
highlight Normal guibg=none
set cursorline
highlight CursorLine term=bold cterm=none gui=bold
