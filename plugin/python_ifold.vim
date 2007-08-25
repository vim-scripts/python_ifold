" Vim folding file
" Language:	Python
" Author:	Jorrit Wiersma (foldexpr), Max Ischenko (foldtext), Robert
" Ames (line counts)
" Last Change:	2007 Ago 25
" Version:	2.4
" Bug fix:	Jean-Pierre Chauvel



if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1 

setlocal foldmethod=expr
setlocal foldexpr=GetPythonFold(v:lnum)
setlocal foldtext=PythonFoldText()


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

    " Ignore blank lines
    if line =~ '^\s*$'
        return "="
    endif

    " Ignore triple quoted strings
    if line =~ "(\"\"\"|''')"
        return "="
    endif

    " Ignore continuation lines
    if line =~ '\\$'
        return '='
    endif

    " Support markers
    if line =~ '{{{'
        return "a1"
    elseif line =~ '}}}'
        return "s1"
    endif

    " Classes and functions get their own folds
    if line =~ '^\s*\(class\|def\)\s'
        let b:ind = indent(a:lnum - 1)
        return ">" . (b:ind / &sw + 1)
    endif

    let pnum = prevnonblank(a:lnum - 1)

    if pnum == 0
	" Hit start of file
        return 0
    endif

    " If the previous line has foldlevel zero, and we haven't increased
    " it, we should have foldlevel zero also
    if foldlevel(pnum) == 0
        return 0
    endif

    " The end of a fold is determined through a difference in indentation
    " between this line and the next.
    " So first look for next line
    let nnum = nextnonblank(a:lnum + 1)
    if nnum == 0
        return "="
    endif

    " If next line has less or equal indentation than the first one,
    " we end a fold.
    let nind = indent(nnum)
    if nind <= b:ind
        let b:ind = nind
        return "<" . (b:ind / &sw + 1)
    endif

    " If none of the above apply, keep the indentation
    return "="

endfunction
