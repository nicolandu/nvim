return {
    -- Load immediately
    {
        'ellisonleao/gruvbox.nvim',
        lazy = false,
        priority = 1000,
    },

    -- UI

    {
        'nvim-lualine/lualine.nvim',
        opts = require('nvim-lualine-config')
    },

    { 'nvim-tree/nvim-web-devicons', },

    {
        'lewis6991/gitsigns.nvim',
        commit = 'd7e0bcbe45bd9d5d106a7b2e11dc15917d272c7a',
    },

    { 'tpope/vim-repeat', },
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        lazy = false,
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('nvim-tree').setup({})
        end,
    },
    {
        'jiaoshijie/undotree',
        dependencies = 'nvim-lua/plenary.nvim',
        config = true,
        keys = { -- load the plugin only when using it's keybinding:
            {
                '<leader>u', '<cmd>lua require("undotree").toggle()<cr>' },
        },
    },
    { 'kdheepak/lazygit.nvim', },
    { 'akinsho/toggleterm.nvim', version = '*', config = true },
    { 'kylechui/nvim-surround', },

    {
        'filipdutescu/renamer.nvim',
        branch = 'master',
        requires = {
            { 'nvim-lua/plenary.nvim' }
        }
    },

    { 'ggandor/leap.nvim', },

    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.4',
        opts = {
            extensions = {
                file_browser = {
                    -- disables netrw and { telescope-file-browser in its place
                    hijack_netrw = true,
                },
            },
        },
    },
    {
        'folke/noice.nvim',
        event = 'VeryLazy',
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module='...'` entries
            'MunifTanjim/nui.nvim',
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            'rcarriga/nvim-notify',
        }
    },

    -- LSP Support
    { 'williamboman/mason.nvim', },
    { 'williamboman/mason-lspconfig.nvim', },
    { 'neovim/nvim-lspconfig', },
    { 'simrat39/rust-tools.nvim' },

    -- Debugging
    { 'nvim-lua/plenary.nvim', },
    { 'mfussenegger/nvim-dap', },

    -- Treesitter
    { 'nvim-treesitter/nvim-treesitter', },

    -- Completion framework:
    { 'hrsh7th/nvim-cmp' },

    -- LSP completion source:
    { 'hrsh7th/cmp-nvim-lsp' },

    -- Useful completion sources:
    { 'hrsh7th/cmp-nvim-lua' },
    { 'hrsh7th/cmp-nvim-lsp', },
    { 'hrsh7th/cmp-nvim-lsp-signature-help' },
    { 'hrsh7th/cmp-vsnip' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-calc', },
    { 'hrsh7th/vim-vsnip' },

    -- Code actions
    {
        'weilbith/nvim-code-action-menu',
    },
}
