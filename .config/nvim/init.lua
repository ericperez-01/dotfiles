-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Set home directory as default
vim.cmd("cd $HOME")

-- Neovide settings for macOS
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_refresh_rate = 60
  vim.opt.guifont = "FiraCode Nerd Font:h13" -- Install with `brew install --cask font-fira-code-nerd-font`
  vim.g.neovide_transparency = 0.95         -- Optional: slight transparency
  vim.keymap.set('t', '<D-v>', [[<C-\><C-n>"+pi]], { noremap = true }) -- Paste from clipboard in terminal mode"]
end

-- Leader key
vim.g.mapleader = " "

-- Lazy.nvim setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Plugins
require("lazy").setup({
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {}
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
  },
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {}
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep, {})
    end,
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "lua", "javascript", "python", "html", "css" },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },
  { "yetone/avante.nvim", event = "VeryLazy", build = "make",
    dependencies = { "nvim-treesitter/nvim-treesitter", "stevearc/dressing.nvim", "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    config = function()
      require("avante").setup {
        provider = "claude",
        model = "claude-3-7-sonnet-20240229",
        api_key_name = "ANTHROPIC_API_KEY",
      }
      vim.keymap.set("n", "<leader>a", ":AvanteAsk<CR>", { desc = "Ask LLM" })
    end,
  },
  { "mg979/vim-visual-multi", branch = "master" },
  { "folke/tokyonight.nvim", config = function() vim.cmd([[colorscheme tokyonight]]) end },
  
  -- GitHub Copilot
  { "github/copilot.vim",
    config = function()
      -- Enable Copilot for all filetypes
      vim.g.copilot_filetypes = {
        ["*"] = true,
      }
      -- Disable Copilot by default (toggle with :Copilot enable/disable)
      -- vim.g.copilot_enabled = true
      
      -- Copilot keybindings
      vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', { expr = true, silent = true, replace_keycodes = false })
      vim.g.copilot_no_tab_map = true
    end,
  },
  
  -- Additional useful plugins
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  { "numToStr/Comment.nvim", config = true },
  { "lewis6991/gitsigns.nvim", config = true },
  
  -- LSP setup
  { "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  { "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "pyright", "typescript-language-server", "rust_analyzer" }
      })
    end,
  },
  { "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- Configure each language server
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      
      require("lspconfig").lua_ls.setup({ capabilities = capabilities })
      require("lspconfig").pyright.setup({ capabilities = capabilities })
      require("lspconfig").tsserver_ls.setup({ capabilities = capabilities })
      require("lspconfig").rust_analyzer.setup({ capabilities = capabilities })
      
      -- LSP keybindings
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover information" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format code" })
      
      -- Completion setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
})

-- Additional key mappings
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Status line setup
vim.opt.showmode = false
vim.opt.laststatus = 3

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

