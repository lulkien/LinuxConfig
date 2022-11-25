-- Some defines
local feline = require('feline')
local vi_mode = require('feline.providers.vi_mode')
local LEFT = 1
local MID = 2
local RIGHT = 3
local api = vim.api

-- Color palette
local MODE_COLORS = {
    ['NORMAL']      =   '#87D787',
    ['COMMAND']     =   '#87D787',
    ['INSERT']      =   '#00AFFF',
    ['REPLACE']     =   '#FF5F87',
    ['LINES']       =   '#D75FD7',
    ['VISUAL']      =   '#D75FD7',
    ['BLOCK']       =   '#D75FD7',
    ['V-REPLACE']   =   '#FF5F87',
    ['OP']          =   '#87D787',
    ['ENTER']       =   '#87D787',
    ['MORE']        =   '#87D787',
    ['SELECT']      =   '#87D787',
    ['SHELL']       =   '#87D787',
    ['TERM']        =   '#87D787',
    ['NONE']        =   '#87D787',
}

local ONEDARK = {
    bg          =   '#2C323C',
    fg          =   '#ABB2BF',
    black       =   '#282C34',
    violet      =   '#C678DD',
    magenta     =   '#C678DD',
    oceanblue   =   '#61AFEF',
    cyan        =   '#56B6C2',
    green       =   '#98C379',
    skyblue     =   '#61AFEF',
    yellow      =   '#E5C07B',
    orange      =   '#D19A66',
    red         =   '#E06C75',
    white       =   '#ABB2BF',
}

-- Init
local used_theme = ONEDARK

-- Function declaration
function get_filename()
    local filename = api.nvim_buf_get_name(0)
    if filename == '' then
        filename = '[no name]'
    end
    return filename
end

function get_posision(arg)
    local _row, _col = unpack(api.nvim_win_get_cursor(0))
    if arg == 'row' then
        return _row
    elseif arg == 'col' then
        return _col
    else
        local pos = {
            col = _col,
            row = _row,
        }
        return pos
    end
end

function get_total_line()
    return api.nvim_buf_line_count(0)
end

function get_filetype()
    local filetype = vim.bo.filetype
    if filetype == '' then
        filetype = '[no type]'
    end
    return string.upper(filetype)
end

function get_osinfo()
    local os = vim.bo.fileformat
    return string.upper(os)
end

function get_encoding()
    local encoding = vim.o.encoding
    return string.upper(encoding)
end

-- Components
local components = {
    active = {
        {}, --Left
        {}, --Mid
        {}, --Right
    },
    inactive = {
        {}, --Left
        {}, --Right
    }
}

-- Insert component for MODE NAME
table.insert(components.active[LEFT], {
    name = 'mode',
    provider = function()
        return ' ' .. vi_mode.get_vim_mode() .. ' '
    end,
    hl = function()
        local val = {}
        val.bg = vi_mode.get_mode_color()
        val.fg = used_theme.black
        val.style = 'bold'
        return val
    end,
})

-- Insert component for FILE NAME
table.insert(components.active[LEFT], {
    name  = 'filename',
    provider = function()
        return ' ' .. get_filename()
    end,
    hl = function()
        local val = {}
        val.bg = used_theme.bg
        val.fg = vi_mode.get_mode_color()
        return val
    end,
    right_sep = ' ',
})

-- Insert component for FILE TYPE
table.insert(components.active[RIGHT], {
    name = 'filetype',
    provider = function()
        return ' ' .. get_filetype() .. ' '
    end,
    hl = function() 
        local val = {}
        val.bg = used_theme.yellow
        val.fg = used_theme.black
        return val
    end,
})

-- Insert component for ENCODING
table.insert(components.active[RIGHT], {
    name = 'encoder',
    provider = function()
        return ' ' .. get_encoding() .. ' '
    end,
    hl = function()
        local val = {}
        val.bg = used_theme.orange
        val.fg = used_theme.black
        return val
    end,
})

-- Insert component for OS NAME
table.insert(components.active[RIGHT], {
    name = 'osname',
    provider = function()
        return ' ' .. get_osinfo() .. ' '
    end,
    hl = function()
        local val = {}
        val.bg = used_theme.red
        val.fg = used_theme.black
        return val
    end,
})

-- Insert component for POSITION
table.insert(components.active[RIGHT], {
    name = 'position',
    provider = function()
        local pos = get_posision()
        local total = get_total_line()
        return ' row:' .. pos.row .. ' | column:' .. pos.col .. ' | total:' .. total .. ' '
    end,
    hl = function()
        local val = {}
        val.bg = used_theme.skyblue
        val.fg = used_theme.black
        return val
    end,
})

-- Insert FILE NAME if inactive
table.insert(components.inactive[LEFT], {
    name  = 'filename',
    provider = get_filename(),
    hl = function()
        local val = {}
        val.bg = used_theme.bg
        val.fg = vi_mode.get_mode_color()
        return val
    end,
})

-- Finalize
feline.setup({
    theme = used_theme,
    components = components,
    vi_mode_colors = MODE_COLORS,
})
