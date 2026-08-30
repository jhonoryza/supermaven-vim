let s:save_cpo = &cpo
set cpo&vim
let s:defaults = {
      \ 'keymaps': {'accept_suggestion': '<Tab>', 'clear_suggestion': '<C-]>', 'accept_word': '<C-j>'},
      \ 'ignore_filetypes': {},
      \ 'disable_inline_completion': v:false,
      \ 'disable_keymaps': v:false,
      \ 'log_level': 'info',
      \ }
let s:config = deepcopy(s:defaults)
function! supermaven#config#Setup(args) abort
  let s:config = extend(deepcopy(s:defaults), get(a:args, 0, {}), 'force')
endfunction
function! supermaven#config#Get(key) abort
  return get(s:config, a:key, get(s:defaults, a:key, v:null))
endfunction
let &cpo = s:save_cpo
