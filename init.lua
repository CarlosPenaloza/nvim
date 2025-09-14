-- init.lua

-- ===== Leader keys (debe ir ANTES de cargar plugins) =====
require('leader')

vim.g.python3_host_prog = "/usr/bin/python3"

-- ===== Bootstrap lazy.nvim =====
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===== Cargar specs de plugins =====
require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

-- ===== Tu config modular =====
require("index")
