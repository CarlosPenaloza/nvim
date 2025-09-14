-- Settings
require('leader')
pcall(require, 'plugins')
pcall(require, 'options')

-- Pluggins
pcall(require, 'config.telescope')
pcall(require, 'config.catppuccin')
pcall(require, 'config.devicons')
pcall(require, 'config.bufferline')
pcall(require, 'config.coc')
-- pcall(require, 'config.gitsigns')
pcall(require, 'config.mini')
pcall(require, 'config.oil-git-status')
pcall(require, 'config.oil-git')
pcall(require, 'config.oil')
pcall(require, 'config.lualine')
pcall(require, 'config.bufferline')
require('config.gitsigns')
pcall(require, 'config.treesitter')
pcall(require, 'config.other-pluggins-config')
pcall(require, 'config.largefile')

-- Mapeo de teclas
pcall(require, 'mapped')
