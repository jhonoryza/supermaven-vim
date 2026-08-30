let s:save_cpo = &cpo
set cpo&vim
let s:job = v:null
let s:channel = v:null
let s:buffer = ''
let s:state_map = {}
let s:current_id = 0

function! s:BinaryPath() abort
  let data_home = $XDG_DATA_HOME !=# '' ? $XDG_DATA_HOME . '/supermaven' : $HOME . '/.supermaven'
  let os = substitute(system('uname'), '\n', '', '')
  let arch = substitute(system('uname -m'), '\n', '', '')
  let platform = os ==# 'Darwin' ? 'macosx' : os ==# 'Linux' ? 'linux' : 'windows'
  let arch2 = arch =~# 'arm' ? 'aarch64' : 'x86_64'
  let dir = data_home . '/binary/v20/' . platform . '-' . arch2
  let bin = dir . (platform ==# 'windows' ? '/sm-agent.exe' : '/sm-agent')
  if filereadable(bin)
    return bin
  endif
  call mkdir(dir, 'p')
  let url = system('curl -s "https://supermaven.com/api/download-path-v2?platform=' . platform . '&arch=' . arch2 . '&editor=neovim"')
  try
    let j = json_decode(url)
    let dl = get(j, 'downloadUrl', '')
    if empty(dl)
      call supermaven#log#Info('Gagal dapat URL supermaven')
      return ''
    endif
    call supermaven#log#Info('Downloading supermaven binary...')
    call system('curl -o ' . shellescape(bin) . ' -L ' . shellescape(dl))
    call system('chmod +x ' . shellescape(bin))
    return bin
  catch
    return ''
  endtry
endfunction

function! s:OnOut(channel, msg) abort
  let s:buffer .= a:msg
  while 1
    let idx = stridx(s:buffer, "\n")
    if idx < 0 | break | endif
    let line = strpart(s:buffer, 0, idx)
    let s:buffer = strpart(s:buffer, idx+1)
    call s:ProcessLine(line)
  endwhile
endfunction

function! s:ProcessLine(line) abort
  if strpart(a:line, 0, 11) ==# 'SM-MESSAGE '
    let j = json_decode(strpart(a:line, 11))
    call s:HandleMessage(j)
  endif
endfunction

function! s:HandleMessage(msg) abort
  if get(a:msg, 'kind', '') ==# 'response'
    let id = str2nr(get(a:msg, 'stateId', '0'))
    if has_key(s:state_map, id)
      for item in get(a:msg, 'items', [])
        call add(s:state_map[id].completion, item)
      endfor
      let comp = s:state_map[id].completion
      if !empty(comp)
        let params = {'line_before_cursor': getline('.')[:col('.')-2], 'line_after_cursor': getline('.')[col('.')-1:], 'dust_strings': [], 'can_retry': v:true, 'can_show_partial_line': v:true}
        let derived = supermaven#textual#DeriveCompletion(comp, params)
        if type(derived) == v:t_dict && has_key(derived, 'text') && !empty(derived.text)
          call supermaven#ShowGhost(derived.text, len(get(derived, 'dedent', '')))
        else
          " fallback simple
          let txt = ''
          for it in comp | if get(it,'kind','')=='text' | let txt .= get(it,'text','') | endif | endfor
          if !empty(txt) | call supermaven#ShowGhost(txt, 0) | endif
        endif
      endif
    endif
  elseif get(a:msg, 'kind', '') ==# 'service_tier'
    call supermaven#log#Info('Supermaven tier: ' . get(a:msg, 'display', ''))
  endif
endfunction

function! supermaven#server#SendBufferUpdate(buf, text, prefix, lnum, col) abort
  let path = fnamemodify(bufname(a:buf), ':p')
  if empty(path) | let path = 'file:///tmp/untitled' | endif
  let offset = len(a:prefix)
  let updates = [
        \ {'kind':'cursor_update','path':path,'offset':offset},
        \ {'kind':'file_update','path':path,'content':a:text},
        \ ]
  return supermaven#server#SendStateUpdate(updates)
endfunction

function! supermaven#server#Start() abort
  if s:job isnot v:null && job_status(s:job) ==# 'run'
    return
  endif
  let bin = s:BinaryPath()
  if empty(bin) || !filereadable(bin)
    call supermaven#log#Info('Binary supermaven tidak ditemukan')
    return
  endif
  let s:job = job_start([bin, 'stdio'], {
        \ 'in_mode': 'raw',
        \ 'out_mode': 'raw',
        \ 'out_cb': function('s:OnOut'),
        \ 'err_cb': {ch,msg -> supermaven#log#Info('[SM] '.msg)},
        \ })
  let s:channel = job_getchannel(s:job)
  call ch_sendraw(s:channel, json_encode({'kind':'greeting','allowGitignore':v:false}) . "\n")
  let g:supermaven_job = s:job
  call supermaven#log#Info('Supermaven started: ' . bin)
endfunction

function! supermaven#server#Stop() abort
  if s:job isnot v:null
    try | call job_stop(s:job) | catch | endtry
    let s:job = v:null
  endif
endfunction

function! supermaven#server#SendStateUpdate(updates) abort
  if s:channel is v:null | return | endif
  let s:current_id += 1
  let msg = {'kind':'state_update','newId':string(s:current_id),'updates':a:updates}
  let s:state_map[s:current_id] = {'prefix':'','completion':[]}
  call ch_sendraw(s:channel, json_encode(msg) . "\n")
  return s:current_id
endfunction

let &cpo = s:save_cpo
