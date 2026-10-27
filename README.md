# Post-install Setup

## Desarrollo Web: Lit y React

Requisitos: Neovim >= 0.12, Git y una version LTS de Node.js compatible
con tu proyecto. Lazy instala los plugins y Mason instala los servidores y
formateadores; no instala las dependencias npm de tus aplicaciones.

### TypeScript y Lit

VTSLS es el unico servidor TypeScript/JavaScript activo. Utiliza el TypeScript
del proyecto cuando esta disponible, respeta la raiz de monorepos y no se
activa dentro de proyectos Deno. Los errores al cargar la configuracion se
muestran en las notificaciones y en `:messages`.

Para analizar propiedades, eventos y bindings de Lit, instala en cada proyecto:

```sh
npm install --save-dev typescript ts-lit-plugin
```

Incorpora este plugin a las opciones existentes de tu tsconfig, sin reemplazar
las demas opciones ni otros plugins:

```json
{
  "compilerOptions": {
    "plugins": [{ "name": "ts-lit-plugin", "strict": true }]
  }
}
```

Para JavaScript utiliza la misma opcion en jsconfig.json. Reinicia Neovim
despues de instalar o cambiar plugins de TypeScript. El analisis de plantillas
depende de la compatibilidad entre las versiones de TypeScript y ts-lit-plugin.
Los proyectos con Yarn PnP necesitan su SDK/resolucion de modulos correspondiente.

Treesitter resalta HTML y CSS dentro de plantillas Lit, incluidas interpolaciones.
Los snippets HTML se ofrecen en JS/TS solo dentro de plantillas etiquetadas
`html` de Lit, no dentro de sus expresiones `${...}` ni en cadenas normales.
React conserva los snippets JSX/TSX de su lenguaje, sin heredar HTML globalmente.
La deteccion requiere el parser de Treesitter del archivo; si no esta disponible,
solo se ofrecen los snippets del lenguaje principal. Los archivos HTML mantienen
sus snippets normales.
Los snippets `lit-element` y `lit-event` estan disponibles en JavaScript y
TypeScript; `lit-property` y `lit-state` son exclusivos de TypeScript. Los snippets
con decoradores usan `accessor`: respeta la configuracion de decoradores de tu
proyecto y anade los imports necesarios (`property` o `state`).

`lit-property-doc` y `lit-method-doc` insertan JSDoc junto con la propiedad o
el metodo. En normal o insercion, `<localleader>lp` y `<localleader>lm` los
insertan directamente (localleader es espacio en esta configuracion).
En JavaScript, la propiedad es una entrada para `static properties` o el objeto
devuelto por `static get properties()`; inicializa su valor en el constructor.
En TypeScript se genera un `@property` con `accessor`. Recorre los campos con Tab.

### ESLint, React y Formato

ESLint se activa en proyectos con configuracion ESLint. Usa las dependencias y
reglas del proyecto; no se crean archivos de reglas en tu directorio personal.
Las configuraciones globales creadas por versiones anteriores no se borran.
Si falta el ejecutable del servidor se muestra un aviso una sola vez, en lugar
de fallar al abrir archivos. Instalalo con `:MasonInstall eslint-lsp` y reinicia
Neovim. Si npm devuelve ETIMEDOUT, revisa acceso al registro/red corporativa;
instalar el servidor es independiente de instalar ESLint en cada proyecto.

Para Lit, incorpora `eslint-plugin-lit` y `eslint-plugin-lit-a11y` a la
configuracion del proyecto. Para React, usa sus reglas de hooks y accesibilidad
(`eslint-plugin-react-hooks` y `eslint-plugin-jsx-a11y`). En proyectos modernos
prefiere eslint.config.js/mjs; conserva el formato que requiera un proyecto antiguo.
Instalar un plugin npm no activa sus reglas: hay que incluirlo en la configuracion.

Prettier conserva el formato manual: `<leader>F` o `:Format` para el archivo y
`<leader>f` en visual para solo la seleccion. `:10,20FormatSelection` procesa
un rango de lineas. No se amplia automaticamente al bloque de Treesitter.
Las selecciones visuales admiten lineas o caracteres, no bloques rectangulares;
si un cambio de Prettier cruza el limite seleccionado, se omite y se avisa.
Conform prefiere el ejecutable local
del proyecto y utiliza Mason como respaldo. No hay formato ni autofix al guardar.
`:LspEslintFixAll` aplica correcciones ESLint y `:LspOrganizeImports` organiza imports.
`<leader>ih` alterna las pistas de tipos. Comprueba clientes con `:LspInfo` y
formateadores con `:ConformInfo`.

### Colores y Legibilidad

El tema inicial es Gruvbox (ellisonleao/gruvbox.nvim), con soporte de Treesitter
y colores semanticos del LSP. `:ThemeToggle` alterna con Catppuccin; la barra de
estado y los ajustes de resaltado siguen el tema activo.

Funciones/metodos, propiedades y parametros tienen grupos diferenciados.
En Lit, `.value` usa el color de propiedad, `?disabled` el de booleano y
`@click` el de funcion/evento; los atributos normales conservan su propio grupo.
Los tokens semanticos genericos de variables, cadenas y comentarios no tapan
los colores de Treesitter ni del HTML/CSS embebido.

Los comentarios Gruvbox tienen mayor contraste. Los diagnosticos usan subrayado
ondulado y texto sin fondos destacados. Estos ajustes se aplican al cargar o
cambiar el tema; no anaden temporizadores, eventos por pulsacion ni otro parser.
Usa `:Inspect` sobre un simbolo para consultar sus grupos de resaltado.

### Busqueda con Grep

La busqueda activa es Fzf-Lua, no Telescope. `<leader>fg` busca desde la raiz
del paquete/proyecto, respeta los archivos ignorados y excluye node_modules,
dist, build, coverage y caches de frameworks. No sigue enlaces simbolicos ni
lee archivos mayores de 1 MB, y no ejecuta grep con una consulta vacia.
`<leader>fG` permite buscar tambien archivos ocultos/ignorados sin el limite
de tamano; conserva la exclusion de .git y puede ser mas lento.

### Plegado de Codigo

UFO usa Treesitter con respaldo de indentacion. Los folds conservan el resaltado
de su cabecera y muestran el numero de lineas ocultas; no se recorren los bloques
ni se consultan diagnosticos para dibujar el resumen. Los archivos se abren
desplegados, sin ocultar automaticamente JSDoc ni metodos.
En JS/TS/JSX/TSX el proveedor prepara las inyecciones de Treesitter al solicitar
los rangos, reutilizando el parser incremental: las etiquetas HTML de Lit se
pueden plegar desde la apertura del archivo. Las plantillas completas `html` y
`css` tienen tambien su propio fold. No se anaden eventos de teclado ni timers
para esta preparacion y se conservan los limites de tamano indicados abajo.

| Atajo | Accion |
| --- | --- |
| `za` / `zo` / `zc` | Alternar, abrir o cerrar el fold bajo el cursor |
| `zM` / `zR` | Cerrar o abrir todos los folds |
| `2zm` | Cerrar folds por debajo del nivel 2; admite otra cuenta |
| `zr` | Abrir salvo los grupos de folds configurados |
| `zp` | Vista previa del fold cerrado; si no hay fold, hover LSP |

En la vista previa: Ctrl-d/Ctrl-u desplazan, Tab cambia el foco, Enter salta al
codigo y q cierra. `:UfoInspect` muestra los proveedores y tipos de folds activos.

El selector consulta el buffer recibido y su tamano en memoria, sin acceder al
disco. Usa indentacion por encima de 200 KB o 10000 lineas, y desactiva los
proveedores por encima de 1.5 MB o con LargeFileOn. Oil, terminales y otros
buffers especiales quedan excluidos. LargeFileOff restaura UFO si estaba activo.
No se anaden dependencias, temporizadores ni escaneos en cada pulsacion.

### Pruebas

Neotest incluye el adaptador de Vitest y utiliza la configuracion de tus proyectos.
Vitest debe estar instalado en el proyecto; no se cambia el runner existente.
Guarda los archivos antes de ejecutar pruebas.

| Atajo | Accion |
| --- | --- |
| `<leader>Tn` | Prueba mas cercana (Vitest) |
| `<leader>Tf` | Archivo actual (Vitest) |
| `<leader>Ta` | Directorio de trabajo actual (Vitest) |
| `<leader>Ts` | Resumen de resultados |
| `<leader>To` | Salida de una prueba |
| `<leader>Tx` | Detener prueba |
| `<leader>Tw` | Archivo actual (Web Test Runner) |
| `<leader>TW` | Proyecto (Web Test Runner) |

Para proyectos que utilizan `@web/test-runner`, `:WebTest` ejecuta el archivo
actual y `:WebTestAll` usa la seleccion de archivos de la configuracion del
proyecto. Anade `!` para modo watch. Se usa exclusivamente el ejecutable local,
incluyendo dependencias elevadas al directorio raiz de un monorepo; no se ejecuta
npx ni se descargan paquetes implicitamente. La salida aparece en un terminal:
`Ctrl-\ Ctrl-n` vuelve al modo normal y `Ctrl-c` en modo terminal detiene el runner.

### Comprobaciones de Esta Configuracion

Desde la raiz de este repositorio:

```sh
nvim --headless -u NONE -l tests/config_spec.lua
NVIM_INTEGRATION_TESTS=1 nvim --headless -u NONE -l tests/config_spec.lua
```

La segunda comprobacion requiere LuaSnip, nvim-treesitter y los parsers
javascript, typescript, tsx, html y css instalados. Comprueba inyecciones Lit y
parseo real de snippets, pero no sustituye ejecutar las pruebas de una aplicacion.

## 🐚 Zsh

### Cambiar shell por defecto

```bash
chsh -s $(which zsh)
```

### Instalar Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Plugins de Oh My Zsh

#### zsh-autosuggestions

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

#### zsh-syntax-highlighting

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### zsh-you-should-use

```bash
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git \
  $ZSH_CUSTOM/plugins/you-should-use
```

#### En `.zshrc`:

```zsh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)
```

### Powerlevel10k

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

---

## 📦 Node / NVM

### Instalar NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```

#### En `.zshrc`:

```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

---

## 📝 Neovim

### Gestor de plugins (lazy.nvim)

Lazy.nvim se bootstrapea automáticamente en `init.lua`:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
```

Luego se cargan los plugins desde `lua/plugins/init.lua`.

### Estructura de la config

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── index.lua
│   ├── plugins/
│   │   └── init.lua
│   │   └── lsp.lua
│   │   └── ui-productivity.lua
│   └── config/
│       ├── oil.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       ├── lualine.lua
│       ├── bufferline.lua
│       ├── mini.lua
│       ├── gitsigns.lua
│       ├── oil-git.lua
│       ├── oil-git-status.lua
│       ├── other-pluggins-config.lua
│       ├── largefile.lua
│       ├── lsp.lua
│       ├── lsp_ts.lua
│       ├── cmp.lua
│       ├── format.lua
```

### Comandos útiles

- **Instalar / actualizar plugins**
  ```vim
  :Lazy sync
  :Lazy update
  ```
- **Revisar estado**
  ```vim
  :Lazy
  ```
- **Perf profiling**
  ```vim
  :Lazy profile
  ```

### LSP

- **Instalar servidores** con Mason:
  ```vim
  :Mason
  ```
- **Ver estado LSP activo**:
  ```vim
  :LspInfo
  ```
- **Reiniciar LSP**:
  ```vim
  :LspRestart
  ```

### Formateo (con conform.nvim)

- `:Format`: archivo completo con Prettier para lenguajes web.
- `:10,20FormatSelection`: solo las lineas indicadas.

Atajos:

- `<leader>F` (normal): archivo completo.
- `<leader>f` (visual): solo el codigo seleccionado.

---

## 🕒 Sincronizar hora Windows/Linux

```bash
sudo timedatectl set-local-rtc 1
```

---

## 📋 Copiar y pegar en Linux

Para tener soporte de portapapeles en Neovim se recomienda instalar **CopyQ**:

```bash
sudo pacman -S copyq   # en Arch Linux
sudo apt install copyq # en Ubuntu/Debian
```

Ejecuta CopyQ en segundo plano:

```bash
copyq &
```

Verifica que tu Neovim tenga soporte para `+clipboard`:

```bash
nvim --version | grep clipboard
```

Si ves `+clipboard`, entonces puedes usar:

- `"+y` para copiar al portapapeles del sistema
- `"+p` para pegar desde el portapapeles del sistema

---

## 🎧 Configuración de Bluetooth

### Paquetes necesarios

```bash
Bluez
Bluez Utils
Blueman
```

### Servicios

```bash
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service
```

---

## 🐞 Troubleshooting

### Lazy.nvim no encuentra plugins

- Verifica que `~/.config/nvim/lua/plugins/init.lua` exista y empiece con `return { ... }`
- Si tienes `lua/plugins.lua` viejo, elimínalo o renómbralo

### Portapapeles no funciona

- Comprueba que `nvim --version` muestre `+clipboard`
- Si ves `-clipboard`, instala `neovim-gtk` o `neovim-qt` o recompila con soporte

### ESLint no arranca

- Asegúrate de tener `eslint` instalado en el proyecto:
  ```bash
  npm i -D eslint eslint-config-prettier
  ```
- Si usas TS + Lit:
  ```bash
  npm i -D @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-plugin-lit eslint-plugin-lit-a11y
  ```
- Revisa `:LspInfo` para confirmar que ESLint LSP está activo.
