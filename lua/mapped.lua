-- === Generales ===
vim.keymap.set("n", "<Leader>w", ":w<CR>", { silent = true, desc = "Guardar" })
vim.keymap.set("n", "<Leader>Q", ":q<CR>", { silent = true, desc = "Salir" })
vim.keymap.set("n", "<C-Q>", ":q!<CR>", { silent = true, desc = "Forzar salir" })
vim.keymap.set("n", "<Leader>W", ":wq<CR>", { silent = true, desc = "Guardar y salir" })

-- === Tamaño de splits ===
vim.keymap.set("n", "<Right>", ":vertical resize +5<CR>", { silent = true, desc = "Aumentar ancho" })
vim.keymap.set("n", "<Left>", ":vertical resize -5<CR>", { silent = true, desc = "Reducir ancho" })
vim.keymap.set("n", "<Up>", ":resize +5<CR>", { silent = true, desc = "Aumentar alto" })
vim.keymap.set("n", "<Down>", ":resize -5<CR>", { silent = true, desc = "Reducir alto" })

-- === Buffers ===
vim.keymap.set("n", "<Leader>k", ":bnext<CR>", { silent = true, desc = "Buffer siguiente" })
vim.keymap.set("n", "<Leader>j", ":bprevious<CR>", { silent = true, desc = "Buffer anterior" })
vim.keymap.set("n", "<Leader>q", ":bdelete<CR>", { silent = true, desc = "Cerrar buffer" })

-- === Splits ===
vim.keymap.set("n", "<Leader>vs", ":vsp<CR>", { silent = true, desc = "Vertical split" })
vim.keymap.set("n", "<Leader>sp", ":sp<CR>", { silent = true, desc = "Horizontal split" })

-- === Limpiar resaltados ===
vim.keymap.set("n", "<Esc>", ":noh<CR>", { silent = true, desc = "Quitar búsqueda resaltada" })

-- local function map(lhs, rhs, desc)
--   vim.keymap.set('n', lhs, rhs, { silent = true, noremap = true, desc = desc })
-- end
--
-- -- Telescope: llamados directos
-- map('<leader>tf', '<cmd>Telescope find_files<CR>',  'Telescope files')
-- map('<leader>tr', '<cmd>Telescope git_status<CR>',  'Telescope git status')
-- map('<leader>tg', '<cmd>Telescope live_grep<CR>',   'Telescope live grep')
-- map('<leader>tb', '<cmd>Telescope buffers<CR>',     'Telescope buffers')
-- map('<leader>th', '<cmd>Telescope help_tags<CR>',   'Telescope help')
-- map('<leader>tk', '<cmd>Telescope keymaps<CR>',     'Telescope keymaps')
-- map('<leader>tt', '<cmd>Telescope treesitter<CR>',  'Telescope treesitter')
-- map('<leader>ts', '<cmd>Telescope grep_string<CR>', 'Telescope grep string')
