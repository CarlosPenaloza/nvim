-- lua/config/ufo.lua

local ok, ufo = pcall(require, "ufo")
if not ok then return end

require("ufo").setup({
  open_fold_hl_timeout = 150,

  provider_selector = function(_, _, _)
    local size = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))

    if size > 200 * 1024 then
      return { "indent" }
    end

    return { "treesitter", "indent" }
  end,
})

-- keymaps
vim.keymap.set("n", "zR", ufo.openAllFolds)
vim.keymap.set("n", "zM", ufo.closeAllFolds)
vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds)
vim.keymap.set("n", "zm", ufo.closeFoldsWith)

vim.keymap.set("n", "zp", function()
  local winid = require("ufo").peekFoldedLinesUnderCursor()

  if not winid then
    vim.lsp.buf.hover()
  end
end)
