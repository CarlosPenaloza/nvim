-- bufferline ultra minimal (sin colores ni lógica)

local ok, bufferline = pcall(require, "bufferline")
if not ok then return end

bufferline.setup({
  options = {
    mode = "buffers",
    numbers = "none",

    indicator = {
      style = "icon",
      icon = "▎", -- más sutil que █
    },

    buffer_close_icon = "",
    modified_icon = "●",

    show_buffer_close_icons = false,
    show_close_icon = false,

    diagnostics = false,

    separator_style = "thin", -- más limpio

    insert_at_end = true,
    sort_by = "id",

    max_name_length = 25,
    truncate_names = true,

    color_icons = true,
    always_show_bufferline = false,
    hover = { enabled = false }
  },
})
