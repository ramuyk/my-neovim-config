"* folding

" Debug message to confirm sourcing
echom "Sourcing folding.vim"

function! MyFoldExpr()
  " Try to extract the comment character from 'commentstring'
  let commentChar = substitute(&commentstring, '%s.*', '', '')

  " Fallback for specific filesyntax
  if &filetype == 'python' || &filetype == 'sh' || &filetype == 'yaml' || &filetype == 'nginx' || &filetype == 'dockerfile' || &filetype == 'r' || &filetype == 'apache' || &filetype == 'conf'
    let commentChar = '#'
  elseif &filetype == 'javascript'
    let commentChar = '//'
  elseif &filetype == 'lua'
    let commentChar = '--'
  elseif &filetype == 'lisp'
    let commentChar = ';;'
  elseif &filetype == 'vim'
    let commentChar = '"'
  endif

  " Build the fold start pattern
  let spacePattern = '"^\\s*"'
  let escapedCommentChar = '"' . escape(commentChar, '\\') . '"'
  let asteriskPattern = '"\\*\\+"'
  let foldStartPattern = spacePattern . '.' . escapedCommentChar . '.' . asteriskPattern

  " Check if the current line starts with the fold pattern
  if getline(v:lnum) =~ eval(foldStartPattern)
    return '>1'
  " Check if the next line also starts with the same pattern, end the current fold
  elseif getline(v:lnum + 1) =~ eval(foldStartPattern)
    return '<1'
  else
    " Continue the fold for other lines
    return '='
  endif
endfunction

set foldmethod=expr
set foldexpr=MyFoldExpr()
set foldlevelstart=1
set foldenable

function! UpdateAndFold()
  normal! zx
  normal! zM
endfunction

function! UpdateAndUnfold()
  normal! zx
  normal! zR
endfunction

function! KillBuffer()
  bd!
endfunction

function! ToggleFold()
  " Get the current line number
  let currentLine = line('.')

  " Check if the current line is within a closed fold
  if foldclosed(currentLine) != -1
    " If in a closed fold, open the fold at the cursor
    normal! zo
  else
    " If not in a closed fold, close the fold at the cursor
    normal! zc
  endif
endfunction

nnoremap zfa :call UpdateAndFold()<CR>
nnoremap zfu :call UpdateAndUnfold()<CR>
nnoremap <Tab> :call ToggleFold()<CR>

