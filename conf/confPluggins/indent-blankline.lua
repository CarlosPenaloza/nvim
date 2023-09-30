local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#B062FA" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#7757DE" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#6B70F5" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#577FDE" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#62B7FA" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#47ABDE" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#50EEFA" })
end)

vim.g.rainbow_delimiters = { highlight = highlight }
require("ibl").setup { scope = { highlight = highlight } }

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
