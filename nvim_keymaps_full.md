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
| `n`  | `<leader>F`     | Formatear **archivo completo** | `nvim/lua/config/format.lua`             |
| `x`  | `<leader>f`     | Formatear **selección**    | `nvim/lua/config/format.lua`                |

---

## Comandos útiles añadidos

- `:Format`: formatea el buffer mediante Conform (Prettier para web).
- `:'<,'>FormatSelection`: formatea solo las lineas del rango, sin ampliar al bloque.
- `<localleader>lp` / `<localleader>lm`: propiedad o metodo Lit con JSDoc (normal/insercion).
- `<leader>fg` / `<leader>fG`: grep del proyecto o grep incluyendo ignorados/ocultos.
- `:LspOrganizeImports`: organiza imports con el servidor TypeScript.
- `:LspEslintFixAll`: aplica correcciones de ESLint al buffer.
- `<leader>ih`: alterna las pistas de tipos del LSP.
- `<leader>Tn` / `<leader>Tf` / `<leader>Ta`: prueba cercana, archivo o directorio con Vitest.
- `<leader>Ts` / `<leader>To` / `<leader>Tx`: resumen, salida o detener prueba.
- `<leader>Tw` / `<leader>TW`: archivo o proyecto con Web Test Runner.
- `:WebTest!` / `:WebTestAll!`: ejecuta Web Test Runner en modo watch.
- `:LargeFileOn` / `:LargeFileOff`: desactiva/restaura funciones costosas solo para el buffer actual.
