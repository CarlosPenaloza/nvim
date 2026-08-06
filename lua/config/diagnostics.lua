vim.diagnostic.config({
  underline = true,
  severity_sort = true,
  update_in_insert = false,
  virtual_text = false,

  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },

  float = {
    border = "rounded",
    source = "if_many",
    focusable = false,
  },
})

vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      focus = false,
    })
  end,
})

vim.keymap.set("n", "<leader>d", function()
  require("fzf-lua").diagnostics_document()
end, { desc = "Document Diagnostics" })

vim.keymap.set("n", "<leader>D", function()
  require("fzf-lua").diagnostics_workspace()
end, { desc = "Workspace Diagnostics" })

vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
