do
  local ai = require("mini.ai")

  ai.setup({
    n_lines = 200,

    custom_textobjects = {
      custom_textobjects = {
        -- funciones
        f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
        -- clases
        c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
      },

      -- Bucles / bloques
      o = ai.gen_spec.treesitter({
        a = "@loop.outer",
        i = "@loop.inner",
      }),

      -- Parámetros
      p = ai.gen_spec.treesitter({
        a = "@parameter.outer",
        i = "@parameter.inner",
      }),
    },
  })
end
