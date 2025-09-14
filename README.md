# Post-install Setup

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
│   └── config/
│       ├── oil.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       ├── lualine.lua
│       ├── bufferline.lua
│       ├── coc.lua
│       ├── mini.lua
│       ├── gitsigns.lua
│       ├── oil-git.lua
│       ├── oil-git-status.lua
│       ├── other-pluggins-config.lua
│       └── largefile.lua
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

### coc.nvim no arranca

- Ejecuta `:CocUpdate`
- Revisa que Node esté instalado (`node --version`)
- Usa `:CocInfo` para logs detallados
