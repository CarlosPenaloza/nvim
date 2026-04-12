require("mini.surround").setup({
  mappings = {
    add = "ys",            -- agregar surround
    delete = "ds",         -- borrar
    replace = "cs",        -- cambiar

    find = "sf",           -- buscar siguiente
    find_left = "sF",      -- buscar anterior
    highlight = "sh",      -- resaltar
    update_n_lines = "sn", -- actualizar líneas

    suffix_last = "l",
    suffix_next = "n",
  },

  n_lines = 50, -- 🔥 clave: mejora rendimiento
})
