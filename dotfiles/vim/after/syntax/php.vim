" adds spelling check to PHP comments
syn clear phpComment
if exists("php_parent_error_open")
  syn region phpComment start="/\*" end="\*/" contained contains=phpTodo,@Spell
else
  syn region phpComment start="/\*" end="\*/" contained contains=phpTodo,@Spell extend
endif
syn match phpComment  "#.\{-}\(?>\|$\)\@="  contained contains=phpTodo,@Spell
syn match phpComment  "//.\{-}\(?>\|$\)\@=" contained contains=phpTodo,@Spell

" this seems to bork syntax highlighting, so add a fixup key
" http://stackoverflow.com/a/15164215/2908724
noremap <F2> <Esc>:syntax sync fromstart<CR>
inoremap <F2> <C-o>:syntax sync fromstart<CR>

" annotation highlights 
if !exists('g:php_annotations_syntax') || g:php_annotations_syntax != 0
  syn match phpDocCommentLineStart #\v^\s*\*\s*# contained
  syn region phpAnnotationString start=#"# skip=#\v\\"# end=#"# contained
  syn region phpAnnotationSimpleString start=#'# skip=#\v\\'# end=#'# contained
  syn match phpAnnotationNumber #\v[0-9.]+# contained
  syn match phpAnnotationGrouping #\v[],=[(){}@$><!]# contained
  syn region phpAnnotationExpressionParenthesis start=#\V(# end=#\V)# contained contains=phpAnnotationExpressionParenthesis, phpAnnotationExpressionBraces, phpAnnotationExpressionBrackets, phpDocCommentLineStart, phpAnnotationString, phpAnnotationSimpleString, phpAnnotationNumber, phpAnnotationGrouping
  syn region phpAnnotationExpressionBraces start=#\V{# end=#\V}# contained contains=phpAnnotationExpressionParenthesis, phpAnnotationExpressionBraces, phpAnnotationExpressionBrackets, phpDocCommentLineStart, phpAnnotationString, phpAnnotationSimpleString, phpAnnotationNumber, phpAnnotationGrouping
  syn region phpAnnotationExpressionBrackets start=#\V[# end=#\V]# contained contains=phpAnnotationExpressionParenthesis, phpAnnotationExpressionBraces, phpAnnotationExpressionBrackets, phpDocCommentLineStart, phpAnnotationString, phpAnnotationSimpleString, phpAnnotationNumber, phpAnnotationGrouping
  syn region phpAnnotation start=#\v^\s*\*?\s*\zs\@# start=#\v/\*\*\s*\zs\@# end=#$# contained contains=phpAnnotationExpressionParenthesis, phpAnnotationExpressionBraces, phpAnnotationExpressionBrackets, phpAnnotationString, phpAnnotationSimpleString, phpAnnotationNumber, phpAnnotationGrouping
  syn region phpDocComment start=#\v/\*\*# end=#\v\ze\*/# containedin=phpComment contains=phpAnnotation keepend

  highlight link phpDocCommentLineStart Comment
  highlight link phpAnnotationGrouping Operator
  highlight link phpAnnotationNumber Number
  highlight link phpAnnotationString String
  highlight link phpAnnotationSimpleString String
  highlight link phpAnnotationExpressionParenthesis SpecialComment
  highlight link phpAnnotationExpressionBraces SpecialComment
  highlight link phpAnnotationExpressionBrackets SpecialComment
  highlight link phpAnnotation SpecialComment
  highlight link phpDocComment Comment
endif
