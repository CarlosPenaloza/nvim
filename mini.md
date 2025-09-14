# Mini.nvim – Atajos clave

## Comentarios — `mini.comment`

- `gcc`: comentar/descomentar línea
- `gc` (visual): comentar/descomentar selección
- `gc` + textobject (ej. `gcap`): comentar párrafo

## Surround — `mini.surround` (prefijo `gs`)

- `gsa`: añadir surround (ej. `gsaiw)`)
- `gsd`: eliminar surround (ej. `gsd"`)
- `gsc`: cambiar surround (ej. `gsc"\'`)
- `gss`: rodear línea completa
- `gS` (visual): rodear selección
- `gsf` / `gsF`: buscar a derecha / izquierda
- `gsh`: resaltar entorno

## Autopairs — `mini.pairs`

- Inserción automática de paréntesis, comillas, etc.

## Mover texto — `mini.move`

- `Alt+h/j/k/l`: mover bloques o líneas

## Alinear — `mini.align`

- Visual: `ga` → alineación interactiva
- Normal: `gA` → alineación por carácter/patrón

## Split/Join — `mini.splitjoin`

- `gS`: alternar una línea ↔ multilínea

## Espacios finales — `mini.trailspace`

- Eliminación automática al guardar (excepto `md` y `txt`)

## Indentación — `mini.indentscope`

- `│` mostrando bloques (desactivado en buffers especiales)

## Colores en código — `mini.hipatterns`

- Resalta `#RRGGBB` con su color

## Textobjects — `mini.ai`

Operador + `a`/`i` + letra:

- `f`: función → `daf`, `yif`
- `c`: clase → `dac`, `yic`
- `o`: bucle → `dao`, `yio`
- `p`: parámetro → `dap`, `yip`

También:

- Paréntesis: `a)` / `i)`
- Comillas: `a"` / `i"`
- Tags: `at` / `it`

## transformaciones de texto

- Normal mode (palabra):
  - `Alt+u`: MAYÚSCULAS
  - `Alt+l`: minúsculas
  - `Alt+t`: alternar
- Visual mode (selección):
  - `Alt+u`: MAYÚSCULAS
  - `Alt+l`: minúsculas
  - `Alt+t`: alternar
