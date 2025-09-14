-- Config de tmux-navigator
vim.g.tmux_navigator_no_mappings = 1

-- Atajos manuales para moverte entre panes de tmux
vim.keymap.set("n", "<Leader>H", ":TmuxNavigateLeft<CR>", { silent = true })
vim.keymap.set("n", "<Leader>J", ":TmuxNavigateDown<CR>", { silent = true })
vim.keymap.set("n", "<Leader>K", ":TmuxNavigateUp<CR>", { silent = true })
vim.keymap.set("n", "<Leader>L", ":TmuxNavigateRight<CR>", { silent = true })
