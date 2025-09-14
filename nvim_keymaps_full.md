# 📌 Atajos de Teclado – Neovim

## Leader

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "
```

---

## Tabla de atajos detectados

| Modo | Teclas          | Acción/Descripción         | Archivo                                     |
| ---- | --------------- | -------------------------- | ------------------------------------------- |
| `n`  | `<M-l>`         | Lowercase word             | `nvim/lua/config/mini.lua`                  |
| `n`  | `<M-t>`         | Toggle case word           | `nvim/lua/config/mini.lua`                  |
| `n`  | `<M-u>`         | Uppercase word             | `nvim/lua/config/mini.lua`                  |
| `n`  | `gA`            | function(                  | `nvim/lua/config/mini.lua`                  |
| `n`  | `gss`           | function(                  | `nvim/lua/config/mini.lua`                  |
| `x`  | `<M-l>`         | Lowercase selection        | `nvim/lua/config/mini.lua`                  |
| `x`  | `<M-t>`         | Toggle case selection      | `nvim/lua/config/mini.lua`                  |
| `x`  | `<M-u>`         | Uppercase selection        | `nvim/lua/config/mini.lua`                  |
| `x`  | `gS`            | function(                  | `nvim/lua/config/mini.lua`                  |
| `x`  | `ga`            | function(                  | `nvim/lua/config/mini.lua`                  |
| `n`  | `<leader><Tab>` | Open parent directory      | `nvim/lua/config/oil.lua`                   |
| `n`  | `<F8>`          | ":TagbarToggle<CR>"        | `nvim/lua/config/other-pluggins-config.lua` |
| `n`  | `<Leader>H`     | ":TmuxNavigateLeft<CR>"    | `nvim/lua/config/other-pluggins-config.lua` |
| `n`  | `<Leader>J`     | ":TmuxNavigateDown<CR>"    | `nvim/lua/config/other-pluggins-config.lua` |
| `n`  | `<Leader>K`     | ":TmuxNavigateUp<CR>"      | `nvim/lua/config/other-pluggins-config.lua` |
| `n`  | `<Leader>L`     | ":TmuxNavigateRight<CR>"   | `nvim/lua/config/other-pluggins-config.lua` |
| `n`  | `<CR>`          | TS: iniciar selección      | `nvim/lua/config/treesitter.lua`            |
| `n`  | `<S-TAB>`       | TS: reducir nodo           | `nvim/lua/config/treesitter.lua`            |
| `n`  | `<TAB>`         | TS: expandir nodo          | `nvim/lua/config/treesitter.lua`            |
| `n`  | `<C-Q>`         | Forzar salir               | `nvim/lua/mapped.lua`                       |
| `n`  | `<Down>`        | Reducir alto               | `nvim/lua/mapped.lua`                       |
| `n`  | `<Esc>`         | Quitar búsqueda resaltada  | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>Q`     | Salir                      | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>W`     | Guardar y salir            | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>j`     | Buffer anterior            | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>k`     | Buffer siguiente           | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>q`     | Cerrar buffer              | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>sp`    | Horizontal split           | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>vs`    | Vertical split             | `nvim/lua/mapped.lua`                       |
| `n`  | `<Leader>w`     | Guardar                    | `nvim/lua/mapped.lua`                       |
| `n`  | `<Left>`        | Reducir ancho              | `nvim/lua/mapped.lua`                       |
| `n`  | `<Right>`       | Aumentar ancho             | `nvim/lua/mapped.lua`                       |
| `n`  | `<Up>`          | Aumentar alto              | `nvim/lua/mapped.lua`                       |
| `n`  | `<leader>f`     | Formatear **línea actual** | `nvim/lua/config/format.lua`                |
| `x`  | `<leader>f`     | Formatear **selección**    | `nvim/lua/config/format.lua`                |

---

## Comandos útiles añadidos

- `:Format` → formatea **todo el buffer** (usa `prettierd`).
- `:FormatLine` → formatea **la línea actual** (fuerza Prettier CLI).
- `:FormatSel` → formatea **selección visual** o rango `:[linea1],[linea2]FormatSel`.
- `:FormatPrettier` → fuerza **Prettier CLI** en todo el buffer.
- `:PrettierdStop` → detener el daemon de `prettierd`.
- `:PrettierdRestart` → reiniciar `prettierd`.
