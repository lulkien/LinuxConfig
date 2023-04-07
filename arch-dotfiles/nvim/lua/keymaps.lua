-- Function declaration
local function map(mode, key, action)
    vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true })
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
map('i', '<A-h>',   '<C-o>^')
map('i', '<A-l>',   '<C-o>$')
map('n', '<A-h>',   '^')
map('n', '<A-l>',   '$')

map('n', '<C-h>',   'b')
map('n', '<C-l>',   'e')
map('n', '<C-L>',   'w')
map('n', '<C-j>',   '<C-d>')
map('n', '<C-k>',   '<C-u>')

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

-- Disable unwant keys
map('n', '<C-c>',   '<Esc><Esc><Esc>')
map('x', '<C-c>',   '<Esc><Esc><Esc>')
map('i', '<C-c>',   '<Esc><Esc><Esc>')
map('n', '<BS>' ,   '<Nop>')
