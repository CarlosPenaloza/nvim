-- lua/config/largefile.lua
local MAX_BYTES = 1.5 * 1024 * 1024 -- 1.5 MB

local function is_large(path)
  local stat = vim.loop.fs_stat(path or "")
  return stat and stat.size and stat.size > MAX_BYTES
end

vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function(args)
    local fname = args.file
    if fname == "" or not is_large(fname) then return end

    -- Marca el buffer como "grande" para otras configs si necesitas
    vim.b.large_file = true

    -- Desactiva cosas costosas
    pcall(vim.cmd, "syntax off")     -- syntax highlighting fuera
    vim.opt_local.foldenable = false -- no folds
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.swapfile = false   -- evita swap
    vim.opt_local.undofile = false   -- sin undo persistente
    vim.opt_local.list = false       -- ocultar caracteres de lista
    vim.opt_local.wrap = false       -- no wrap
    vim.opt_local.colorcolumn = ""   -- sin columnas guía
    vim.opt_local.cursorline = false -- sin cursorline

    -- Búsqueda más barata visualmente en este buffer
    vim.opt_local.hlsearch = false
    vim.opt_local.incsearch = false

    -- Treesitter puede ser caro: si está cargado, intenta desactivarlo en este buffer
    local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
    if ok_ts and ts_configs then
      -- Forzamos a que no adjunte parsers a este buffer grande
      vim.treesitter.stop()
    end

    -- Notificación suave
    vim.schedule(function()
      vim.notify(
      ("Modo archivo grande (> %.1f MB): sintaxis/TS off, folds off, sin swap/undo."):format(MAX_BYTES / (1024 * 1024)),
        vim.log.levels.INFO)
    end)
  end,
})
