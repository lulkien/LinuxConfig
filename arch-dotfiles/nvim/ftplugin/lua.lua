-- Function declaration
local function set_option(key, value)
  vim.api.nvim_set_option_value(key, value, { scope = 'local' })
end

local function map(mode, key, action)
  vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true })
end

-- Set option for lua
-- Set option for lua
-- Set option for lua
-- Set option for lua
set_option('tabstop', 2)
set_option('softtabstop', 2)
set_option('shiftwidth', 2)

-- Set keymap
--map('n', '<A-Bslash>',  '0i-- <Esc>')
--map('n', '<A-BS>',      '<cmd>s!^-- !!<CR><cmd>noh<CR>')
--map('i', '<A-Bslash>',  '<C-o>0-- ')
--map('i', '<A-BS>',      '<cmd>s!^-- !!<CR><cmd>noh<CR>')
