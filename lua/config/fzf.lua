local fzf = require("fzf-lua")

-- función responsiva
local function smart_opts()
  local cols = vim.o.columns

  if cols > 120 then
    return {
      winopts = {
        preview = {
          layout = "horizontal",
          horizontal = "right:50%",
        },
      },
    }
  else
    return {
      winopts = {
        preview = {
          layout = "vertical",
          vertical = "down:60%",
        },
      },
    }
  end
end

-- setup base
fzf.setup({
  winopts = {
    height = 0.85,
    width = 0.80,
    border = "rounded",
  },
  actions = {
    files = {
      ["default"] = require("fzf-lua.actions").file_edit,
      ["ctrl-s"] = require("fzf-lua.actions").file_split,
      ["ctrl-v"] = require("fzf-lua.actions").file_vsplit,
      ["ctrl-t"] = require("fzf-lua.actions").file_tabedit,
    },
  },
})

-- 🔍 Búsqueda
vim.keymap.set("n", "<leader>ff", function()
  fzf.files(smart_opts())
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  fzf.live_grep(smart_opts())
end, { desc = "Live grep" })

vim.keymap.set("n", "<leader>fb", function()
  fzf.buffers(smart_opts())
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>fh", function()
  fzf.help_tags(smart_opts())
end, { desc = "Help tags" })

vim.keymap.set("n", "<leader>fm", function()
  fzf.marks(vim.tbl_deep_extend("force",
    smart_opts(),
    {
      fn_transform = function(items)
        return vim.tbl_filter(function(item)
          return item.mark:match("^[a-zA-Z]$")
        end, items)
      end,
    }
  ))
end, { desc = "Find user marks only" })

-- 🌿 Git
vim.keymap.set("n", "<leader>gs", function()
  fzf.git_status(smart_opts())
end, { desc = "Git status" })

vim.keymap.set("n", "<leader>gc", function()
  fzf.git_commits(smart_opts())
end, { desc = "Git commits" })

vim.keymap.set("n", "<leader>gb", function()
  fzf.git_branches(smart_opts())
end, { desc = "Git branches" })
