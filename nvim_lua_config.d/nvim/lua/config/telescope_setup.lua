-- Function declaration
local function map(mode, key, action)
    vim.api.nvim_set_keymap(mode, key, action, { noremap = true, silent = true } )
end

-- Keymaps
map('n', '<Leader>ff', '<cmd>Telescope find_files<CR>')
map('n', '<Leader>lg', '<cmd>Telescope live_grep<CR>')
map('n', '<Leader>gs', '<cmd>Telescope grep_string<CR>')
