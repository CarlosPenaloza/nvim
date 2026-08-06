local fzf = require("fzf-lua")
local actions = require("fzf-lua.actions")

--------------------------------------------------
-- Setup
--------------------------------------------------

fzf.setup({
  winopts = {
    width = 0.85,
    height = 0.85,
    border = "rounded",

    preview = {
      layout = "flex",
      flip_columns = 120,
    },
  },

  actions = {
    files = {
      true,
      ["default"] = actions.file_edit,
      ["ctrl-s"] = actions.file_split,
      ["ctrl-v"] = actions.file_vsplit,
      ["ctrl-t"] = actions.file_tabedit,
      ["ctrl-h"] = actions.toggle_hidden,
      ["ctrl-g"] = actions.toggle_ignore,
      ["ctrl-l"] = actions.toggle_follow,
    },
  },
})

--------------------------------------------------
-- Module
--------------------------------------------------

local M = {}

--------------------------------------------------
-- Files
--------------------------------------------------

function M.files(opts)
  fzf.files(opts or {})
end

-- function M.files_all()
--   fzf.files({
--     fd_opts = table.concat({
--       "--type", "f",
--       "--hidden",
--       "--follow",
--       "--no-ignore",
--       "--no-ignore-vcs",
--     }, " "),
--   })
-- end

function M.files_from_dir(dir, opts)
  if not dir then
    return
  end

  opts = opts or {}
  opts.cwd = dir

  fzf.files(opts)
end

--------------------------------------------------
-- Grep
--------------------------------------------------

function M.live_grep(opts)
  fzf.live_grep(opts or {})
end

function M.live_grep_all()
  fzf.live_grep({
    rg_opts = table.concat({
      "--column",
      "--line-number",
      "--no-heading",
      "--color=always",
      "--smart-case",
      "--hidden",
      "--follow",
      "--no-ignore",
      "--no-ignore-vcs",
    }, " "),
  })
end

--------------------------------------------------
-- Marks
--------------------------------------------------

function M.user_marks()
  fzf.marks({
    fn_transform = function(items)
      return vim.tbl_filter(function(item)
        return item.mark:match("^[A-Za-z]$")
      end, items)
    end,
  })
end

--------------------------------------------------
-- Keymaps
--------------------------------------------------

local map = vim.keymap.set

---------------- Search ----------------

map("n", "<leader>ff", M.files, {
  desc = "Find files",
})

-- map("n", "<leader>fF", M.files_all, {
--   desc = "Find all files",
-- })

map("n", "<leader>fg", M.live_grep, {
  desc = "Live grep",
})

map("n", "<leader>fG", M.live_grep_all, {
  desc = "Live grep (all)",
})

map("n", "<leader>fb", fzf.buffers, {
  desc = "Buffers",
})

map("n", "<leader>fr", fzf.oldfiles, {
  desc = "Recent files",
})

map("n", "<leader>fh", fzf.help_tags, {
  desc = "Help tags",
})

map("n", "<leader>fk", fzf.keymaps, {
  desc = "Keymaps",
})

map("n", "<leader>fc", fzf.commands, {
  desc = "Commands",
})

map("n", "<leader>fm", M.user_marks, {
  desc = "User marks",
})

---------------- Git ----------------

map("n", "<leader>gs", fzf.git_status, {
  desc = "Git status",
})

map("n", "<leader>gc", fzf.git_commits, {
  desc = "Git commits",
})

map("n", "<leader>gb", fzf.git_branches, {
  desc = "Git branches",
})

map("n", "<leader>gf", fzf.git_files, {
  desc = "Git files",
})

map("n", "<leader>gh", fzf.git_hunks, {
  desc = "Git hunks",
})

map("n", "<leader>gB", fzf.git_bcommits, {
  desc = "Buffer commits",
})

map("n", "<leader>gS", fzf.git_stash, {
  desc = "Git stash",
})

---------------- Diagnostics ----------------

map("n", "<leader>fd", fzf.diagnostics_document, {
  desc = "Document diagnostics",
})

map("n", "<leader>fD", fzf.diagnostics_workspace, {
  desc = "Workspace diagnostics",
})

---------------- LSP ----------------

map("n", "gd", fzf.lsp_definitions, {
  desc = "Goto definition",
})

map("n", "gr", fzf.lsp_references, {
  desc = "References",
})

map("n", "gi", fzf.lsp_implementations, {
  desc = "Implementations",
})

map("n", "gt", fzf.lsp_typedefs, {
  desc = "Type definitions",
})

map("n", "<leader>fs", fzf.lsp_document_symbols, {
  desc = "Document symbols",
})

map("n", "<leader>fS", fzf.lsp_workspace_symbols, {
  desc = "Workspace symbols",
})

--------------------------------------------------
-- Return
--------------------------------------------------

return M
