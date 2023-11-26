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

return {
    options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
        }
    },
    sections = {
        lualine_a = {
            { 'mode', --[[separator = { left = '', right = '' },]] left_padding = 1 },
        },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { padded_progress },
        lualine_z = {
            { 'location', --[[separator = { left = '', right = '' },]] right_padding = 1 },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}

}
