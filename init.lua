vim.opt.mouse = "" -- disable mouse COMPLETELY
vim.opt.scrolloff = 5 -- 5 lines above/below cursor

vim.opt.number = true
vim.opt.relativenumber = true -- turn on hybrid line numbers

vim.opt.showmode = false -- already in status line

vim.opt.colorcolumn = {80} -- visual indicator for good coding style

-- No comment extension on other lines, except by wrapping
vim.api.nvim_create_autocmd({"FileType"}, {
    pattern = {"*"},
    callback =
        function() vim.opt.formatoptions = {o=false, r=false, c=true} end,
})

vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- use SPACES

vim.opt.autoindent = true

vim.opt.swapfile = false

vim.g.mapleader = " " -- space

vim.cmd([[
call plug#begin()

    " Theming
    Plug 'morhetz/gruvbox'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'ryanoasis/vim-devicons'
    Plug 'lewis6991/gitsigns.nvim', {'commit': 'd7e0bcbe45bd9d5d106a7b2e11dc15917d272c7a'}
    
    " Commands/UI
    Plug 'preservim/nerdtree'
    Plug 'mbbill/undotree'
    Plug 'lambdalisue/suda.vim'    
    Plug 'kdheepak/lazygit.nvim'


    " LSP Support
    Plug 'neovim/nvim-lspconfig'
    Plug 'williamboman/mason.nvim'
    Plug 'williamboman/mason-lspconfig.nvim'
    Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'compat-07'}
    
    " Linter support
    Plug 'mfussenegger/nvim-lint'

    " Autocompletion
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'L3MON4D3/LuaSnip'



call plug#end()
]])

vim.cmd('colorscheme gruvbox')

require('nvim-lualine-config') -- custom file to offload options

require('gitsigns').setup()

vim.g.undotree_SetFocusWhenToggle = 1

-- LSP STUFF

local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp_zero.default_keymaps({buffer = bufnr})
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
        lsp_zero.default_setup,
    },
})

require('lspconfig').lua_ls.setup({settings =
    {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing
            -- a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
})

require('lint').linters_by_ft = {
  python = {'mypy',}
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- Keybinds
vim.opt.timeout = true -- leader key
vim.opt.timeoutlen = 750 -- ms

local function map(mode, shortcut, command, expr, silent)
    vim.api.nvim_set_keymap(
        mode, shortcut, command, { expr = expr, noremap = true, silent = silent }
    )
end

local function nmap(shortcut, command, expr)
    map('n', shortcut, command, expr, true)
end

local function nmap_nosilent(shortcut, command, expr)
    map('n', shortcut, command, expr, false)
end

local function imap(shortcut, command, expr)
    map('i', shortcut, command, expr, false)
end

local function vmap(shortcut, command, expr)
    map('v', shortcut, command, expr, false)
end

local function xmap(shortcut, command, expr)
    map('x', shortcut, command, expr, false)
end

-- without count, j/k skip visual lines
nmap('j', "v:count ? 'j' : 'gj'", true) -- enable vim expr mode (last param)
nmap('k', "v:count ? 'k' : 'gk'", true)

imap('<C-c>', '<esc>')

nmap('<leader>', '<nop>')
vmap('<leader>', '<nop>') -- visual and select mode

nmap_nosilent('<leader>te', ':tabe ')
nmap('<leader>tn', ':tabnew<cr>')
nmap_nosilent('<leader>tm', ':tabm ')

nmap('<leader>h', ':nohls<cr>')

nmap('<leader>nt', ':silent NERDTreeMirror | :NERDTreeFocus<cr>')
nmap('<leader>ut', ':UndotreeShow<cr>')

xmap('<leader>p', '"_dP') -- delete into black hole, then paste backward
xmap('<leader>P', '"_d"+P') -- same, but from system clipboard

nmap('<leader>p', '"+p') -- paste from system clipboard
nmap('<leader>P', '"+P')

nmap('<leader>y', '"+y') -- yank to system clipboard
vmap('<leader>y', '"+y')
nmap('<leader>Y', '"+Y') -- same till end of line

nmap('<leader>d', '"_d') -- delete into black hole
vmap('<leader>d', '"_d')
nmap('<leader>c', '"_c')
nmap('<leader>x', '"_x')
nmap('<leader>s', '"_s')

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
]])

-- LSP keybinds
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({select = false}),
        ['<Tab>'] = cmp_action.luasnip_supertab(),
        ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
    }),
})
