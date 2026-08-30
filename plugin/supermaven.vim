if exists('g:loaded_supermaven')
  finish
endif
let g:loaded_supermaven = 1

command! -nargs=? SupermavenAuth exe supermaven#command#Command(<q-args>)
command! SupermavenStart call supermaven#server#Start()
command! SupermavenStop call supermaven#server#Stop()
command! SupermavenStatus echo supermaven#GetStatusString()
command! SupermavenClear call supermaven#Clear()

augroup supermaven
  autocmd!
  autocmd InsertEnter,CursorMovedI,CompleteChanged * call supermaven#DebouncedComplete()
  autocmd InsertLeave,BufLeave * call supermaven#Clear()
  autocmd VimLeave * call supermaven#server#Stop()
augroup END

imap <Plug>(supermaven-accept) <Cmd>call supermaven#Accept()<CR>
imap <Plug>(supermaven-clear) <Cmd>call supermaven#Clear()<CR>
if !get(g:, 'supermaven_disable_bindings', v:false)
  imap <Tab> <Plug>(supermaven-accept)
  imap <C-]> <Plug>(supermaven-clear)
endif
