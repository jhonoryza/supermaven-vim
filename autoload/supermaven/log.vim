let s:save_cpo = &cpo
set cpo&vim
let s:logfile = expand(get(g:, 'supermaven_log_file', tempname() . '-supermaven.log'))
function! supermaven#log#Info(msg) abort
  try | call writefile([a:msg], s:logfile, 'a') | catch | endtry
endfunction
let &cpo = s:save_cpo
