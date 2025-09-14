-- lua/config/telescope.lua

local telescope      = require("telescope")
local actions        = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local builtin        = require("telescope.builtin")

-- Tu filtro original
local file_ignores   = { "^vbank/", "%.yml" }

-- Layout inteligente: horizontal (>=120 cols) / vertical (80–119) / center (<80)
local function smart_layout_opts(extra)
  local cols = vim.o.columns or 120
  if cols < 80 then
    -- ventanas muy angostas: center sin preview
    return vim.tbl_deep_extend("force", {
      layout_strategy = "center",
      layout_config = {
        center = {
          width = 0.9,
          height = 0.5,
          prompt_position = "top",
          preview_cutoff = 9999, -- efectivamente sin preview
        },
      },
      preview = { treesitter = false },
      previewer = false,
    }, extra or {})
  elseif cols < 120 then
    -- vertical: preview abajo SIEMPRE
    return vim.tbl_deep_extend("force", {
      layout_strategy = "vertical",
      layout_config = {
        vertical = {
          width = 0.92,
          height = 0.85,
          prompt_position = "top",
          mirror = false,     -- preview abajo
          preview_cutoff = 0, -- nunca cortes el preview en vertical
          preview_height = 0.45,
        },
      },
      previewer = true, -- fuerza preview
    }, extra or {})
  else
    -- horizontal: preview derecha
    return vim.tbl_deep_extend("force", {
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          width = 0.9,
          height = 0.9,
          prompt_position = "top",
          mirror = false, -- preview derecha
          preview_cutoff = 120,
          preview_width = 0.55,
        },
      },
      previewer = true,
    }, extra or {})
  end
end

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never", "--no-heading", "--with-filename",
      "--line-number", "--column", "--smart-case",
      "--hidden", "--glob", "!.git/*",
    },
    initial_mode = "normal",
    dynamic_preview_title = true,
    path_display = { "smart" },
    sorting_strategy = "ascending",
    file_ignore_patterns = file_ignores,

    -- Base: flex; los keymaps pasan smart_layout_opts por invocación
    layout_strategy = "flex",
    layout_config = {
      flex = { flip_columns = 120 },

      horizontal = {
        width = 0.9,
        height = 0.9,
        prompt_position = "top",
        mirror = false, -- preview derecha
        preview_cutoff = 120,
        preview_width = 0.55,
      },

      vertical = {
        width = 0.92,
        height = 0.85,
        prompt_position = "top",
        mirror = false,     -- preview abajo
        preview_cutoff = 0, -- SIEMPRE mostrar preview en vertical
        preview_height = 0.45,
      },

      center = {
        width = 0.9,
        height = 0.5,
        prompt_position = "top",
        preview_cutoff = 9999, -- sin preview en center
      },
    },

    mappings = {
      i = {
        ["<Esc>"] = actions.close,
        ["<C-p>"] = actions_layout.toggle_preview, -- toggle preview (insert)
      },
      n = {
        ["<Esc>"] = actions.close,
        ["<C-p>"] = actions_layout.toggle_preview, -- toggle preview (normal)
      },
    },

    preview = { treesitter = true },
  },

  pickers = {
    find_files = {
      previewer = true,
      hidden = true,
      follow = true,
      find_command = vim.fn.executable("fd") == 1
          and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" }
          or nil,
    },
    live_grep  = { only_sort_text = true },
    git_status = { previewer = true },
    buffers    = {
      previewer = true,
      sort_lastused = true,
      ignore_current_buffer = true,
    },
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

-- (opcional) carga fzf-native si lo tienes
pcall(telescope.load_extension, "fzf")

-- ====== Keymaps (prefijo <leader>f...) ======
-- Evita choque con Coc en <leader>f
pcall(vim.keymap.del, "n", "<leader>f")

local function map(lhs, fn, desc)
  vim.keymap.set("n", lhs, fn, { silent = true, noremap = true, desc = desc })
end

map("<leader>ff", function() builtin.find_files(smart_layout_opts({ previewer = true })) end, "Telescope files")
map("<leader>fr", function() builtin.git_status(smart_layout_opts({ previewer = true })) end, "Telescope git status")
map("<leader>fg", function() builtin.live_grep(smart_layout_opts()) end, "Telescope live grep")
map("<leader>fb", function() builtin.buffers(smart_layout_opts({ previewer = true })) end, "Telescope buffers")
map("<leader>fh", function() builtin.help_tags(smart_layout_opts()) end, "Telescope help")
map("<leader>fk", function() builtin.keymaps(smart_layout_opts()) end, "Telescope keymaps")
map("<leader>ft", function() builtin.treesitter(smart_layout_opts()) end, "Telescope treesitter")
map("<leader>fs", function() builtin.grep_string(smart_layout_opts()) end, "Telescope grep string")
