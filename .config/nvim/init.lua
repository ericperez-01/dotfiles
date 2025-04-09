vim.opt.number = true
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

if vim.g.neovide then
  vim.cmd "cd $HOME"
  vim.g.neovide_cursor_animation_length = 0.05
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_refresh_rate = 60
  vim.opt.guifont = "FiraCode Nerd Font:h13"
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

-- Set up rustaceanvim configuration before loading plugins
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
    -- Automatically set inlay hints
    inlay_hints = {
      auto = true,
    },
    -- Configure test executor
    test_executor = 'background', -- Can also be set to 'neotest'
  },
  -- DAP configuration
  dap = {
    adapter = {
      type = "executable",
      command = "codelldb",
      name = "rt_lldb",
    },
  },
  -- Server configuration
  server = {
    on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      
      -- Buffer local mappings
      local opts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    end,
    settings = {
      -- rust-analyzer settings
      ["rust-analyzer"] = {
        -- Enable experimental features
        checkOnSave = {
          command = "clippy",
        },
        inlayHints = {
          lifetimeElisionHints = {
            enable = "always",
          },
        },
      },
    },
  },
}

require("lazy").setup({
  {"nvim-neo-tree/neo-tree.nvim", dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim"},
    config = function() require("neo-tree").setup({filesystem = {commands = {avante_add_files = function(state)
      local node, path = state.tree:get_node(), state.tree:get_node():get_id()
      local sidebar, open = require('avante').get(), require('avante').get():is_open()
      if not open then require('avante.api').ask() sidebar = require('avante').get() end
      sidebar.file_selector:add_selected_file(require('avante.utils').relative_path(path))
      if not open then sidebar.file_selector:remove_selected_file('neo-tree filesystem [1]') end
    end}, window = {mappings = {["oa"] = "avante_add_files"}}}})
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", {silent = true}) end},
  {"nvim-telescope/telescope.nvim", dependencies = {"nvim-lua/plenary.nvim"},
    config = function() require("telescope").setup()
      vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
      vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep) end},
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function() require("nvim-treesitter.configs").setup {
      ensure_installed = {"lua", "javascript", "python", "html", "css", "rust"},
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
  {"williamboman/mason.nvim", 
    config = function() 
      require("mason").setup() 
    end
  },
  {"williamboman/mason-lspconfig.nvim",
    config = function() 
      require("mason-lspconfig").setup {
        -- Remove rust_analyzer as it will be handled by rustaceanvim
        ensure_installed = {"lua_ls", "pyright", "ts_ls"}
      } 
    end
  },
  {"jay-babu/mason-nvim-dap.nvim",
    dependencies = {"williamboman/mason.nvim"},
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {"codelldb"},
        automatic_installation = true,
        handlers = {},
      })
    end
  },
  {"neovim/nvim-lspconfig",
    dependencies = {"hrsh7th/nvim-cmp", "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip"},
    config = function()
      local caps = require("cmp_nvim_lsp").default_capabilities()
      for _, lsp in ipairs({"lua_ls", "pyright", "ts_ls"}) do
        require("lspconfig")[lsp].setup {capabilities = caps} end
      
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
  {"folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  -- Add rustaceanvim for Rust development and test debugging
  {"mrcjkb/rustaceanvim",
    version = "^5", -- Use version 5 or higher
    ft = "rust", -- Only load when editing Rust files
    dependencies = {"mfussenegger/nvim-dap"},
    config = function()
      -- Key mappings for Rust debugging and testing
      vim.keymap.set("n", "<leader>rt", function() vim.cmd.RustLsp("testables") end, {desc = "Rust Testables", silent = true})
      vim.keymap.set("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, {desc = "Rust Runnables", silent = true})
      vim.keymap.set("n", "<leader>rd", function() vim.cmd.RustLsp("debuggables") end, {desc = "Rust Debuggables", silent = true})
      vim.keymap.set("n", "<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, {desc = "Expand Rust Macro", silent = true})
      vim.keymap.set("n", "<leader>rc", function() vim.cmd.RustLsp("openCargo") end, {desc = "Open Cargo.toml", silent = true})
      vim.keymap.set("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, {desc = "Go to Parent Module", silent = true})
    end
  },
  {"rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
      local dapui = require("dapui")
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 0.25,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          element = "repl",
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
      })

      -- Automatically open and close dapui when debugging starts/ends
      local dap = require("dap")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymappings for dapui
      vim.keymap.set('n', '<leader>du', function() dapui.toggle() end)
      vim.keymap.set('n', '<leader>de', function() dapui.eval() end)
      vim.keymap.set('v', '<leader>de', function() dapui.eval() end)
    end
  },
  -- Standard DAP keybindings
  {"mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- Keymappings for debugging
      vim.keymap.set('n', '<F5>', function() dap.continue() end)
      vim.keymap.set('n', '<F10>', function() dap.step_over() end)
      vim.keymap.set('n', '<F11>', function() dap.step_into() end)
      vim.keymap.set('n', '<F12>', function() dap.step_out() end)
      vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)
      vim.keymap.set('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)
      vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
      vim.keymap.set('n', '<leader>dl', function() dap.run_last() end)
    end
  },
})

vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
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
vim.keymap.set("n", "<leader>|", ":vsplit<CR>", {silent = true})
vim.keymap.set("n", "<leader>-", ":split<CR>", {silent = true})
vim.keymap.set("n", "<leader>t", ":tabnew<CR>", {silent = true})
vim.keymap.set("n", "<leader>c", ":close<CR>", {silent = true})
vim.keymap.set("n", "<leader>=", "5<C-w>+", {silent = true})
vim.keymap.set("n", "<leader>_", "5<C-w>-", {silent = true})
vim.keymap.set("n", "<leader>>", "5<C-w>>", {silent = true})
vim.keymap.set("n", "<leader><", "5<C-w><", {silent = true})
vim.keymap.set("n", "<leader>n", ":tabnext<CR>", {silent = true})
vim.keymap.set("n", "<leader>p", ":tabprevious<CR>", {silent = true})

-- Buffer navigation with Ctrl
vim.keymap.set("n", "<C-h>", ":bprevious<CR>", { silent = true })
vim.keymap.set("n", "<C-l>", ":bnext<CR>", { silent = true })

-- Focus on Neotree
vim.keymap.set("n", "<leader>E", ":Neotree reveal<CR>", {silent = true})
