# 📌 Atajos de Teclado – Neovim

## Leader

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

```

## Tabla de atajos detectados

| Modo | Teclas | Acción/Descripción | Archivo |
|---|---|---|---|
| `n` | `<M-l>` | Lowercase word | `nvim/lua/config/mini.lua` |
| `n` | `<M-t>` | Toggle case word | `nvim/lua/config/mini.lua` |
| `n` | `<M-u>` | Uppercase word | `nvim/lua/config/mini.lua` |
| `n` | `gA` | function( | `nvim/lua/config/mini.lua` |
| `n` | `gss` | function( | `nvim/lua/config/mini.lua` |
| `x` | `<M-l>` | Lowercase selection | `nvim/lua/config/mini.lua` |
| `x` | `<M-t>` | Toggle case selection | `nvim/lua/config/mini.lua` |
| `x` | `<M-u>` | Uppercase selection | `nvim/lua/config/mini.lua` |
| `x` | `gS` | function( | `nvim/lua/config/mini.lua` |
| `x` | `ga` | function( | `nvim/lua/config/mini.lua` |
| `n` | `<leader><Tab>` | Open parent directory | `nvim/lua/config/oil.lua` |
| `n` | `<leader><Tab>` | Open parent directory | `nvim/lua/config/oil.lua` |
| `n` | `<F8>` | ":TagbarToggle<CR>" | `nvim/lua/config/other-pluggins-config.lua` |
| `n` | `<Leader>H` | ":TmuxNavigateLeft<CR>" | `nvim/lua/config/other-pluggins-config.lua` |
| `n` | `<Leader>J` | ":TmuxNavigateDown<CR>" | `nvim/lua/config/other-pluggins-config.lua` |
| `n` | `<Leader>K` | ":TmuxNavigateUp<CR>" | `nvim/lua/config/other-pluggins-config.lua` |
| `n` | `<Leader>L` | ":TmuxNavigateRight<CR>" | `nvim/lua/config/other-pluggins-config.lua` |
| `n` | `<CR>` | TS: iniciar selección | `nvim/lua/config/treesitter.lua` |
| `n` | `<S-TAB>` | TS: reducir nodo | `nvim/lua/config/treesitter.lua` |
| `n` | `<TAB>` | TS: expandir nodo | `nvim/lua/config/treesitter.lua` |
| `n` | `<C-Q>` | Forzar salir | `nvim/lua/mapped.lua` |
| `n` | `<Down>` | Reducir alto | `nvim/lua/mapped.lua` |
| `n` | `<Esc>` | Quitar búsqueda resaltada | `nvim/lua/mapped.lua` |
| `n` | `<Leader>Q` | Salir | `nvim/lua/mapped.lua` |
| `n` | `<Leader>W` | Guardar y salir | `nvim/lua/mapped.lua` |
| `n` | `<Leader>j` | Buffer anterior | `nvim/lua/mapped.lua` |
| `n` | `<Leader>k` | Buffer siguiente | `nvim/lua/mapped.lua` |
| `n` | `<Leader>q` | Cerrar buffer | `nvim/lua/mapped.lua` |
| `n` | `<Leader>sp` | Horizontal split | `nvim/lua/mapped.lua` |
| `n` | `<Leader>vs` | Vertical split | `nvim/lua/mapped.lua` |
| `n` | `<Leader>w` | Guardar | `nvim/lua/mapped.lua` |
| `n` | `<Left>` | Reducir ancho | `nvim/lua/mapped.lua` |
| `n` | `<Right>` | Aumentar ancho | `nvim/lua/mapped.lua` |
| `n` | `<Up>` | Aumentar alto | `nvim/lua/mapped.lua` |

## Mapeos de Mini.nvim (desde setup)

### mini.surround
| Acción | Tecla |
|---|---|
| `add` | `gsa` |
| `delete` | `gsd` |
| `replace` | `gsc` |
| `find` | `gsf` |
| `find_left` | `gsF` |
| `highlight` | `gsh` |
| `update_n_lines` | `gsn` |
| `desc` | `MiniAlign (normal)` |
| `left` | `<M-h>` |
| `right` | `<M-l>` |
| `down` | `<M-j>` |
| `up` | `<M-k>` |
| `line_left` | `<M-h>` |
| `line_right` | `<M-l>` |
| `line_down` | `<M-j>` |
| `line_up` | `<M-k>` |
| `toggle` | `gS` |
### mini.splitjoin
| Acción | Tecla |
|---|---|
| `toggle` | `gS` |