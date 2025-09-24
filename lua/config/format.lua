-- ?????????????????????????????????????????????????????????????????????????????
-- Comandos: :Format (buffer), :FormatLine (l’nea actual), :FormatSelection (selecci—n)
-- Pega este bloque al final del archivo. No modifica tu l—gica previa.
-- ?????????????????????????????????????????????????????????????????????????????

-- helpers locales m’nimos (no tocan resto del archivo)
local function _has_lsp_method(bufnr, method)
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.supports_method and c:supports_method(method) then return true end
  end
  return false
end

local function _line_end_col0(bufnr, lnum1)
  local text = vim.api.nvim_buf_get_lines(bufnr, lnum1 - 1, lnum1, false)[1] or ""
  return #text -- col 0-index al final de la l’nea
end

-- Construye rango para Conform: filas 1-index, cols 0-index
local function _mk_conform_range(bufnr, s_row1, s_col1, e_row1, e_col1)
  if (e_row1 < s_row1) or (e_row1 == s_row1 and (e_col1 or 1) < (s_col1 or 1)) then
    s_row1, e_row1, s_col1, e_col1 = e_row1, s_row1, e_col1, s_col1
  end
  local s_col0 = (s_col1 and math.max(s_col1 - 1, 0)) or 0
  local e_col0 = (e_col1 and math.max(e_col1 - 1, 0)) or _line_end_col0(bufnr, e_row1)
  return { start = { s_row1, s_col0 }, ["end"] = { e_row1, e_col0 } }
end

-- Intenta formatear con Conform; si hay rango, NO usar lsp_fallback
local function _conform_format(opts)
  local ok, conform = pcall(require, 'conform')
  if not ok then return false end
  local cfg = {
    bufnr = opts.bufnr,
    timeout_ms = opts.timeout_ms or 3000,
    quiet = true,
    lsp_fallback = opts.range and false or true,
    range = opts.range,
  }
  local ok_call, err = pcall(function()
    conform.format(cfg, function(cb_err)
      if cb_err then
        vim.notify('Formato (Conform) fall—: ' .. tostring(cb_err), vim.log.levels.WARN)
      end
    end)
  end)
  if not ok_call then
    vim.notify('Formato (Conform) lanz— excepci—n: ' .. tostring(err), vim.log.levels.WARN)
  end
  return true
end

-- Fallback LSP (respeta rango si el servidor lo soporta)
local function _lsp_format(opts)
  local bufnr = opts.bufnr
  if opts.range then
    if not _has_lsp_method(bufnr, 'textDocument/rangeFormatting') then
      vim.notify('Ningœn LSP soporta rangeFormatting en este buffer.', vim.log.levels.INFO)
      return
    end
    local r = opts.range
    pcall(vim.lsp.buf.format, {
      bufnr = bufnr,
      async = false,
      timeout_ms = opts.timeout_ms or 3000,
      range = {
        start = { line = r.start[1] - 1, character = r.start[2] }, -- LSP: 0/0
        ["end"] = { line = r["end"][1] - 1, character = r["end"][2] },
      },
    })
  else
    if not _has_lsp_method(bufnr, 'textDocument/formatting') then
      vim.notify('Ningœn LSP con formatting disponible.', vim.log.levels.INFO)
      return
    end
    pcall(vim.lsp.buf.format, {
      bufnr = bufnr,
      async = false,
      timeout_ms = opts.timeout_ms or 3000,
    })
  end
end

-- Wrapper comœn
local function _do_format(opts)
  local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
  if _conform_format({ bufnr = bufnr, range = opts.range, timeout_ms = opts.timeout_ms }) then
    return
  end
  _lsp_format({ bufnr = bufnr, range = opts.range, timeout_ms = opts.timeout_ms })
end

-- Elimina comandos previos si existen para evitar errores al redefinir
pcall(vim.api.nvim_del_user_command, 'Format')
pcall(vim.api.nvim_del_user_command, 'FormatLine')
pcall(vim.api.nvim_del_user_command, 'FormatSelection')

-- :Format ? buffer completo
vim.api.nvim_create_user_command('Format', function()
  _do_format({})
end, { desc = 'Formatear buffer completo (Conform -> LSP)' })

-- :FormatLine ? s—lo la l’nea actual (modo Normal)
vim.api.nvim_create_user_command('FormatLine', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local l = vim.api.nvim_win_get_cursor(0)[1]
  local range = _mk_conform_range(bufnr, l, 1, l, _line_end_col0(bufnr, l) + 1)
  _do_format({ range = range, bufnr = bufnr })
end, { desc = 'Formatear l’nea actual' })

-- :FormatSelection ? respeta selecci—n visual exacta (o l’neas completas si estabas en Visual Line)
vim.api.nvim_create_user_command('FormatSelection', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local sp, ep = vim.fn.getpos("'<"), vim.fn.getpos("'>")
  if sp[2] == 0 or ep[2] == 0 then
    vim.notify('No hay selecci—n visual activa', vim.log.levels.INFO)
    return
  end
  local s_row1, s_col1 = sp[2], sp[3]
  local e_row1, e_col1 = ep[2], ep[3]
  if vim.fn.mode() == 'V' then
    -- En Visual Line, cubre l’neas completas
    s_col1 = 1
    e_col1 = _line_end_col0(bufnr, e_row1) + 1
  end
  local range = _mk_conform_range(bufnr, s_row1, s_col1, e_row1, e_col1)
  _do_format({ range = range, bufnr = bufnr })
end, { desc = 'Formatear selecci—n visual' })

vim.keymap.set('n', '<leader>f', '<cmd>Format<cr>', { desc = 'Format buffer' })
vim.keymap.set('n', 'gQ', '<cmd>FormatLine<cr>', { desc = 'Format current line' })
vim.keymap.set('x', '<leader>f', '<esc><cmd>FormatSelection<cr>', { desc = 'Format selection' })
