local ok, todo = pcall(require, "todo-comments")
if not ok then return end

todo.setup({
  keywords = {
    TODO = { icon = "", color = "info" },
    FIX  = { icon = "", color = "error", alt = { "FIXME", "BUG" } },
    HACK = { icon = "", color = "warning" },
    NOTE = { icon = "", color = "hint", alt = { "INFO" } },
  },
  highlight = { multiline = false },
  search = {
    command = "rg",
    args = { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column" },
  },
})

-- Keymaps aquí (no lazy por tecla)
local map = vim.keymap.set
map("n", "]t", function() todo.jump_next() end, { desc = "Siguiente TODO" })
map("n", "[t", function() todo.jump_prev() end, { desc = "Anterior TODO" })
map("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Trouble: TODOs" })
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Telescope: TODOs" })
