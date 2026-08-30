let s:save_cpo = &cpo
set cpo&vim
let s:logfile = expand(get(g:, 'supermaven_log_file', tempname() . '-supermaven.log'))
let s:level_map = {'off':0,'trace':1,'debug':2,'info':3,'warn':4,'error':5}
function! supermaven#log#GetLogfile() abort
  return s:logfile
endfunction
function! s:ShouldLog(level) abort
  let cur = toupper(get(g:, 'supermaven_log_level', 'info'))
  let l = get(s:level_map, tolower(a:level), 3)
  let c = get(s:level_map, tolower(cur), 3)
  return l >= c
endfunction
function! supermaven#log#Log(level, msg) abort
  try | call writefile([printf('[%-6s %s] %s', toupper(a:level), strftime('%c'), a:msg)], s:logfile, 'a') | catch | endtry
  if s:ShouldLog(a:level)
    echomsg '[supermaven] ' . a:msg
  endif
endfunction
function! supermaven#log#Info(msg) abort
  call supermaven#log#Log('info', a:msg)
endfunction
function! supermaven#log#Warn(msg) abort
  call supermaven#log#Log('warn', a:msg)
endfunction
function! supermaven#log#Error(msg) abort
  call supermaven#log#Log('error', a:msg)
endfunction
function! supermaven#log#Debug(msg) abort
  call supermaven#log#Log('debug', a:msg)
endfunction
function! supermaven#log#Trace(msg) abort
  call supermaven#log#Log('trace', a:msg)
endfunction
function! supermaven#log#Show() abort
  exe 'tabnew ' . fnameescape(s:logfile)
endfunction
let &cpo = s:save_cpo
