-- init.lua

-- ===== Leader keys (debe ir ANTES de cargar plugins) =====
require("leader")

-- (Opcional) Host de Python para plugins que lo requieran
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

-- ===== Cargar specs de plugins (dos “imports”: generales y LSP) =====
require("lazy").setup({
  { import = "plugins" },     -- tus temas, oil, treesitter, telescope, etc.
  { import = "plugins.lsp" }, -- SOLO plugins de LSP/cmp/format (nuevo archivo)
}, {
  ui = { border = "rounded" },
  change_detection = { notify = false },
})

-- ===== Tu config modular =====
-- Aquí cargas tus configs (opciones, keymaps, LSP, cmp, format, etc.)
require("index")
