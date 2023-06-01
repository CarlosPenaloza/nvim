require('pretty-fold').setup {
  keep_indentation = true,
  fill_char = '━', --lo que servira como relleno
  sections = {
    left = {
      '━ ', function() return string.rep('*', vim.v.foldlevel) end, ' ━┫', 'content',
      '┣'                                                                                  --seleccionamos lo que estara en el lado derecho
    },
    right = {
      '┫ ', 'number_of_folded_lines', ': ', 'percentage', ' ┣━━', --seleccionamos lo que estara en el lado izquierdo
    }
  }
}
local keymap = vim.keymap
keymap.amend = require('keymap-amend')
local map = require('fold-preview').mapping
keymap.amend('n', 'h',  map.show_close_preview_open_fold)
keymap.amend('n', 'l',  map.close_preview_open_fold)
