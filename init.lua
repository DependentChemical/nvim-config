vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

--------------------------------------------------
-- lazy.nvim bootstrap
--------------------------------------------------

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

--------------------------------------------------
-- plugins
--------------------------------------------------

require("lazy").setup({

    -- Tokyonight Colorscheme
    {
        "folke/tokyonight.nvim",
        lazy = false,    -- Make sure it loads during startup
        priority = 1000, -- Load this before all other plugins
        opts = {
            style = "night", -- Choose between: storm, moon, night, day
            transparent = true, -- Set to true if you want a transparent background
        },
    },

    -- GameMaker syntax
    {
        "JafarDakhan/vim-gml",
    },

    -- Statusline (Lualine) & Icons
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "auto", -- Automatically picks up tokyonight!
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                globalstatus = true,
            },
            sections = {
                lualine_a = { "branch" },
                lualine_b = { "diff", "diagnostics" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" }
            },
        },
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },

    -- Oil (filesystem as a buffer)
    {
        "stevearc/oil.nvim",
        opts = {
            view_options = {
                show_hidden = true,
            },
        },
    },

    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = function()
            require("nvim-treesitter").install({
                "lua", "vim", "vimdoc", "bash", "json", "yaml",
                "toml", "markdown", "markdown_inline", "rust",
                "c", "cpp", "python",
            }):wait(60000)
        end,
    },

    -- Mason
    {
        "mason-org/mason.nvim",
        opts = {},
    },

    {
        "mason-org/mason-lspconfig.nvim",
        opts = {
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "clangd",
                "jsonls",
                "powershell_es",
                "pyrefly",
            },
        },
    },

    -- LSP
    {
        "neovim/nvim-lspconfig",
    },

    -- Blink (stable v1)
    {
        "Saghen/blink.cmp",
        version = "1.*",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },

        opts = {
            keymap = {
                preset = "super-tab",
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
            },

            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                },
            },

            fuzzy = {
                implementation = "prefer_rust",
            },
        },
    },
})

--------------------------------------------------
-- load colorscheme
--------------------------------------------------

vim.cmd[[colorscheme tokyonight]]

--------------------------------------------------
-- word wrap per filetype
--------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function()
        if vim.bo.filetype ~= "markdown" then
            vim.opt_local.wrap = false
        end
    end,
})

--------------------------------------------------
-- telescope keybinds
--------------------------------------------------

local ok, builtin = pcall(require, "telescope.builtin")
if ok then
    vim.keymap.set("n", "<leader>ff", builtin.find_files)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>fb", builtin.buffers)
    vim.keymap.set("n", "<leader>fh", builtin.help_tags)
end

-- Oil: open parent directory
vim.keymap.set("n", "<leader>o", "<cmd>Oil<cr>", { desc = "Open Oil (file explorer)" })

--------------------------------------------------
-- LSP
--------------------------------------------------

local ok, blink = pcall(require, "blink.cmp")
local capabilities = ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()

--------------------------------------------------
-- LSP server configs
--------------------------------------------------

vim.lsp.config("rust_analyzer", {
    capabilities = capabilities,
})

vim.lsp.config("clangd", {
    capabilities = capabilities,
})

vim.lsp.config("powershell_es", {
    capabilities = capabilities,
    cmd = {
        "pwsh", "-NoLogo", "-NoProfile", "-Command",
        vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1",
        "-BundledModulesPath", vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        "-LogPath", vim.fn.stdpath("data") .. "/powershell_es.log",
        "-SessionDetailsPath", vim.fn.stdpath("data") .. "/powershell_es.session.json",
        "-FeatureFlags", "@{}",
        "-AdditionalModules", "@()",
        "-HostName", "nvim",
        "-HostProfileId", "0",
        "-HostVersion", "0.0.0",
        "-Stdio", "-LogLevel", "Normal",
    },
})

vim.lsp.config("pyrefly", {
    capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    settings = {
        Lua = {
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
            },
        },
    },
})

--------------------------------------------------
-- JSON LSP
--------------------------------------------------

vim.lsp.config("jsonls", {
    capabilities = capabilities,
    settings = {
        json = {
            validate = { enable = true },
            schemas = {},
        },
    },
})

--------------------------------------------------
-- enable servers
--------------------------------------------------

vim.lsp.enable({
    "rust_analyzer",
    "clangd",
    "powershell_es",
    "pyrefly",
    "jsonls",
    "lua_ls",
})