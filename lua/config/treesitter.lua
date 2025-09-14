-- lua/config/treesitter.lua
local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
if not ok then return end

local uv = vim.uv or vim.loop

-- ----- Guardas de rendimiento -----
local BIG_FILE_SIZE = 500 * 1024 -- 500 KB
local BIG_FILE_LINES = 10000

-- cache de buffers ya notificados
local notified = {}

-- tabla global para checar estado en lualine
_G.BigFile = _G.BigFile or {}
BigFile.state = {}

local function is_large(buf)
  local ok_stat, st = pcall(uv.fs_stat, vim.api.nvim_buf_get_name(buf))
  local big_file = ok_stat and st and st.size and st.size > BIG_FILE_SIZE
  local big_lines = (vim.api.nvim_buf_line_count(buf) or 0) > BIG_FILE_LINES
  return big_file or big_lines
end

ts_configs.setup({
  ensure_installed = {
    "bash", "comment", "css", "dockerfile", "gitignore", "html", "http",
    "javascript", "json", "lua", "markdown", "markdown_inline", "python",
    "regex", "scss", "tsx", "typescript", "vim", "vimdoc", "yaml", "toml",
    "go",
  },
  sync_install = false,
  auto_install = true,
  ignore_install = {},

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = function(lang, buf)
      if is_large(buf) then
        BigFile.state[buf] = true
        if not notified[buf] then
          vim.schedule(function()
            vim.notify(
              ("[Treesitter] Deshabilitado highlight para archivo grande (> %d KB o > %d líneas)")
              :format(BIG_FILE_SIZE / 1024, BIG_FILE_LINES),
              vim.log.levels.WARN,
              { title = "Treesitter" }
            )
          end)
          notified[buf] = true
        end
        return true
      end
      BigFile.state[buf] = false
      return false
    end,
  },

  indent = {
    enable = true,
    disable = { "python", "css", "scss" },
  },

  rainbow = {
    enable = true,
    query = 'rainbow-parens',
    strategy = require('rainbow-delimiters').strategy['local'],
    disable = function(lang, buf)
      if is_large(buf) then
        BigFile.state[buf] = true
        if not notified[buf] then
          vim.schedule(function()
            vim.notify("[Rainbow] Deshabilitado en archivo grande", vim.log.levels.WARN, { title = "Treesitter" })
          end)
          notified[buf] = true
        end
        return true
      end
      return false
    end,
  },
})

-- Incremental selection
local sel = require('nvim-treesitter.incremental_selection')
vim.keymap.set('n', '<CR>', sel.init_selection, { desc = 'TS: iniciar selección' })
vim.keymap.set('n', '<TAB>', sel.node_incremental, { desc = 'TS: expandir nodo' })
vim.keymap.set('n', '<S-TAB>', sel.node_decremental, { desc = 'TS: reducir nodo' })
