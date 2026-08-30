let s:save_cpo = &cpo
set cpo&vim
function! supermaven#util#Trim(s) abort
  return trim(a:s)
endfunction
function! supermaven#util#TrimEnd(s) abort
  return substitute(a:s, '\s\+$', '', '')
endfunction
function! supermaven#util#TrimStart(s) abort
  return substitute(a:s, '^\s*', '', '')
endfunction
function! supermaven#util#IsWhitespace(c) abort
  return a:c ==# ' ' || a:c ==# "\t" || a:c ==# "\n" || a:c ==# "\r"
endfunction
function! supermaven#util#Contains(a,b) abort
  return stridx(a:a, a:b) >= 0
endfunction
function! supermaven#util#GetText(bufnr) abort
  return join(getbufline(a:bufnr, 1, '$'), "\n")
endfunction
let &cpo = s:save_cpo
