" Vim syntax file
" Language: Customasm Assembler
" Last Change: 2024 Jan 26

" quit when a syntax file was already loaded
if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn case ignore
" ***Later matches take precedence over previous ones.***


" Consider $ and . a letter (part of a word)
setlocal iskeyword+=$,.

" account for fact that identifier may be a local label
" \= : ? in PCRE
syn match asmIdentifier "\<\.*[a-zA-Z_][a-zA-Z0-9_]*\(\.[a-zA-Z_][a-zA-Z0-9_]*\)*\>"

" he=e-1 => offset end of highlighting by -1 (do not highlight colon);
" also allow for 0 or more periods ('.') for local labels
syn match asmLabel "^\s*\zs\.*[a-zA-Z_][a-zA-Z0-9_]\{-}:"he=e-1 

syn match asmPc "\<\(\$\|pc\)\>"

" integer literals, accounting for underscores to split digits
" also, $ and % aren't part of a word
" see https://vimdoc.sourceforge.net/htmldoc/pattern.html#/magic
syn match asmDecimal "\<[0-9]\+\(_\+[0-9]\+\)*\>" display
syn match asmOctal "\<0o\(_*[0-7]\+\)\+\>" display
syn match asmHexadecimal "\(\<0x\|\$\)\(_*[0-9A-Fa-f]\+\)\+\>" display
syn match asmBinary "\(\<0b\|%\)\(_*[01]\+\)\+\>" display

" Allow all characters to be escaped (and in strings)
syn match asmCharacterEscape "\\." contained
syn match asmCharacter "'\\\=." contains=asmCharacterEscape

syn match asmStringEscape "\\\_." contained
syn match asmStringEscape "\\\%(\o\{3}\|00[89]\)" contained display
syn match asmStringEscape "\\x\x\+" contained display

syn region asmString start="\"" end="\"" contains=asmStringEscape


syn keyword asmTodo contained TODO FIXME XXX NOTE

" Customasm uses ";*" as a multi-line comment start delimiter.
syn region asmBlockComment start=";\*" end="\*;" contains=asmTodo,@Spell

" Customasm uses ";" as a single-line comment start delimiter. Make sure a '*' isn't present after the ';'.
syn match asmComment ";[^\*].*" contains=asmEmptyComment,asmTodo,@Spell
" Take care of a ";" at the end of a line (in which case there is no "[^\*]" afterwards):
syn match asmEmptyComment ";$" contains=asmTodo,@Spell

" Assembler directives start with a '#' and may contain upper case
syn match asmDirective "^\s*\zs#[A-Za-z][0-9A-Za-z\-_]*\>"

syn match asmType "^\s*\zs#d[0-9]\{-}\>" " match #d, #d8, #d16, non greedy number


syn case match

" Define the default highlighting.
" Only when an item doesn't have highlighting yet

" The default methods for highlighting. Can be overridden later
hi def link asmLabel Label
hi def link asmIdentifier Identifier

hi def link asmPc Keyword

hi def link asmBlockComment Comment
hi def link asmComment Comment
hi def link asmEmptyComment Comment

hi def link asmTodo Todo

hi def link asmDirective PreProc

hi def link asmType Type 

hi def link asmHexadecimal Number
hi def link asmDecimal Number
hi def link asmOctal Number
hi def link asmBinary Number


hi def link asmString String
hi def link asmStringEscape Special
hi def link asmCharacterEscape Special

let b:current_syntax = "asm"

let &cpo = s:cpo_save
unlet s:cpo_save

