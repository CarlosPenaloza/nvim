local pantran = require("pantran")
local actions = require("pantran.ui.actions")
local engines = require("pantran.engines")
local async = require("pantran.async")
local opts = {noremap = true, silent = true, expr = true}
vim.keymap.set("n", "<leader>tr", pantran.motion_translate, opts)
vim.keymap.set("n", "<leader>trr", function() return pantran.motion_translate() .. "_" end, opts)
vim.keymap.set("x", "<leader>tr", pantran.motion_translate, opts)

