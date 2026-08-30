let s:save_cpo = &cpo
set cpo&vim
let s:server_port = v:null
function! supermaven#server#Start() abort
  " TODO: job_start binary supermaven, mirip windsurf server.vim
  call supermaven#log#Info('server Start placeholder')
endfunction
function! supermaven#server#Stop() abort
  if exists('g:supermaven_job') && g:supermaven_job isnot v:null
    if has('nvim') | call jobstop(g:supermaven_job) | else | call job_stop(g:supermaven_job) | endif
  endif
endfunction
let &cpo = s:save_cpo
