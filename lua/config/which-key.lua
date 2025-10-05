local ok, wk = pcall(require, "which-key")
if not ok then
  return
end

wk.setup({
  plugins = { spelling = { enabled = false } },
  win = { border = "rounded" },
  show_help = true,
  show_keys = true,
})

wk.add({
  { "<leader>x", group = "Trouble / Diagnósticos" },
  { "<leader>t", group = "TODOs" },
})
