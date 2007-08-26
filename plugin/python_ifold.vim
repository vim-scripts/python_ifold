" Vim folding file
" Language:	Python
" Author:	Jorrit Wiersma (foldexpr), Max Ischenko (foldtext), Robert,
" Jean-Pierre Chauvel
" Ames (line counts)
" Last Change:	2007 Ago 26
" Version:	2.6
"



if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1 

if !exists("g:ifold_support_markers")
    let g:ifold_support_markers = 0
endif

if !exists("g:ifold_show_text")
    let g:ifold_show_text = 0
endif


function! PythonFoldText()
    let line = getline(v:foldstart)
    let nnum = nextnonblank(v:foldstart + 1)
    let nextline = getline(nnum)
    if nextline =~ '^\s\+"""$'
        let line = line . getline(nnum + 1)
    elseif nextline =~ '^\s\+"""'
        let line = line . ' ' . matchstr(nextline, '"""\zs.\{-}\ze\("""\)\?$')
    elseif nextline =~ '^\s\+"[^"]\+"$'
        let line = line . ' ' . matchstr(nextline, '"\zs.*\ze"')
    elseif nextline =~ '^\s\+pass\s*$'
        let line = line . ' pass'
    endif
    let size = 1 + v:foldend - v:foldstart
    if size < 10
        let size = " " . size
    endif
    if size < 100
        let size = " " . size
    endif
    if size < 1000
        let size = " " . size
    endif
        return size . " lines: " . line
endfunction


let b:ind = 0

function! GetPythonFold(lnum)
    " Determine folding level in Python source
    "
    let line = getline(a:lnum - 1)

    " Support markers
    if g:ifold_support_markers
        if line =~ '{{{'
            return "a1"
        elseif line =~ '}}}'
            return "s1"
        endif
    endif

    " Classes and functions get their own folds
    if line =~ '^\s*\(class\|def\)\s'
        let b:ind = indent(a:lnum - 1)
        return ">" . (b:ind / &sw + 1)
    endif

    " If next line has less or equal indentation than the first one,
    " we end a fold.
    let nnum = nextnonblank(a:lnum + 1)
    let nind = indent(nnum)
    if nind <= b:ind
        let b:ind = nind
        return "<" . (b:ind / &sw + 1)
    endif

    " If none of the above apply, keep the indentation
    return "="

endfunction

" In case folding breaks down
function! ReFold()
    set foldmethod=expr
    set foldexpr=0
    set foldmethod=expr
    set foldexpr=GetPythonFold(v:lnum)
    if g:ifold_show_text
        set foldtext=PythonFoldText()
    else
        set foldtext='Folded\ code'
    endif
    echo
endfunction

call ReFold()
