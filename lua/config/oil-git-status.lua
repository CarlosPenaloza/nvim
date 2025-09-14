-- Estado de Git en Oil (opcional)
local ok_git, oil_git_status = pcall(require, "oil-git-status")
if ok_git then
  oil_git_status.setup({
    show_ignored = false, -- mostrar ignorados puede costar; déjalo en false para repos grandes
    -- Si notas refrescos constantes, puedes subir el debounce del plugin si lo soporta.
  })
end
