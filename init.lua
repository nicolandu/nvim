-- no startup screen (equiv. to [blah blah blah].append([blah blah blah], 'I'))
vim.opt.shortmess:append('I')

vim.opt.mouse = ''    -- disable mouse COMPLETELY
vim.opt.scrolloff = 5 -- 5 lines above/below cursor

vim.opt.number = true
vim.opt.relativenumber = true -- turn on hybrid line numbers

vim.opt.showmode = false      -- already in status line
vim.opt.signcolumn = 'yes'

-- Extend comments in insert mode, but not in normal mode
vim.api.nvim_create_autocmd({ 'FileType' }, {
    pattern = { '*' },
    callback =
        function()
            vim.opt.formatoptions = { o = false, r = true, c = true }
        end,
})


vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- use SPACES

vim.opt.autoindent = true
vim.opt.swapfile = false
vim.opt.lazyredraw = true

vim.g.mapleader = ' ' -- space

-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.api.nvim_set_option('updatetime', 300)

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins')

require('gruvbox').setup({})
vim.cmd('colorscheme gruvbox')
vim.cmd('hi link GitSignsAdd GruvboxGreenSign')
vim.cmd('hi link GitSignsChange GruvboxBlueSign')
vim.cmd('hi link GitSignsDelete GruvboxRedSign')

require('gitsigns').setup({})

require('nvim-surround').setup({})
require('leap').add_default_mappings()

require('mason').setup({})
require('mason-lspconfig').setup({})

require('renamer').setup({})

-- Completion Plugin Setup

local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require('cmp')
cmp.setup({
    view = {
        entries = { name = 'custom', selection_order = 'near_cursor' }
    },
    -- Enable LSP snippets
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        -- Add tab support
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
                feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
                cmp.complete()
            else
                fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                feedkey("<Plug>(vsnip-jump-prev)", "")
            end
        end, { "i", "s" }),
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.close(),
        ['<cr>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        })
    },
    -- Installed sources:
    sources = {
        { name = 'path' },                                       -- file paths
        { name = 'nvim_lsp',               keyword_length = 3 }, -- from language server
        { name = 'nvim_lsp_signature_help' },                    -- display function signatures with current parameter emphasized
        { name = 'nvim_lua',               keyword_length = 2 }, -- complete neovim's Lua runtime API such vim.lsp.*
        { name = 'buffer',                 keyword_length = 2 }, -- source current buffer
        { name = 'vsnip',                  keyword_length = 2 }, -- nvim-cmp source for vim-vsnip
        { name = 'calc' },                                       -- source for math calculation
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    formatting = {
        fields = { 'menu', 'abbr', 'kind' },
        format = function(entry, item)
            local menu_icon = {
                nvim_lsp = 'λ',
                vsnip = '⋗',
                buffer = 'Ω',
                path = '🖫',
            }
            item.menu = menu_icon[entry.source.name]
            return item
        end,
    },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('lspconfig').lua_ls.setup({
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file('', true),
                -- No Luassert
                checkThirdParty = false,
            },
        },
    },
})

require('lspconfig').clangd.setup({
    capabilities = capabilities,
    settings = {
        Clangd = {
            cmd = { 'clangd', '-header-insertion=never' }
        }
    }
})

local rt = require("rust-tools")

rt.setup({
    capabilities = capabilities,
    server = {
        on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
        end,

        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
})


-- Treesitter Plugin Setup
require('nvim-treesitter.configs').setup {
    ensure_installed = { "lua", "rust", "toml" },
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    ident = { enable = true },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    }
}


local signs = { Error = "", Warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Keybinds
vim.opt.timeout = true   -- leader key
vim.opt.timeoutlen = 750 -- ms

local function map(mode, shortcut, command, expr, silent)
    vim.api.nvim_set_keymap(
        mode, shortcut, command, { expr = expr, noremap = true, silent = silent }
    )
end

local function nmap(shortcut, command, expr)
    map('n', shortcut, command, expr, true)
end

local function imap(shortcut, command, expr)
    map('i', shortcut, command, expr, true)
end

local function vmap(shortcut, command, expr)
    map('v', shortcut, command, expr, true)
end

local function xmap(shortcut, command, expr)
    map('x', shortcut, command, expr, true)
end

-- without count, j/k skip visual lines
nmap('j', "v:count ? 'j' : 'gj'", true) -- enable vim expr mode (last param)
nmap('k', "v:count ? 'k' : 'gk'", true)

imap('<C-c>', '<esc>')

nmap('<leader>', '<nop>')
vmap('<leader>', '<nop>') -- visual and select mode

nmap('<leader>tn', ':tabnew<cr>')

nmap('<leader>h', ':nohls<cr>')

nmap('<leader>nt', ':NvimTreeOpen<cr>')

nmap('<leader>ff', ':Telescope find_files<cr>')
nmap('<leader>fb', ':Telescope buffers<cr>')
nmap('<leader>fg', ':Telescope live_grep<cr>')
nmap('<leader>fs', ':Telescope lsp_document_symbols<cr>')
nmap('<leader>fd', ':Telescope diagnostics<cr>')

nmap('<leader>lg', ':LazyGit<cr>')
nmap('<leader>te', '<cmd>exe v:count1 . "ToggleTerm"<cr>')

xmap('<leader>p', '"_dP')   -- delete into black hole, then paste backward
xmap('<leader>P', '"_d"+P') -- same, but from system clipboard

nmap('<leader>p', '"+p')    -- paste from system clipboard
nmap('<leader>P', '"+P')

nmap('<leader>y', '"+y') -- yank to system clipboard
vmap('<leader>y', '"+y')
nmap('<leader>Y', '"+Y') -- same till end of line

nmap('<leader>d', '"_d') -- delete into black hole
vmap('<leader>d', '"_d')
nmap('<leader>c', '"_c')
nmap('<leader>x', '"_x')
nmap('<leader>s', '"_s')


local function quickfix()
    vim.lsp.buf.code_action({
        filter = function(a) return a.isPreferred end,
        apply = true
    })
end

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>cc', quickfix, opts)
nmap('<leader>ca', ':CodeActionMenu<cr>')

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<f3>', vim.lsp.buf.format, opts)

vim.keymap.set({ 'n', 'v' }, '<leader>rn', require('renamer').rename, opts)
vim.keymap.set('i', '<f2>', require('renamer').rename, opts)

-- difficult to port to lua, so just embed
vim.cmd([[
let g:esc_j_lasttime = 0
let g:esc_k_lasttime = 0
function! JKescape(key)
	if a:key=='j' | let g:esc_j_lasttime = reltimefloat(reltime()) | endif
	if a:key=='k' | let g:esc_k_lasttime = reltimefloat(reltime()) | endif
	let l:timediff = abs(g:esc_j_lasttime - g:esc_k_lasttime)
	return (l:timediff <= 0.07 && l:timediff >=0.001) ? "\b\e" : a:key
endfunction
inoremap <expr> j JKescape('j')
inoremap <expr> k JKescape('k')
tnoremap <expr> j JKescape('j')
tnoremap <expr> k JKescape('k')
vnoremap <expr> j JKescape('j')
vnoremap <expr> k JKescape('k')
]])


vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    pattern = { '*' },
    callback =
        function()
            vim.lsp.buf.format()
        end,
})
