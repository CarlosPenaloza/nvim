local mocha = require("catppuccin.palettes").get_palette "mocha"
require("bufferline").setup{
  highlights = require("catppuccin.groups.integrations.bufferline").get {
      styles = { "italic", "bold" },
      custom = {
          all = {
              fill = { bg = "#000000" },
          },
          mocha = {
              background = { fg = mocha.text },
          },
          latte = {
              background = { fg = "#000000" },
          },
      },
  },
  options = {
    max_name_length = 50,
    tab_size = 11,
    diagnostics = 'nvim_lsp',
    themable = true, -- allows highlight groups to be overriden i.e. sets highlights as default
    indicator = {
      icon = '▎', -- this should be omitted if indicator style is not 'icon'
      style = 'icon',
    },
    truncate_names = true, -- whether or not tab names should be truncated
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,
    color_icons = true, -- whether or not to add the filetype icon highlights
    always_show_bufferline = false,
    hover = {
      enabled = true,
      delay = 200,
      reveal = {'close'}
    },
 },
}
