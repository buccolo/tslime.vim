" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Function to send keys to tmux
" useful if you want to stop some command with <c-c> in tmux.
function! Send_keys_to_Tmux(keys)
  if !exists("g:tslime") || s:PaneExists(g:tslime['pane'])
    call <SID>Tmux_Vars()
  endif

  call system("tmux send-keys -t " . s:tmux_target() . " " . a:keys)
endfunction

" Main function.
" Use it in your script if you want to send text to a tmux pane.
function! Send_to_Tmux(text)
  if !exists("g:tslime") || s:PaneExists(g:tslime['pane'])
    call <SID>Tmux_Vars()
  endif

  call <SID>set_tmux_buffer(a:text)
  call system("tmux paste-buffer -t " . s:tmux_target())
  call system("tmux delete-buffer")
endfunction

function! s:tmux_target()
  return g:tslime['pane']
endfunction

function! s:set_tmux_buffer(text)
  let buf = substitute(a:text, "'", "\\'", 'g')
  call system("tmux load-buffer -", buf)
endfunction

function! SendToTmux(text)
  call Send_to_Tmux(a:text)
endfunction

function! s:CreateTmuxPane()
  call system("tmux splitw -h")
  return system("tmux list-panes | grep active | sed -e 's/:.*$//'")
endfunction

function! s:PaneExists(index)
  let panes = system("tmux list-panes | sed -e 's/:.*$//' | grep " . a:index)
  return (panes == (a:index . "\n")) == 0
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let g:tslime = {}
  let panes = split(s:CreateTmuxPane(), "\n")
  let g:tslime['pane'] = panes[0]
endfunction

vmap <unique> <Plug>SendSelectionToTmux "ry :call Send_to_Tmux(@r)<CR>
nmap <unique> <Plug>NormalModeSendToTmux vip <Plug>SendSelectionToTmux

nmap <unique> <Plug>SetTmuxVars :call <SID>Tmux_Vars()<CR>

command! -nargs=* Tmux call Send_to_Tmux('<Args><CR>')
