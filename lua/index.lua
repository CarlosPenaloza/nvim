local function load_config(name)
  local ok, err = pcall(require, name)
  if not ok then
    vim.schedule(function()
      vim.notify(name .. ": " .. tostring(err), vim.log.levels.ERROR, { title = "Neovim config" })
    end)
  end
end

load_config("options")
load_config("config.largefile")
load_config("config.mason")
load_config("config.lsp")
load_config("config.lsp_ts")
load_config("config.cmp")
load_config("config.conform")
load_config("config.format")
load_config("config.treesitter")
load_config("config.complexity")
load_config("config.web_tests")
load_config("config.highlights")

vim.cmd.colorscheme("gruvbox")
vim.api.nvim_create_user_command("ThemeToggle", function()
  local c = vim.g.colors_name
  if c == "gruvbox" then
    vim.cmd.colorscheme("catppuccin")
  else
    vim.cmd.colorscheme("gruvbox")
  end
end, {})

-- ===== Cargar configs de plugins cuando lazy esté listo =====
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- UI / Utilidades
    load_config("config.devicons")
    load_config("config.bufferline")
    load_config("config.mini")
    load_config("config.lualine")
    load_config("config.gitsigns")
    load_config("config.other-pluggins-config")
    load_config("config.diagnostics")
    load_config("config.which-key")
    load_config("config.ufo")
    load_config("config.fzf")
  end,
})

-- ===== Mapeos globales (no dependen de plugins) =====
load_config("mapped")
