
-- vscode.lua - Configuration for VSCode Neovim integration

-- Basic settings useful in VSCode
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- VSCode-specific keymappings
local function vscode_notify(command, args)
  return function() vim.fn.VSCodeNotify(command, args) end
end

-- Navigation keymaps
vim.keymap.set('n', 'gd', vscode_notify('editor.action.revealDefinition'))
vim.keymap.set('n', 'gr', vscode_notify('editor.action.goToReferences'))
vim.keymap.set('n', 'K', vscode_notify('editor.action.showHover'))
vim.keymap.set('n', '<leader>ca', vscode_notify('editor.action.quickFix'))
vim.keymap.set('n', '<leader>rn', vscode_notify('editor.action.rename'))

-- Search and navigation
vim.keymap.set('n', '<leader>ff', vscode_notify('workbench.action.quickOpen'))
vim.keymap.set('n', '<leader>fg', vscode_notify('workbench.action.findInFiles'))

-- Clear search highlighting
vim.keymap.set("n", "<Esc>", vscode_notify('editor.action.clearFind'), {silent = true})

-- Window navigation (using VSCode's split commands)
vim.keymap.set("n", "<M-h>", vscode_notify('workbench.action.navigateLeft'), {silent = true})
vim.keymap.set("n", "<M-l>", vscode_notify('workbench.action.navigateRight'), {silent = true})
vim.keymap.set("n", "<M-j>", vscode_notify('workbench.action.navigateDown'), {silent = true})
vim.keymap.set("n", "<M-k>", vscode_notify('workbench.action.navigateUp'), {silent = true})

-- Window management
vim.keymap.set("n", "<leader>|", vscode_notify('workbench.action.splitEditorRight'), {silent = true})
vim.keymap.set("n", "<leader>-", vscode_notify('workbench.action.splitEditorDown'), {silent = true})
vim.keymap.set("n", "<leader>c", vscode_notify('workbench.action.closeActiveEditor'), {silent = true})

-- Load VSCode-compatible plugins
require("lazy").setup({
  -- Text manipulation plugins that work well with VSCode
  {"mg979/vim-visual-multi", branch = "master"},
  {"windwp/nvim-autopairs", event = "InsertEnter", config = true},
  {"numToStr/Comment.nvim", config = true},
  
  -- Flash for navigation
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
})

-- Ensure we don't have conflicting keybindings with VSCode
vim.keymap.set("n", "<leader>w", vscode_notify('workbench.action.files.save'), {silent = true})
vim.keymap.set("n", "<leader>q", vscode_notify('workbench.action.closeActiveEditor'), {silent = true})

-- Disable some Neovim UI elements that are redundant in VSCode
vim.opt.showmode = false
