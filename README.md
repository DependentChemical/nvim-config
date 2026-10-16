# nvim-config

Personal Neovim configuration for Windows. Single-file setup (`init.lua`)
managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Location

This repo must live at Neovim's Windows config path:

```
%LOCALAPPDATA%\nvim\   (e.g. C:\Users\<you>\AppData\Local\nvim)
```

Runtime data (plugins, Mason packages, swap, undo, logs) lives separately in
`%LOCALAPPDATA%\nvim-data\` and is never committed.

## What's tracked

| File           | Purpose                                              |
|----------------|------------------------------------------------------|
| `init.lua`     | Entire config: options, plugins, LSP, keymaps        |
| `lazy-lock.json` | Pinned plugin commits for reproducible installs   |
| `.gitignore`   | Ignore rules (binaries, runtime noise, secrets)      |
| `README.md`    | This file                                            |

## What's intentionally ignored

* `biome.exe` — ~79 MB standalone Biome binary used as the JSON/JSONC
  LSP server (`biome lsp-proxy`). Re-download per machine, see below.
* `*.log`, swap (`*.swp`), undo, shada, session files — host-specific noise.
* `.env`, `*.pem`, `*.key`, `secrets.lua` — never commit secrets.

## Fresh-machine restore

1. Install Neovim (≥ 0.11), Git, a Nerd Font, and PowerShell 7 (`pwsh`).
2. Clone here (not to `~/.config/nvim`, that's for WSL/Linux):
   ```powershell
   git clone https://github.com/DependentChemical/nvim-config.git "$env:LOCALAPPDATA\nvim"
   ```
3. Open Neovim once — `lazy.nvim` bootstraps itself and installs plugins:
   ```
   nvim
   :Lazy sync
   ```
4. Install language servers via Mason (`:Mason`), or they install on demand
   via `mason-lspconfig` (`lua_ls`, `rust_analyzer`, `clangd`,
   `powershell_es`, `pyrefly`).
5. Restore `biome.exe` for JSON/JSONC support:
   * Download the standalone `biome` Windows binary from
     https://github.com/biomejs/biome/releases
   * Rename it to `biome.exe` and place it next to `init.lua`
     (i.e. `%LOCALAPPDATA%\nvim\biome.exe`).
   * Verify with `:checkhealth` or `:lua print(vim.fn.executable("biome"))`
     from the config dir.
6. Optional: `:MasonLog` / `:Lazy log` if anything fails to install.

## Daily workflow

```powershell
nvim                              # edit config: $env:LOCALAPPDATA\nvim\init.lua
git -C $env:LOCALAPPDATA\nvim status --short
git -C $env:LOCALAPPDATA\nvim add -p
git -C $env:LOCALAPPDATA\nvim commit -m "feat: ..."
git -C $env:LOCALAPPDATA\nvim push
```

## Plugins (via lazy.nvim)

Tokyonight colorscheme, lualine, telescope, oil.nvim, treesitter,
mason + mason-lspconfig, nvim-lspconfig, blink.cmp, vim-gml (GameMaker),
vim-monkeyc (Garmin Monkey-C).

## Notes

* Branch is `master` (kept from the original local repo).
* Line endings: Windows CRLF via `core.autocrlf=true`.
