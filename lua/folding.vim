"* folding

" Debug message to confirm sourcing
echom "Sourcing folding.vim"

function! MyFoldExpr()
  " Try to extract the comment character from 'commentstring'
  let commentChar = substitute(&commentstring, '%s.*', '', '')

  " Fallback for specific filesyntax
  if &filetype == 'python' || &filetype == 'sh' || &filetype == 'yaml' || &filetype == 'nginx' || &filetype == 'dockerfile' || &filetype == 'r' || &filetype == 'apache' || &filetype == 'conf' || &filetype == 'tmux'
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

"* narrow
let g:originalFoldRange = {}
function! OpenFoldInNewBuffer()
  normal! zx
  normal! zM
  let foldStart = foldclosed('.')
  let foldEnd = foldclosedend('.')
  
  if foldStart == -1 || foldEnd == -1
    echo "Not in a fold"
    return
  endif

  " Store original buffer number and fold range
  let g:originalFoldRange = {'bufnr': bufnr('%'), 'start': foldStart, 'end': foldEnd}

  let currentFileType = &filetype
  silent execute foldStart . ',' . foldEnd . 'yank'
  enew
  execute 'setlocal filetype=' . currentFileType
  0put
  normal! Gddgg
  if line('$') > 1
    execute '1delete'
  endif
endfunction

nnoremap zn :call OpenFoldInNewBuffer()<CR>

"* widen
function! ReplaceFoldContent()
  " Check if 'g:originalFoldRange' exists and if the current buffer has no associated file
  if !exists('g:originalFoldRange') || bufname('%') != ''
    echo "This command can only be executed in a temporary buffer opened by zn"
    return
  endif

  " Enable hiding buffers with unsaved changes
  set hidden

  " Store the edited content from the temporary buffer
  let editedContent = getline(1, '$')

  " Switch to the original buffer
  execute 'buffer' . g:originalFoldRange.bufnr

  " Delete the old content inside the fold, excluding the fold start line
  if g:originalFoldRange.start < g:originalFoldRange.end
    execute (g:originalFoldRange.start + 1) . ',' . g:originalFoldRange.end . 'delete'
  endif

  " Insert the new content after the fold start line
  call append(g:originalFoldRange.start, editedContent)

  " Close the temporary buffer
  let tempBufferNr = bufnr('#')
  execute 'bdelete! ' . tempBufferNr

  " Move cursor to the start of the fold that was edited
  execute g:originalFoldRange.start

  " Reapply folding and open the current fold if it exists
  normal! zx
  normal! zM
  normal! zo
endfunction

nnoremap zu :call ReplaceFoldContent()<CR>

