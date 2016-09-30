augroup filetypedetect
au BufNewFile,BufRead *.xt setf xt
au BufRead,BufNewFile *.twig call s:Setf(expand('<amatch>'))
augroup END

" https://github.com/lumiliet/vim-twig/blob/master/filetype.vim
function! s:Setf(filename)
  let prefix = (&verbose < 8) ? 'silent!' : ''
  let ei_save = &eventignore
  set eventignore=FileType
  try
    let basefile = fnamemodify(a:filename, ':r')
    execute prefix 'doau BufRead' basefile
  finally
    let &eventignore = ei_save
  endtry
  if !strlen(&ft)
    let ft = 'html.twig'
  else
    let ft = &ft . (&ft =~ '\<twig\>' ? '' : '.twig')
  endif
  execute prefix 'set filetype=' . ft
endfun
