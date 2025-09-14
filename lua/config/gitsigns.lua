-- lua/config/gitsigns.lua
local ok_gs, gitsigns = pcall(require, "gitsigns")
if not ok_gs then return end

gitsigns.setup({
  -- Signos minimalistas
  signs                        = {
    add          = { text = '│' },
    change       = { text = '│' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },

  -- UI
  signcolumn                   = true,
  numhl                        = false,
  linehl                       = false,
  word_diff                    = false,
  sign_priority                = 6,

  -- Watcher de .git
  watch_gitdir                 = {
    interval = 1500,
    follow_files = true,
  },

  -- Rendimiento
  update_debounce              = 200,
  attach_to_untracked          = false,
  max_file_length              = 30000,

  -- Blame de línea
  current_line_blame           = false,
  current_line_blame_opts      = {
    virt_text = true,
    virt_text_pos = 'eol',
    delay = 700,
    ignore_whitespace = true,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',

  -- Preview ventana
  preview_config               = {
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },

  -- Mapeos buffer-local y toggles útiles
  on_attach                    = function(bufnr)
    -- 🚨 Clave: NO adjuntar en buffers Oil
    local ft = vim.bo[bufnr].filetype
    local name = vim.api.nvim_buf_get_name(bufnr) or ""
    if ft == "oil" or name:match("^oil://") then
      return false
    end

    local gs = package.loaded.gitsigns
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    -- Navegación de hunks
    map('n', '<leader>hn', gs.next_hunk, 'Siguiente hunk')
    map('n', '<leader>hm', gs.prev_hunk, 'Anterior hunk')

    -- Acciones
    map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
    map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
    map('n', '<leader>hu', gs.undo_stage_hunk, 'Undo stage hunk')
    map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')

    -- Toggles
    map('n', '<leader>hd', gs.toggle_deleted, 'Mostrar eliminados')
    map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle line blame')
    map('n', '<leader>tn', gs.toggle_numhl, 'Toggle numhl')
    map('n', '<leader>tl', gs.toggle_linehl, 'Toggle linehl')
    map('n', '<leader>tw', gs.toggle_word_diff, 'Toggle word diff')
  end,
})
