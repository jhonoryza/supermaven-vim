let s:save_cpo = &cpo
set cpo&vim
" Simplified port of textual.lua - hanya handle text + dedent + delete, skip complex dust
function! supermaven#textual#DeriveCompletion(completion, params) abort
  let output = ''
  let dedent = ''
  for item in a:completion
    let kind = get(item, 'kind', '')
    if kind ==# 'text'
      let output .= get(item, 'text', '')
    elseif kind ==# 'dedent'
      let dedent .= get(item, 'text', '')
    elseif kind ==# 'delete' || kind ==# 'skip' || kind ==# 'jump'
      " untuk minimal, ignore - akan di-handle di server
      continue
    elseif kind ==# 'end' || kind ==# 'barrier'
      break
    endif
  endfor
  let output = substitute(output, '\s\+$', '', '')
  if empty(trim(output)) | return v:null | endif
  " simple dedent handling
  if !empty(dedent) && stridx(a:params.line_before_cursor, dedent) < 0
    return v:null
  endif
  return {'kind':'text','text':output,'dedent':dedent,'is_incomplete':v:false}
endfunction
let &cpo = s:save_cpo
