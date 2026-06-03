" Vim syntax file
" Language:    NAND2Tetris HDL ("The Elements of Computing Systems")
" Note:        The educational HDL from nand2tetris.org -- NOT VHDL/Verilog,
"              which happen to share the .hdl extension.

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Comments (C/Java style, as used by the course tools)
syn keyword hdlTodo    contained TODO FIXME XXX NOTE
syn region  hdlComment start="//" end="$"   contains=hdlTodo,@Spell
syn region  hdlComment start="/\*" end="\*/" contains=hdlTodo,@Spell

" Structure
syn keyword hdlStatement CHIP
syn keyword hdlSection   IN OUT PARTS BUILTIN CLOCKED

" Chip name in the declaration:  CHIP Foo {
syn match   hdlChipName  "\(\<CHIP\s\+\)\@<=\w\+"

" Constant buses
syn keyword hdlConstant  true false

" Numbers (bus widths and indices)
syn match   hdlNumber    "\<\d\+\>"

" Bus subscript:  a[0]  or  out[0..7]
syn match   hdlSubscript "\[\s*\d\+\s*\(\.\.\s*\d\+\s*\)\?\]"

" Part instantiation:  an UpperCamel name immediately before '('
syn match   hdlPart      "\<\u\w*\ze\s*("

" Pin name on the left of '='  (a=..., out=...)
syn match   hdlPin       "\<\w\+\ze\s*="

" Punctuation
syn match   hdlOperator  "[=,;]"

hi def link hdlComment   Comment
hi def link hdlTodo      Todo
hi def link hdlStatement Structure
hi def link hdlSection   Keyword
hi def link hdlChipName  Typedef
hi def link hdlConstant  Boolean
hi def link hdlNumber    Number
hi def link hdlSubscript Special
hi def link hdlPart      Function
hi def link hdlPin       Identifier
hi def link hdlOperator  Operator

let b:current_syntax = "hdl"

let &cpo = s:cpo_save
unlet s:cpo_save
