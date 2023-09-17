local colors = {
    gray     = '#3C3C3C',
    lightred = '#D16969',
    blue     = '#569CD6',
    pink     = '#C586C0',
    black    = '#262626',
    white    = '#D4D4D4',
    green    = '#608B4E',
}

local code_dark_custom_theme = {
    normal = {
        b = { fg = colors.green, bg = colors.black },
        a = { fg = colors.black, bg = colors.green, gui = 'bold' },
        c = { fg = colors.white, bg = colors.black },
    },
    visual = {
        b = { fg = colors.pink, bg = colors.black },
        a = { fg = colors.black, bg = colors.pink, gui = 'bold' },
    },
    inactive = {
        b = { fg = colors.black, bg = colors.blue },
        a = { fg = colors.white, bg = colors.gray, gui = 'bold' },
    },
    replace = {
        b = { fg = colors.lightred, bg = colors.black },
        a = { fg = colors.black, bg = colors.lightred, gui = 'bold' },
        c = { fg = colors.white, bg = colors.black },
    },
    insert = {
        b = { fg = colors.blue, bg = colors.black },
        a = { fg = colors.black, bg = colors.blue, gui = 'bold' },
        c = { fg = colors.white, bg = colors.black },
    },
}

-- Taken from Lualine's internals and tweaked
local function padded_progress()
    local cur = vim.fn.line('.')
    local total = vim.fn.line('$')
    
    if cur == 1 then
        return 'Top'
    elseif cur == total then
        return 'Bot'
    else
        -- Pad percentage to 2 digits to prevent a shift in the powerline
        return string.format("%2d", math.floor(cur / total * 100)) .. "%%"
    end
end

require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = { left = '', right = ''},
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 100,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {
            { 'mode', separator = { left = '', right = '' }, right_padding = 2 },
        },
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = { padded_progress },
        lualine_z = {
            { 'location', separator = { left = '', right = '' }, left_padding = 2 },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
