if exists('g:loaded_supermaven')
  finish
endif
let g:loaded_supermaven = 1

command! -nargs=? SupermavenAuth exe supermaven#command#Command(<q-args>)
command! SupermavenStart call supermaven#server#Start()
command! SupermavenStop call supermaven#server#Stop()
command! SupermavenRestart call supermaven#server#Restart()
command! SupermavenToggle call supermaven#server#Toggle()
command! SupermavenStatus echo supermaven#server#IsRunning() ? 'Supermaven running' : 'Supermaven not running'
command! SupermavenClear call supermaven#Clear()
command! SupermavenUseFree call supermaven#server#UseFree()
command! SupermavenUsePro call supermaven#server#UsePro()
command! SupermavenLogout call supermaven#server#Logout()
command! SupermavenShowLog call supermaven#log#Show()
command! SupermavenClearLog call supermaven#log#Clear()

augroup supermaven
  autocmd!
  autocmd InsertEnter,CursorMovedI,CompleteChanged,TextChanged,TextChangedI,TextChangedP * call supermaven#DebouncedComplete()
  autocmd CursorMoved,CursorMovedI * call supermaven#OnCursorMoved()
  autocmd InsertLeave,BufLeave * call supermaven#Clear()
  autocmd VimLeave * call supermaven#server#Stop()
  autocmd BufEnter * if get(g:, 'supermaven_enabled', v:true) | call supermaven#server#Start() | endif
  autocmd ColorScheme,VimEnter * call supermaven#UpdateHighlight()
augroup END

imap <Plug>(supermaven-accept) <Cmd>call supermaven#Accept()<CR>
imap <Plug>(supermaven-clear) <Cmd>call supermaven#Clear()<CR>
if !get(g:, 'supermaven_disable_bindings', v:false)
  imap <Tab> <Plug>(supermaven-accept)
  imap <C-]> <Plug>(supermaven-clear)
endif
