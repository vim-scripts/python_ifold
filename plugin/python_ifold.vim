" Vim folding file
" Language:	Python
" Author:	Jorrit Wiersma (foldexpr), Max Ischenko (foldtext), Robert,
" Jean-Pierre Chauvel (bugfixes)
" Ames (line counts)
" Last Change:	2007 Nov 25
" Version:	2.8.3.2.a
" Bugfix: Jean-Pierre Chauvel



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

if !exists("g:ifold_accuracy")
    let g:ifold_accuracy = 0
endif

map <buffer> f :call ToggleFold()<CR> 

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


let b:nestinglevel = 0

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
    " Verify if the next line is a class or function definition
    " as well
        let imm_nnum = a:lnum + 1
        let nnum = nextnonblank(imm_nnum)
        if nnum - imm_nnum < 2
            let nind = indent(nnum)
            let pind = indent(a:lnum - 1)
            if pind >= nind
                let nline = getline(nnum)
                let b:nestinglevel = nind
                return "<" . ((b:nestinglevel + &sw) / &sw)
            endif
        endif
        let b:nestinglevel = indent(a:lnum - 1)
        return ">" . ((b:nestinglevel + &sw) / &sw)
    endif

    " If next line has less or equal indentation than the first one,
    " we end a fold.
    let nind = indent(nextnonblank(a:lnum + 1))
    if nind <= b:nestinglevel
        let b:nestinglevel = nind
        return "<" . ((b:nestinglevel + &sw) / &sw)
    else
        let ind = indent(a:lnum)
        if ind == (b:nestinglevel + &sw)
            if nind < ind
                let b:nestinglevel = nind
                return "<" . ((b:nestinglevel + &sw) / &sw)
            endif
        endif
    endif

    " If none of the above apply, keep the indentation
    return "="
endfunction

function! GetPythonFoldAccurately(lnum)
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
    " Verify if the next line is a class or function definition
    " as well
        let imm_nnum = a:lnum + 1
        let nnum = nextnonblank(imm_nnum)
        let nind = indent(nnum)
        let pind = indent(a:lnum - 1)
        if pind >= nind
            let nline = getline(nnum)
            let b:nestinglevel = nind
            return "<" . ((b:nestinglevel + &sw) / &sw)
        endif
        let b:nestinglevel = indent(a:lnum - 1)
        return ">" . ((b:nestinglevel + &sw) / &sw)
    endif

    " If next line has less or equal indentation than the first one,
    " we end a fold.
    let nind = indent(nextnonblank(a:lnum + 1))
    if nind <= b:nestinglevel
        let b:nestinglevel = nind
        return "<" . ((b:nestinglevel + &sw) / &sw)
    else
        let ind = indent(a:lnum)
        if ind == (b:nestinglevel + &sw)
            if nind < ind
                let b:nestinglevel = nind
                return "<" . ((b:nestinglevel + &sw) / &sw)
            endif
        endif
    endif

    " If none of the above apply, keep the indentation
    return "="
endfunction

let b:is_folding = 1

function! ToggleFold()
    if b:is_folding
        set foldexpr=0
        let b:is_folding = 0
    else
        call ReFold()
        " Open the fold we are in
        exec 'norm! zO'
        let b:is_folding = 1
    endif
endfunction

" In case folding breaks down
function! ReFold()
    set foldmethod=expr
    set foldexpr=0
    set foldmethod=expr
    if g:ifold_accuracy
        set foldexpr=GetPythonFoldAccurately(v:lnum)
    else
        set foldexpr=GetPythonFold(v:lnum)
    endif
    if g:ifold_show_text
        set foldtext=PythonFoldText()
    else
        set foldtext='Folded\ code'
    endif
    echo
endfunction

call ReFold()
