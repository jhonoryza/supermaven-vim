# supermaven-vim

Supermaven for Vim 9 — port of [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim) from Lua to Vimscript. Ghost text via `prop` (Vim) / `extmark` (Neovim), `job` stdio `SM-MESSAGE`, no Neovim required.

> Translation: `completion_preview.lua` → `autoload/supermaven.vim` (`prop_add`), `binary_handler.lua` → `autoload/supermaven/server.vim` (`job_start` stdio), `document_listener` → `plugin/supermaven.vim` autocmd. See full guide in [tulisan](https://jhonoryza.github.io/tulisan/14-cara-install-supermaven-di-vim.html).

## Requirements

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

Binary `sm-agent` auto-downloads to `~/.supermaven/binary/v20/<platform>-<arch>/sm-agent` via `https://supermaven.com/api/download-path-v2`.

## Authentication

```bash
# Free Tier (opens activation popup)
:SupermavenUseFree
# or Pro
:SupermavenUsePro
# or API key manually
mkdir -p ~/.config/supermaven
echo '{"apiKey":"sm-..."}' > ~/.config/supermaven/config.json
:SupermavenAuth sm-xxxx
```

Check:
```vim
:SupermavenStatus
:SupermavenShowLog
```

## Keymaps

Default `Tab` / `C-]` / `C-j`. To avoid conflict with Windsurf (`Ctrl`), use `Alt`:

```vim
let g:supermaven_disable_bindings = 1
imap <M-g> <Plug>(supermaven-accept)        " accept all
imap <M-]> <Plug>(supermaven-clear)         " clear
imap <M-j> <Cmd>call supermaven#Accept()<CR> " accept word
imap <M-Space> <Cmd>call supermaven#Complete()<CR> " trigger manually
```

Or use `Ctrl` if Codeium is disabled:
```vim
imap <C-g> <Plug>(supermaven-accept)
imap <C-Space> <Cmd>call supermaven#Complete()<CR>
```

## Configuration

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

For Vim 9, inline ghost text is enough — no `cmp` needed.

## How it Works

| Neovim (Lua) | Vim (Vimscript) |
|---|---|
| `vim.uv.spawn("sm-agent","stdio")` | `job_start([bin,"stdio"])` |
| `nvim_buf_set_extmark` | `prop_add` |
| `vim.json.encode` | `json_encode` |

## License

MIT — same as `supermaven-nvim`.
