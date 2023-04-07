local api = vim.api

-- Function declaration
local function autocmd_evt(_event, _pattern, _command)
    api.nvim_create_autocmd( _event, { pattern = _pattern, command = _command })
end

local function autocmd_ft(_pattern, _command)
    api.nvim_create_autocmd("FileType", { pattern = _pattern, command = _command })
end

-- Auto command
autocmd_ft('*', 'setlocal formatoptions-=cro')
