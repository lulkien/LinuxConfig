local api = vim.api

-- Function declaration
local function auto_event(_event, _pattern, _command)
    api.nvim_create_autocmd( _event, { pattern = _pattern, command = _command })
end

local function auto_type(_pattern, _command)
    api.nvim_create_autocmd("FileType", { pattern = _pattern, command = _command })
end

-- Auto command
auto_type('*', 'setlocal formatoptions-=cro')
