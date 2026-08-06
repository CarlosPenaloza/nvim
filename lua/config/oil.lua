-- lua/config/oil.lua
vim.keymap.set("n", "<leader><Tab>", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local ok_oil, oil = pcall(require, "oil")
if not ok_oil then return end

oil.setup({
  default_file_explorer = true,
  skip_confirm_for_simple_edits = true,
  columns = {
    "icon",
    "permissions",
    "size",
    -- "mtime",
  },
  view_options = {
    show_hidden = true,
  },
  win_options = {
    signcolumn = "yes:2", -- necesario para git status
    cursorline = true,
  },
  use_default_keymaps = false,
  keymaps = {
    ["q"]     = "actions.close",
    ["<Esc>"] = "actions.close",
    ["<CR>"]  = "actions.select",
    ["-"]     = "actions.parent",
    ["_"]     = "actions.open_cwd",
    ["g."]    = "actions.toggle_hidden",
    ["P"]     = "actions.preview"
  },
  preview = {
    max_width = 0.5, -- 50% de la pantalla
    min_width = 40,
    max_height = 0.5,
    border = "rounded",
  }
})

-- Oil Git Status
local ok_oilgit, oil_git = pcall(require, "oil-git-status")
if ok_oilgit then
  oil_git.setup({
    symbols = {
      index = "", -- staged
      working_tree = "", -- modified
      untracked = "",
      ignored = "",
      deleted = "",
      renamed = "",
      conflict = "",
    },
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.keymap.set("n", "<leader>ff", function()
      local dir = require("oil").get_current_dir()
      require("config.fzf").files_from_dir(dir)
    end, {
      buffer = true,
      desc = "Find files in current directory",
    })
  end,
})
