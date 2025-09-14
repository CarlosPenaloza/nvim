-- lua/index.lua

-- ===== Settings base =====
pcall(require, 'options')

-- ===== Tema por defecto (opcional) =====
vim.cmd.colorscheme('gruvbox')
vim.api.nvim_create_user_command("ThemeToggle", function()
  local c = vim.g.colors_name
  if c == "gruvbox" then vim.cmd.colorscheme("catppuccin") else vim.cmd.colorscheme("gruvbox") end
end, {})

-- ===== Cargar configs de plugins cuando lazy esté listo =====
vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    -- Plugins (tus módulos de configuración)
    pcall(require, 'config.telescope')
    pcall(require, 'config.catppuccin')
    pcall(require, 'config.devicons')          -- si lo usas
    pcall(require, 'config.bufferline')
    pcall(require, 'config.coc')
    pcall(require, 'config.mini')
    pcall(require, 'config.lualine')
    pcall(require, 'config.gitsigns')          -- ya sin duplicado
    pcall(require, 'config.treesitter')
    pcall(require, 'config.other-pluggins-config')
    pcall(require, 'config.largefile')
  end,
})

-- ===== Mapeos globales (no dependen de plugins) =====
pcall(require, 'mapped')

