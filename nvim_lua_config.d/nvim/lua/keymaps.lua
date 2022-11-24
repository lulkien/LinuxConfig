-- Function declaration
local function map(mode, key, action)
    vim.keymap.set(mode, key, action, { silent = true })
end

-- Keymap
-- Disable arrow keys
map('n', '<Up>',    '<Nop>')
map('n', '<Down>',  '<Nop>')
map('n', '<Left>',  '<Nop>')
map('n', '<Right>', '<Nop>')

map('i', '<Up>',    '<Nop>')
map('i', '<Down>',  '<Nop>')
map('i', '<Left>',  '<Nop>')
map('i', '<Right>', '<Nop>')

-- Some quickcast
map('n', '<Leader>q',   '<cmd>q!<CR>')
map('n', '<Leader>wq',  '<cmd>wq!<CR>')
map('n', '<Leader>cq',  '<cmd>cclose<CR>')

-- Mimic shell movements
map('i', '<C-h>',   '<C-o>^')
map('i', '<C-e>',   '<C-o>$')

-- Quickly save the current buffer or all buffers
map('n', '<leader>w',   '<CMD>update<CR>')
map('n', '<leader>W',   '<CMD>wall<CR>')

-- Line movements
map('n', '<A-j>',   '<cmd>move .+1<CR>==')
map('n', '<A-k>',   '<cmd>move .-2<CR>==')
map('i', '<A-j>',   '<Esc><cmd>move .+1<CR>==gi')
map('i', '<A-k>',   '<Esc><cmd>move .-2<CR>==gi')
map('x', '<A-j>',   ":move '>+1<CR>gv=gv")
map('x', '<A-k>',   ":move '<-2<CR>gv=gv")

-- Splitscreen
-- map('n', '<C-A-h>',     '<cmd>split<CR>')
-- map('n', '<C-A-v>',     '<cmd>vsplit<CR>')
