# supermaven-vim

Supermaven untuk Vim 9 (port dari [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) Lua → Vimscript). Ghost via `prop` (Vim) / `extmark` (Neovim), `job` stdio `SM-MESSAGE`, tanpa Neovim.

> Translate: `completion_preview` → `prop_add`, `binary_handler` → `job_start`, `document_listener` → autocmd. Lihat [tulisan lengkap](https://jhonoryza.github.io/tulisan/14-cara-install-supermaven-di-vim.html).

## Prasyarat

```bash
vim --version | head -n1  # 9.0+
git --version
```

## Install

```vim
" vim-plug (Vim/Neovim)
Plug 'jhonoryza/supermaven-vim'
:PlugInstall

" manual Vim
git clone https://github.com/jhonoryza/supermaven-vim ~/.vim/pack/supermaven/start/supermaven-vim
" manual Neovim
git clone https://github.com/jhonoryza/supermaven-vim ~/.local/share/nvim/site/pack/supermaven/start/supermaven-vim
```

Binary `sm-agent` auto-download ke `~/.supermaven/binary/v20/<platform>-<arch>/sm-agent` via `https://supermaven.com/api/download-path-v2`.

## Auth

```bash
# Free Tier (buka popup aktivasi)
:SupermavenUseFree
# atau Pro
:SupermavenUsePro
# atau API key manual
mkdir -p ~/.config/supermaven
echo '{"apiKey":"sm-..."}' > ~/.config/supermaven/config.json
:SupermavenAuth sm-xxxx
```

Cek:
```vim
:SupermavenStatus
:SupermavenShowLog
```

## Keymap

Default `Tab` / `C-]` / `C-j`. Biar tidak bentrok Windsurf (`Ctrl`), pakai `Alt`:

```vim
let g:supermaven_disable_bindings = 1
imap <M-g> <Plug>(supermaven-accept)        " terima semua
imap <M-]> <Plug>(supermaven-clear)         " hapus
imap <M-j> <Cmd>call supermaven#Accept()<CR> " terima 1 kata
imap <M-Space> <Cmd>call supermaven#Complete()<CR> " trigger manual
```

Atau pakai `Ctrl` kalau Codeium off:
```vim
imap <C-g> <Plug>(supermaven-accept)
imap <C-Space> <Cmd>call supermaven#Complete()<CR>
```

## Config

```vim
let g:supermaven_ignore_filetypes = {'cpp': v:true}
let g:supermaven_manual = v:true
let g:supermaven_idle_delay = 75
let g:supermaven_suggestion_color = "#ffffff"
let g:supermaven_suggestion_cterm = 244
let g:SupermavenCondition = {-> expand('%:t') =~# 'foo.sh'}
set statusline+=%{supermaven#GetStatusString()}
```

## Commands

```
:SupermavenStart / Stop / Restart / Toggle / Status
:SupermavenUseFree / UsePro / Logout
:SupermavenShowLog / ClearLog / Auth
```

## nvim-cmp (Neovim)

```lua
cmp.setup { sources = {{ name = "supermaven" }} }
vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {fg="#6CC644"})
```

Vim 9 cukup inline ghost, tidak perlu `cmp`.

## Cara Kerja

| nvim | Vim |
|---|---|
| `vim.uv.spawn("sm-agent","stdio")` | `job_start([bin,"stdio"])` |
| `nvim_buf_set_extmark` | `prop_add` |
| `vim.json.encode` | `json_encode` |

## License

MIT
