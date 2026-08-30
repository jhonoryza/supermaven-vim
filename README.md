# supermaven-vim

Supermaven untuk Vim 9 (port dari [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) Lua → Vimscript). Ghost text via `prop`/`extmark`, tanpa Neovim.

> Translate: `completion_preview.lua` → `autoload/supermaven.vim` (`prop_add`), `binary_handler.lua` → `autoload/supermaven/server.vim` (`job_start` stdio `SM-MESSAGE`), `document_listener` → `plugin/supermaven.vim` autocmd.

## Install

```vim
" vim-plug
Plug 'jhonoryza/supermaven-vim'

" atau manual
git clone https://github.com/jhonoryza/supermaven-vim ~/.vim/pack/supermaven/start/supermaven-vim
```

Neovim tetap bisa pakai `supermaven-nvim` asli, tapi `supermaven-vim` juga jalan di Neovim (pakai `nvim_buf_set_extmark`).

## Auth

```bash
mkdir -p ~/.config/supermaven
echo '{"apiKey":"sm-..."}' > ~/.config/supermaven/config.json
# atau
:SupermavenAuth sm-xxxx
```

Atau pakai `:SupermavenUseFree` / `:SupermavenUsePro` untuk aktivasi via browser.

## Keymap

```vim
" default (bisa disable g:supermaven_disable_bindings=1)
imap <Tab>   <Plug>(supermaven-accept)   " Terima saran
imap <C-]>   <Plug>(supermaven-clear)    " Hapus
imap <C-j>   <Plug>(supermaven-accept-word) " Terima 1 kata (via supermaven#AcceptNextWord)
```

Custom:
```vim
let g:supermaven_disable_bindings = 1
imap <C-g> <Plug>(supermaven-accept)
```

## Config

```vim
let g:supermaven_ignore_filetypes = {'cpp': v:true}  " atau ["cpp"]
let g:supermaven_manual = v:true  " hanya trigger manual
let g:supermaven_idle_delay = 75
let g:supermaven_suggestion_color = "#ffffff"
let g:supermaven_suggestion_cterm = 244
" condition: return v:true untuk disable di file tertentu
let g:SupermavenCondition = {-> expand('%:t') =~# 'foo.sh'}

" statusline
set statusline+=%{supermaven#GetStatusString()}
```

## Commands

```
:SupermavenStart / Stop / Restart / Toggle / Status
:SupermavenUseFree / UsePro / Logout
:SupermavenShowLog / ClearLog
:SupermavenAuth
```

Log di `tempname()-supermaven.log` atau `:SupermavenShowLog`.

## nvim-cmp (Opsional, Neovim)

Jika pakai `hrsh7th/nvim-cmp`, source `supermaven` otomatis terdaftar (port dari `cmp.lua`). Tambah di `cmp.setup`:

```lua
cmp.setup { sources = {{ name = "supermaven" }} }
-- highlight
vim.api.nvim_set_hl(0, "CmpItemKindSupermaven", {fg="#6CC644"})
```

Untuk Vim 9, `cmp` tidak perlu — cukup inline ghost text.

## Cara Kerja (Vim vs Neovim)

| nvim (Lua) | Vim (Vimscript) |
|---|---|
| `vim.uv.spawn("sm-agent","stdio")` | `job_start([bin,"stdio"], {out_cb:...})` |
| `nvim_buf_set_extmark(virt_text)` | `prop_add(virt_text)` / `nvim_buf_set_extmark` jika `has('nvim')` |
| `vim.json.encode` | `json_encode` |

Binary di `~/.supermaven/binary/v20/<platform>-<arch>/sm-agent` (auto download via `https://supermaven.com/api/download-path-v2`).

## License

MIT — sama seperti `supermaven-nvim`.
