vim.keymap.set("n", "<leader><Tab>", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- lua/config/oil.lua
vim.keymap.set("n", "<leader><Tab>", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local ok_oil, oil = pcall(require, "oil")
if not ok_oil then return end

oil.setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  columns = { "icon" },
  view_options = {
    show_hidden = false,
  },
  win_options = {
    signcolumn = "yes:2", -- necesario para git status
    cursorline = true,
  },
  keymaps = {
    ["q"]     = "actions.close",
    ["<Esc>"] = "actions.close",
    ["<CR>"]  = "actions.select",
    ["-"]     = "actions.parent",
    ["_"]     = "actions.open_cwd",
    ["g."]    = "actions.toggle_hidden",
  },
})

-- Oil Git Status
local ok_oilgit, oil_git = pcall(require, "oil-git-status")
if ok_oilgit then
  oil_git.setup({
    -- Puedes personalizar símbolos o ignorados aquí
    -- symbols = { staged = "S", unstaged = "M", untracked = "?" },
  })
end

-- Asegura signcolumn correcto en buffers Oil
vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.wo.signcolumn = "yes:2"
  end,
})
