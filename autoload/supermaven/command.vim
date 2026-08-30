let s:save_cpo = &cpo
set cpo&vim
let s:commands = {}
function! supermaven#command#Command(arg) abort
  return 'echo "SupermavenAuth placeholder"'
endfunction
let &cpo = s:save_cpo
