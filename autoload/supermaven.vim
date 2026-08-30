let s:save_cpo = &cpo
set cpo&vim
let s:hlgroup = 'SupermavenSuggestion'
let s:request_nonce = 0
if !has('nvim') && empty(prop_type_get(s:hlgroup))
  call prop_type_add(s:hlgroup, {'highlight': s:hlgroup})
endif
" TODO: port completion_preview.lua -> prop_add ghost text (copy dari windsurf.vim s:RenderCurrentCompletion)
function! supermaven#Accept() abort
  " placeholder - akan diisi translate dari completion_preview.on_accept_suggestion
  return "\<Tab>"
endfunction
function! supermaven#Clear() abort
  if has('nvim')
    let ns = nvim_create_namespace('supermaven')
    call nvim_buf_clear_namespace(0, ns, 0, -1)
  else
    call prop_remove({'type': s:hlgroup, 'all': v:true})
  endif
  return ''
endfunction
function! supermaven#DebouncedComplete() abort
  call supermaven#Clear()
  if get(g:, 'supermaven_manual', v:false) | return | endif
  let delay = get(g:, 'supermaven_idle_delay', 75)
  let g:_supermaven_timer = timer_start(delay, {-> supermaven#Complete()})
endfunction
function! supermaven#Complete() abort
  " TODO: kirim document ke server via supermaven#server#Request
  call supermaven#log#Info('Complete placeholder - isi dari server.vim')
endfunction
function! supermaven#GetStatusString() abort
  return '...'
endfunction
let &cpo = s:save_cpo
