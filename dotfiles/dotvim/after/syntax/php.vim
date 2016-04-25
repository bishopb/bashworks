" adds spelling check to PHP comments
syn clear phpComment
if exists("php_parent_error_open")
  syn region phpComment start="/\*" end="\*/" contained contains=phpTodo,@Spell
else
  syn region phpComment start="/\*" end="\*/" contained contains=phpTodo,@Spell extend
endif
syn match phpComment  "#.\{-}\(?>\|$\)\@="  contained contains=phpTodo,@Spell
syn match phpComment  "//.\{-}\(?>\|$\)\@=" contained contains=phpTodo,@Spell
