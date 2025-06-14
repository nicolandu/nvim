-- Disablk netrw at the very start of your init.luapicke
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Also at beginning
vim.g.nvimgdb_disable_start_keymaps = true

vim.opt.shell = 'fish'
-- No startup screen (equiv. to [blah blah blah].append([blah blah blah], 'I'))
vim.opt.shortmess:append('I')

vim.cmd('filetype plugin on')

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

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.rs' },
    callback =
        function()
            vim.opt.syntax = 'rust'
        end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
    pattern = { '*.tera' },
    callback =
        function()
            vim.opt.filetype = 'html'
        end,
})

vim.opt.wrap = true
vim.opt.linebreak = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- use SPACES

vim.opt.autoindent = true
vim.opt.swapfile = false

vim.g.mapleader = ' ' -- space

-- Hide trailing whitespace with .tex files
vim.g.trailing_whitespace_exclude_filetypes = { 'tex', 'git' }

-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.opt.updatetime = 300

-- increment/decrement letters
vim.opt.nrformats:append('alpha')

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
vim.opt.signcolumn = 'yes'
vim.cmd([[
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

require('lazy').setup({ spec = { import = 'plugins' }, rocks = { enabled = false } })

require('gruvbox').setup({})
vim.cmd('colorscheme gruvbox')
vim.cmd('hi link GitSignsAdd GruvboxGreenSign')
vim.cmd('hi link GitSignsChange GruvboxBlueSign')
vim.cmd('hi link GitSignsDelete GruvboxRedSign')

require('nvim-surround').setup({})
require('leap').add_default_mappings()

-- Hopefully fixes the invisible cursor?
vim.api.nvim_create_autocmd(
    "User",
    {
        callback = function()
            vim.cmd.hi("Cursor", "blend=100")
            vim.opt.guicursor:append { "a:Cursor/lCursor" }
        end,
        pattern = "LeapEnter"
    }
)
vim.api.nvim_create_autocmd(
    "User",
    {
        callback = function()
            vim.cmd.hi("Cursor", "blend=0")
            vim.opt.guicursor:remove { "a:Cursor/lCursor" }
        end,
        pattern = "LeapLeave"
    }
)

local telescope_custom_actions = {}

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
function telescope_custom_actions._multiopen(prompt_bufnr, open_cmd)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selected_entry = action_state.get_selected_entry()
    local num_selections = #picker:get_multi_selection()

    if not num_selections or num_selections <= 1 then
        actions.add_selection(prompt_bufnr)
    end

    actions.send_selected_to_qflist(prompt_bufnr)

    local initial_buf = vim.api.nvim_win_get_buf(picker.original_win_id)
    local initial_name = vim.api.nvim_buf_get_name(initial_buf)
    local initial_modified = vim.api.nvim_get_option_value("modified", { buf = initial_buf })

    vim.cmd("cfdo " .. open_cmd)

    if initial_name == "" and not initial_modified then
        vim.cmd('bdelete ' .. initial_buf)
    end
end

function telescope_custom_actions.multi_selection_open_vsplit(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "vsplit")
end

function telescope_custom_actions.multi_selection_open_split(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "split")
end

function telescope_custom_actions.multi_selection_open_tab(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "tabe")
end

function telescope_custom_actions.multi_selection_open(prompt_bufnr)
    telescope_custom_actions._multiopen(prompt_bufnr, "edit")
end

require('telescope').setup({
    extensions = {
        file_browser = {
            -- disables netrw and uses telescope-file-browser in its place
            hijack_netrw = true,
        },
    },
    defaults = {
        file_ignore_patterns = { "node_modules", ".git" },
        mappings = {
            i = {
                ["<ESC>"] = actions.close,
                ["<C-J>"] = actions.move_selection_next,
                ["<C-K>"] = actions.move_selection_previous,
                ["<CR>"] = actions.select_default,
                ["<TAB>"] = actions.nop,
                ["<S-TAB>"] = actions.nop,
            },
            n = i,
        },
    },
    pickers = {
        -- used to show code actions
        find_files = {
            mappings = {
                i = {
                    ["<ESC>"] = actions.close,
                    ["<C-J>"] = actions.move_selection_next,
                    ["<C-K>"] = actions.move_selection_previous,
                    ["<TAB>"] = actions.toggle_selection,
                    ["<C-TAB>"] = actions.toggle_selection + actions.move_selection_next,
                    ["<S-TAB>"] = actions.toggle_selection + actions.move_selection_previous,
                    ["<CR>"] = telescope_custom_actions.multi_selection_open,
                    ["<C-V>"] = telescope_custom_actions.multi_selection_open_vsplit,
                    ["<C-S>"] = telescope_custom_actions.multi_selection_open_split,
                    ["<C-T>"] = telescope_custom_actions.multi_selection_open_tab,
                    ["<C-DOWN>"] = actions.cycle_history_next,
                    ["<C-UP>"] = actions.cycle_history_prev,
                },
                n = i,
            },
        },
        live_grep = find_files,
    },

}
)

require('mason').setup({})
require('mason-lspconfig').setup({
    automatic_installation = true
})

require('renamer').setup({})

require('noice').setup({
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        },
    },
    -- you can enable a preset for easier configuration
    presets = {
        bottom_search = true,   -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        inc_rename = false,     -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },

    -- Override long_message_to_split length
    routes = {
        {
            filter = { event = "msg_show", min_height = 10 },
            view = "cmdline_output",
        },
        {
            view = "mini",
            filter = {
                event = "msg_showmode",
                any = {
                    { find = "recording" },
                },
            },
        },
    },
})

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
---@diagnostic disable-next-line: redundant-parameter
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
            select = false,
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
        completion = {
            border = "rounded",
        },
        documentation = {
            border = "rounded",
        }
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

require('lspconfig').html.setup({})
require('lspconfig').cssls.setup({})

require('lspconfig').bashls.setup({})

-- XML
require('lspconfig').lemminx.setup({})

-- Toml
require('lspconfig').taplo.setup({})

require('lspconfig').ts_ls.setup({})
require('lspconfig').clangd.setup({
    capabilities = capabilities,
})
require('lspconfig').pyright.setup({
    capabilities = capabilities,
    settings = {
    }
})
require('lspconfig').autopep8.setup({
    capabilities = capabilities,
    settings = {
    }
})
require('lspconfig').texlab.setup({
    capabilities = capabilities,
    settings = {
        texlab = {
            diagnostics = {
                ignoredPatterns = { "[Uu]ndefined [Rr]eference" }
            }
        }
    }
})

vim.g.tex_flavor = "latex"
require('lspconfig').ltex.setup({
    on_attach = function()
        require('ltex_extra').setup {
            -- This is where your dictionary will be stored! Replace this directory with
            -- whatever you want!
            load_langs = { 'fr', 'en' },
            path = vim.fn.expand '~' .. '/.config/nvim/ltex',
        }
    end,
    capabilities = capabilities,
    filetypes = { "latex", "tex", "bib", "markdown", "gitcommit", "text" },
    settings = {
        ltex = {
            enabled = { "latex", "tex", "bib", "markdown", },
            language = "auto",
            diagnosticSeverity = "information",
            sentenceCacheSize = 2000,
            additionalRules = {
                enablePickyRules = false,
                motherTongue = "fr",
            },
            checkFrequency = "save",
            completionEnabled = true,
            dictionary = (function()
                -- For dictionary, search for files in the runtime to have
                -- and include them as externals the format for them is
                -- dict/{LANG}.txt
                --
                -- Also add dict/default.txt to all of them
                local files = {}
                for _, file in ipairs(vim.api.nvim_get_runtime_file("dict/*", true)) do
                    local lang = vim.fn.fnamemodify(file, ":t:r")
                    local fullpath = vim.fs.normalize(file, ":p")
                    files[lang] = { ":" .. fullpath }
                end

                if files.default then
                    for lang, _ in pairs(files) do
                        if lang ~= "default" then
                            vim.list_extend(files[lang], files.default)
                        end
                    end
                    files.default = nil
                end
                return files
            end)(),
        },
    },
})

local rt = require("rust-tools")

rt.setup({
    capabilities = capabilities,
    server = {
        settings = {
            ["rust-analyzer"] = {
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
})

-- Server cancelled the request shenanigans
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end


-- Treesitter Plugin Setup
require('nvim-treesitter.configs').setup {
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

local null_ls = require('null-ls')
null_ls.setup({
    sources = { null_ls.builtins.formatting.black.with({
        extra_args = { "--line-length=120" },
    }),
        null_ls.builtins.formatting.isort,
    }
})

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

local function tmap(shortcut, command, expr)
    map('t', shortcut, command, expr, true)
end

-- without count, j/k skip visual lines
nmap('j', "v:count ? 'j' : 'gj'", true) -- enable vim expr mode (last param)
nmap('k', "v:count ? 'k' : 'gk'", true)
-- without count, j/k skip visual lines

vmap('j', "v:count ? 'j' : 'gj'", true) -- enable vim expr mode (last param)
vmap('k', "v:count ? 'k' : 'gk'", true)

imap('<C-c>', '<esc>')

nmap('<leader>', '<nop>')
vmap('<leader>', '<nop>') -- visual and select mode

nmap('<leader>tn', ':tabnew<cr>')

nmap('<leader>h', ':nohls<cr>')

nmap('<leader>nt', ':NvimTreeOpen<cr>')
nmap('<leader>nT', ':NvimTreeOpen .<cr>')

nmap('<leader>ff', ':Telescope find_files<cr>')
nmap('<leader>fb', ':Telescope buffers<cr>')
nmap('<leader>fg', ':Telescope live_grep<cr>')
nmap('<leader>fs', ':Telescope lsp_document_symbols<cr>')
nmap('<leader>fd', ':Telescope diagnostics<cr>')

nmap('gx', [[:execute '!open ' . shellescape(expand('<cfile>'), 1)<cr>]])

xmap('<leader>p', '"_dP')   -- delete into black hole, then paste backward
xmap('<leader>P', '"_d"+P') -- same, but from system clipboard

nmap('<leader>p', '"+p')    -- paste from system clipboard
nmap('<leader>P', '"+P')

nmap('<leader>y', '"+y') -- yank to system clipboard
vmap('<leader>y', '"+y')
nmap('<leader>Y', '"+Y') -- same till end of line

nmap('<leader>d', '"_d') -- delete into black hole
nmap('<leader>D', '"_D')
vmap('<leader>d', '"_d')
nmap('<leader>c', '"_c')
vmap('<leader>c', '"_c')
nmap('<leader>C', '"_C')
nmap('<leader>x', '"_x')
nmap('<leader>s', '"_s')

tmap('<esc>', '<C-\\><C-N>')
tmap('<C-W>', '<C-\\><C-N><C-W>')


local function quickfix()
    vim.lsp.buf.code_action({
        filter = function(a) return a.isPreferred end,
        apply = true
    })
end

local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>cc', quickfix, opts)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', '<leader>td', vim.lsp.buf.type_definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
vim.keymap.set('n', '<leader>o', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '<f2>', vim.lsp.buf.rename, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<f3>', vim.lsp.buf.format, opts)
vim.keymap.set({ 'v', 'n' }, '<leader>ca', require("actions-preview").code_actions)
vim.keymap.set('n', '<leader>ll', ':GdbStartLLDB lldb ./')
nmap('<leader>lp', ':GdbStartPDB python3 -m pdb ./')


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


-- Auto format on save for all files except some
vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local no_rename = {
            tex = true,
            text = true,
            html = true,
            htmldjango = true,
            svg = true,
            markdown = true,
        }
        if not no_rename[filetype] then
            vim.lsp.buf.format({ async = false })
        end
    end,
})

vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
    pattern = { "*" },
    callback = function()
        if vim.opt.buftype:get() == "terminal" then
            vim.cmd(":startinsert")
        end
    end
})
vim.cmd([[ autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc ]])
