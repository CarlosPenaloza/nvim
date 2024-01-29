local filter = {
  '^vbank/'
}
require('telescope').setup {
  defaults = {
    layout_config = {
      bottom_pane = {
        height = 25,
        preview_cutoff = 120,
        prompt_position = "top"
      },
      center = {
        height = 0.4,
        preview_cutoff = 40,
        prompt_position = "top",
        width = 0.5
      },
      cursor = {
        height = 0.9,
        preview_cutoff = 40,
        width = 0.8
      },
      horizontal = {
        height = 0.9,
        preview_cutoff = 120,
        prompt_position = "top",
        width = 0.9
      },
      vertical = {
        height = 0.8,
        preview_cutoff = 40,
        prompt_position = "bottom",
        width = 0.9
      }
    },
    initial_mode = 'normal',
    preview = {
      treesitter = true
    },
    file_ignore_patterns = filter,
    dynamic_preview_title = true,
  },
  pickers = {
  },
  extensions = {
  }
}

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>fr', ':Telescope git_status<CR>')
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<leader>ft', ':Telescope treesitter<CR>')
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>')
vim.keymap.set('n', '<leader>fk', ':Telescope keymaps<CR>')
