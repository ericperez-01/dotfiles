-- Basic settings that apply everywhere
vim.opt.clipboard = "unnamedplus"
vim.g.mapleader = " "

-- Set up lazy.nvim
local lp = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lp) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lp})
end
vim.opt.rtp:prepend(lp)

require('regular')
