local global = vim.g
local option = vim.o

-- GUI
option.termguicolors = true
option.guicursor = nil
option.noerrorbells = true

-- Decrease update time
option.timeoutlen = 500
option.updatetime = 200

-- Number of screen lines to keep above and below the cursor
option.scrolloff = 8

-- Better editor UI
option.number = true
option.relativenumber = true

-- Better editing
option.smartindent = true
option.tabstop = 4
option.softtabstop = 4
option.shiftwidth = 4
option.expandtab = true
option.textwidth = 180

-- Disable backup
option.backup = false
option.writebackup = false
option.swapfile = false

-- Search support
option.hlsearch = true
option.incsearch = true
option.ignorecase = true
option.smartcase = true

-- Highlight
vim.cmd.highlight('CursorLine', 'term=bold, cterm=none, gui=bold')

-- Mapleader
global.mapleader = ' ' 

-- Add path
--option.path += **
