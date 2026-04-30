local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                transparent = true,
                styles = {
                    sidebars = "transparent",
                    floats = "transparent",
                },
            })
            vim.cmd.colorscheme("tokyonight")
        end,
    },

    -- Completion
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        version = "*",
        opts = {
            keymap = {
                preset = "enter",
                ["<Up>"] = { "select_prev", "fallback" },
                ["<Down>"] = { "select_next", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            completion = {
                keyword = { range = "prefix" },
                menu = {
                    draw = {
                        treesitter = { "lsp" },
                    },
                },
                trigger = { show_on_trigger_character = true },
                documentation = {
                    auto_show = true,
                },
            },
            signature = { enabled = true },
        },
        opts_extend = { "sources.default" },
    },

    -- LSP installer
    { "mason-org/mason.nvim", opts = {} },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            -- Enable treesitter highlighting when a buffer with a filetype is opened
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    pcall(vim.treesitter.start, args.buf)
                end,
            })
        end,
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "filetype" },
                    lualine_y = { "location" },
                    lualine_z = {},
                },
            })
        end,
    },

    -- Git signs in gutter
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup({
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local map = function(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    map("n", "]h", gs.next_hunk, { desc = "Next git hunk" })
                    map("n", "[h", gs.prev_hunk, { desc = "Prev git hunk" })
                    map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
                    map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
                    map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
                end,
            })
        end,
    },

    -- Fuzzy finder, file explorer, word highlights
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("snacks").setup({
                picker = { enabled = true },
                explorer = { enabled = true },
                words = { enabled = true },
            })
        end,
    },

    -- Mini modules: auto-pairs, commenting, surrounds
    { "echasnovski/mini.pairs", opts = {} },
    { "echasnovski/mini.comment", opts = {} },
    { "echasnovski/mini.surround", opts = {} },

    -- Diagnostics list
    {
        "folke/trouble.nvim",
        cmd = { "Trouble" },
        opts = {},
    },

    -- Highlight TODO/FIXME/HACK comments
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "BufReadPost",
        opts = {},
    },

    -- Better command line and notifications
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        opts = {
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        },
    },

    -- Formatting
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        opts = {
            format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
            formatters_by_ft = {
                python = { "ruff_format" },
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                go = { "gofmt" },
                rust = { "rustfmt" },
            },
        },
    },

    -- Linting
    {
        "mfussenegger/nvim-lint",
        event = "BufReadPost",
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                python = { "ruff" },
                javascript = { "eslint" },
                typescript = { "eslint" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function()
                    pcall(lint.try_lint)
                end,
            })
        end,
    },

    -- Git interface
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
        cmd = "Neogit",
        opts = {},
    },

    -- Cursor trail effect
    {
        "gen740/smoothcursor.nvim",
        config = function()
            require("smoothcursor").setup({
                type = "exp",
                fancy = {
                    enable = true,
                    head = { cursor = ">", texthl = "SmoothCursor", linehl = nil },
                    body = {
                        { cursor = "●", texthl = "SmoothCursorRed" },
                        { cursor = "●", texthl = "SmoothCursorOrange" },
                        { cursor = "●", texthl = "SmoothCursorYellow" },
                        { cursor = "●", texthl = "SmoothCursorGreen" },
                        { cursor = "●", texthl = "SmoothCursorAqua" },
                        { cursor = "●", texthl = "SmoothCursorBlue" },
                        { cursor = "●", texthl = "SmoothCursorPurple" },
                    },
                    tail = { cursor = nil, texthl = "SmoothCursor" },
                },
            })
        end,
    },

    -- Smooth animations
    {
        "echasnovski/mini.animate",
        config = function()
            require("mini.animate").setup({
                cursor = { enable = true },
                scroll = { enable = true },
                resize = { enable = true },
                open = { enable = true },
                close = { enable = true },
            })
        end,
    },

    -- Smooth scrolling
    {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup({
                mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
            })
        end,
    },

})
