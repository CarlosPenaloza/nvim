-- lua/config/mini.lua

-- 1) Comentarios → `gcc` (línea) y `gc` (bloque)
require('mini.comment').setup({
  mappings = {
    comment = 'gc',
    comment_line = 'gcc',
    textobject = 'gc',
  },
})

-- 2) Surround estándar con prefijo `gs`
require('mini.surround').setup({
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    replace = 'gsc',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    update_n_lines = 'gsn',
  },
})
vim.keymap.set('x', 'gS', function() require('mini.surround').add('visual') end,
  { desc = 'Add surround (visual)' })
vim.keymap.set('n', 'gss', function() require('mini.surround').add('line') end,
  { desc = 'Add surround to line' })

-- 3) Autopairs
require('mini.pairs').setup()

-- 4) Mover texto
require('mini.move').setup({
  mappings = {
    left = '<M-h>',
    right = '<M-l>',
    down = '<M-j>',
    up = '<M-k>',
    line_left = '<M-h>',
    line_right = '<M-l>',
    line_down = '<M-j>',
    line_up = '<M-k>',
  },
})

-- 5) Alinear texto
require('mini.align').setup()
vim.keymap.set('x', 'ga', function() require('mini.align').align() end, { desc = 'MiniAlign (visual)' })
vim.keymap.set('n', 'gA', function() require('mini.align').align_to_char({}) end, { desc = 'MiniAlign (normal)' })

-- 6) Split/Join
require('mini.splitjoin').setup({ mappings = { toggle = 'gS' } })

-- 7) Quitar espacios al final
require('config.miniConfig.trailspace')

-- 8) Indentscope (reemplaza indent-blankline)
require('mini.indentscope').setup({
  draw = { animation = require('mini.indentscope').gen_animation.none() },
  symbol = '│',
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'alpha', 'dashboard', 'neo-tree', 'NvimTree', 'Trouble', 'lazy' },
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- 9) Hipatterns (reemplaza nvim-highlight-colors)
require('config.miniConfig.hipatterns')

-- 10) mini.ai — Textobjects inteligentes
-- do
--   local ai = require('mini.ai')
--   ai.setup({
--     n_lines = 500,
--     custom_textobjects = {
--       f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
--       c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
--       o = ai.gen_spec.treesitter({ a = '@loop.outer', i = '@loop.inner' }),
--       p = ai.gen_spec.treesitter({ a = '@parameter.outer', i = '@parameter.inner' }),
--     },
--   })
-- end

-- 11) Transformaciones de mayúsculas/minúsculas
-- Normal mode: palabra actual
vim.keymap.set('n', '<M-u>', 'gUiw', { remap = true, desc = 'Uppercase word' })
vim.keymap.set('n', '<M-l>', 'guiw', { remap = true, desc = 'Lowercase word' })
vim.keymap.set('n', '<M-t>', 'g~iw', { remap = true, desc = 'Toggle case word' })

-- Visual mode: selección
vim.keymap.set('x', '<M-u>', 'gU', { remap = true, desc = 'Uppercase selection' })
vim.keymap.set('x', '<M-l>', 'gu', { remap = true, desc = 'Lowercase selection' })
vim.keymap.set('x', '<M-t>', 'g~', { remap = true, desc = 'Toggle case selection' })
