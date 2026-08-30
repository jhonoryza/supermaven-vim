# supermaven-vim

Supermaven untuk Vim 9 (port dari [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) Lua → Vimscript). Pakai `job` + `prop` (ghost text) tanpa Neovim.

> Workspace awal — translate `completion_preview.lua` → `autoload/supermaven.vim` (render via `prop_add`), `api.start()` → `job_start`.

## Install

```vim
Plug 'jhonoryza/supermaven-vim'
```

```vim
:SupermavenAuth  " atau echo '{"apiKey":"sm-..."}' > ~/.config/supermaven/config.json
```

## Status

WIP — struktur dari `windsurf.vim` (Exafunction) dipakai sebagai template.

