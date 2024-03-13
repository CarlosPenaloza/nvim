require('lualine').setup {
  options = {
    theme = 'auto',
    component_separators = '|',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      { 'mode', separator = { left = '' }, right_padding = 2},
    },
    lualine_b = {
      { 'branch' },
      { 'filename', file_status = true, shorting_target = 40, newfile_status = true, path = 1 }
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      'encoding',
      { 'filetype', icon_only = true},
      'diff',
      'diagnostics',
      'progress'
    },
    lualine_z = {
      { 'location', separator = { right = '' }, left_padding = 2 },
    },
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {},
  extensions = {
    'nerdtree'
  },
}
