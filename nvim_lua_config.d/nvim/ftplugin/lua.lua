-- Function declaration
local function set_option(key, value)
  vim.api.nvim_set_option_value(key, value, { scope = 'local' })
end

local function map(mode, key, action)
  vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true })
end

-- Set option for lua
set_option('tabstop', 2)
set_option('softtabstop', 2)
set_option('shiftwidth', 2)

-- Set keymap
map('n', '<C-k><C-c>', 'I--<Esc>')
map('n', '<C-k><C-u>', '<cmd>s/^--//<CR><cmd>noh<CR>')
map('i', '<C-k><C-c>', '<C-o>^--')
map('i', '<C-k><C-u>', '<cmd>s/^--//<CR><cmd>noh<CR>i')
map('x', '<C-k><C-c>', 'I--<Esc>')
