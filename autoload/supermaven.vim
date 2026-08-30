let s:save_cpo = &cpo
set cpo&vim
let s:hlgroup = 'SupermavenSuggestion'
let s:request_nonce = 0
let s:ghost_text = ''
let s:ghost_prior_delete = 0
if !has('nvim') && empty(prop_type_get(s:hlgroup))
  call prop_type_add(s:hlgroup, {'highlight': s:hlgroup})
endif

function! supermaven#Clear() abort
  let s:ghost_text = ''
  if has('nvim')
    try | call nvim_buf_clear_namespace(0, nvim_create_namespace('supermaven'), 0, -1) | catch | endtry
  else
    call prop_remove({'type': s:hlgroup, 'all': v:true})
  endif
  return ''
endfunction

function! supermaven#ShowGhost(text, prior_delete) abort
  call supermaven#Clear()
  let s:ghost_text = a:text
  let s:ghost_prior_delete = a:prior_delete
  if empty(a:text) | return | endif
  if mode() !~# '^[iR]' | return | endif
  let parts = split(a:text, "\n", 1)
  let first = remove(parts, 0)
  if has('nvim')
    let ns = nvim_create_namespace('supermaven')
    let opts = {'virt_text': [[first, s:hlgroup]], 'virt_text_win_col': virtcol('.')-1, 'hl_mode': 'combine'}
    if len(parts) > 0
      let opts.virt_lines = map(parts, {_,l -> [[l, s:hlgroup]]})
    endif
    call nvim_buf_set_extmark(0, ns, line('.')-1, col('.')-1, opts)
  else
    call prop_add(line('.'), col('.'), {'type': s:hlgroup, 'text': first})
    for line in parts
      if empty(line) | continue | endif
      call prop_add(line('.'), 0, {'type': s:hlgroup, 'text_align': 'below', 'text': line})
    endfor
  endif
endfunction

function! supermaven#Accept() abort
  if empty(s:ghost_text)
    return get(g:, 'supermaven_tab_fallback', "\<Tab>")
  endif
  let text = s:ghost_text
  call supermaven#Clear()
  let s:completion_text = text
  return "\<C-R>\<C-O>=supermaven#InsertText()\<CR>"
endfunction

function! supermaven#InsertText() abort
  try | return remove(s:, 'completion_text') | catch | return '' | endtry
endfunction

function! supermaven#DebouncedComplete() abort
  call supermaven#Clear()
  if get(g:, 'supermaven_manual', v:false) | return | endif
  if exists('g:_supermaven_timer') | call timer_stop(g:_supermaven_timer) | endif
  let delay = get(g:, 'supermaven_idle_delay', 75)
  let curbuf = bufnr('')
  let g:_supermaven_timer = timer_start(delay, {-> supermaven#Complete(curbuf)})
endfunction

function! s:ShouldIgnore() abort
  let ft = &filetype
  let ignore = get(g:, 'supermaven_ignore_filetypes', {})
  if type(ignore) == v:t_dict && has_key(ignore, ft) && ignore[ft]
    return v:true
  endif
  if type(ignore) == v:t_list && index(ignore, ft) >= 0
    return v:true
  endif
  if exists('g:SupermavenCondition') && type(g:SupermavenCondition) == v:t_func
    try | if call(g:SupermavenCondition, []) | return v:true | endif | catch | endtry
  endif
  if get(g:, 'SUPERMAVEN_DISABLED', 0) | return v:true | endif
  return v:false
endfunction

function! supermaven#Complete(...) abort
  if a:0 > 0 && a:1 != bufnr('') | return | endif
  if !get(g:, 'supermaven_enabled', v:true) | return | endif
  if s:ShouldIgnore() | call supermaven#Clear() | return | endif
  let buf = bufnr('%')
  let text = join(getbufline(buf, 1, '$'), "\n")
  let lnum = line('.')
  let col = col('.')
  let prefix = strpart(getline('.'), 0, col-1)
  call supermaven#server#SendBufferUpdate(buf, text, prefix, lnum, col)
endfunction

function! supermaven#OnCursorMoved() abort
  " mirror document_listener CursorMoved -> clear ghost if context changed
  if !empty(s:ghost_text) && mode() !~# '^[iR]'
    call supermaven#Clear()
  endif
endfunction

function! supermaven#UpdateHighlight() abort
  let color = get(g:, 'supermaven_suggestion_color', '#ffffff')
  let cterm = get(g:, 'supermaven_suggestion_cterm', 244)
  try
    if has('nvim')
      call nvim_set_hl(0, 'SupermavenSuggestion', {'fg': color, 'ctermfg': cterm})
    else
      exec 'hi SupermavenSuggestion guifg=' . color . ' ctermfg=' . cterm
    endif
  catch | endtry
endfunction

function! supermaven#GetStatusString() abort
  if empty(s:ghost_text) | return '   ' | endif
  return ' * '
endfunction
let &cpo = s:save_cpo
