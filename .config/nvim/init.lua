vim.opt.number = true vim.opt.relativenumber = true vim.opt.expandtab = true vim.opt.termguicolors = true
vim.opt.mouse = "a" vim.opt.clipboard = "unnamedplus" vim.opt.tabstop = 2 vim.opt.shiftwidth = 2
if vim.g.neovide then
  vim.cmd "cd $HOME"
  vim.g.neovide_cursor_animation_length = 0.05 vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_refresh_rate = 60 vim.opt.guifont = "FiraCode Nerd Font:h13"
  vim.g.neovide_transparency = 0.95
  vim.keymap.set("t", "<D-v>", [[<C-\><C-n>"+pi]], { noremap = true })
  vim.g.neovide_input_macos_option_key_is_meta = 'only_left'
end
vim.g.mapleader = " "
local lp = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lp) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lp})
end
vim.opt.rtp:prepend(lp)
require("lazy").setup({
  {"nvim-neo-tree/neo-tree.nvim", dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    config = function() require("neo-tree").setup() vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", {silent = true}) end},
  {"nvim-telescope/telescope.nvim", dependencies = {"nvim-lua/plenary.nvim"},
    config = function() require("telescope").setup()
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep) end},
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function() require("nvim-treesitter.configs").setup {
      ensure_installed = {"lua", "javascript", "python", "html", "css"},
      highlight = {enable = true}, indent = {enable = true}} end},
  {"yetone/avante.nvim", event = "VeryLazy", build = "make",
    dependencies = {"nvim-treesitter/nvim-treesitter", "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim"},
    config = function() require("avante").setup {provider = "claude",
      model = "claude-3-7-sonnet-20240229", api_key_name = "ANTHROPIC_API_KEY"}
      vim.keymap.set("n", "<leader>a", ":AvanteAsk<CR>") end},
  {"mg979/vim-visual-multi", branch = "master"},
  {"folke/tokyonight.nvim", config = function() vim.cmd "colorscheme tokyonight" end},
  {"github/copilot.vim",
    config = function() vim.g.copilot_filetypes = {["*"] = true} vim.g.copilot_enabled = true
      vim.keymap.set("i", "<C-j>", 'copilot#Accept("<CR>")', {expr = true, silent = true,
        replace_keycodes = false}) vim.g.copilot_no_tab_map = true end},
  {"windwp/nvim-autopairs", event = "InsertEnter", config = true},
  {"numToStr/Comment.nvim", config = true},
  {"lewis6991/gitsigns.nvim", config = true},
  {"williamboman/mason.nvim", config = function() require("mason").setup() end},
  {"williamboman/mason-lspconfig.nvim",
    config = function() require("mason-lspconfig").setup {
      ensure_installed = {"lua_ls", "pyright", "ts_ls", "rust_analyzer"}} end},
  {"neovim/nvim-lspconfig",
    dependencies = {"hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"},
    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      for _, lsp in ipairs({"lua_ls", "pyright", "ts_ls", "rust_analyzer"}) do
        require("lspconfig")[lsp].setup {capabilities = caps} end
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format {async = true} end)
      local cmp = require("cmp") local ls = require("luasnip")
      cmp.setup {snippet = {expand = function(args) ls.lsp_expand(args.body) end},
        mapping = cmp.mapping.preset.insert {
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm {select = true},
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif ls.expand_or_jumpable() then ls.expand_or_jump()
            else fallback() end end, {"i", "s"}),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif ls.jumpable(-1) then ls.jump(-1)
            else fallback() end end, {"i", "s"})},
        sources = cmp.config.sources({{name = "nvim_lsp"}, {name = "luasnip"},
          {name = "buffer"}, {name = "path"}})}
    end},
})
vim.keymap.set("n", "<leader>w", ":w<CR>") vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.opt.showmode = false vim.opt.laststatus = 3
vim.opt.ignorecase = true vim.opt.smartcase = true vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>", {silent = true})

-- Smart window navigation with Alt/Option keys (like tmux)
vim.keymap.set("n", "<M-h>", function()
  if vim.fn.winnr() == vim.fn.winnr('h') then vim.cmd('tabprevious') else vim.cmd('wincmd h') end
end, {silent = true})
vim.keymap.set("n", "<M-l>", function()
  if vim.fn.winnr() == vim.fn.winnr('l') then vim.cmd('tabnext') else vim.cmd('wincmd l') end
end, {silent = true})
vim.keymap.set("n", "<M-j>", "<C-w>j", {silent = true})
vim.keymap.set("n", "<M-k>", "<C-w>k", {silent = true})

-- Window management keybindings
vim.keymap.set("n", "<leader>|", ":vsplit<CR>", {silent = true})                          -- Vertical split (like tmux)
vim.keymap.set("n", "<leader>-", ":split<CR>", {silent = true})                           -- Horizontal split (like tmux)
vim.keymap.set("n", "<leader>t", ":tabnew<CR>", {silent = true})                          -- New tab
vim.keymap.set("n", "<leader>c", ":close<CR>", {silent = true})                           -- Close current split/tab
vim.keymap.set("n", "<leader>=", "5<C-w>+", {silent = true})                              -- Increase split height
vim.keymap.set("n", "<leader>_", "5<C-w>-", {silent = true})                              -- Decrease split height
vim.keymap.set("n", "<leader>>", "5<C-w>>", {silent = true})                              -- Increase split width
vim.keymap.set("n", "<leader><", "5<C-w><", {silent = true})                              -- Decrease split width
vim.keymap.set("n", "<leader>n", ":tabnext<CR>", {silent = true})                         -- Next tab
vim.keymap.set("n", "<leader>p", ":tabprevious<CR>", {silent = true})                     -- Previous tab

-- Buffer navigation with Ctrl
vim.keymap.set("n", "<C-h>", ":bprevious<CR>", { silent = true })  -- Previous buffer
vim.keymap.set("n", "<C-l>", ":bnext<CR>", { silent = true })      -- Next buffer
