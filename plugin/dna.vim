if exists('g:loaded_dna_colors')
	finish
endif

let g:loaded_dna_colors = 1
let g:dna_highlight_enabled = 0

augroup dna_colors
	autocmd!
	autocmd BufRead,BufNewFile *.sam,*.paf,*.fasta,*.fa,*.fastq,*.fq,*.gaf,*.gfa set filetype=dna
	autocmd FileType dna let g:dna_highlight_enabled = 1
	autocmd FileType dna call s:DNAHighlight()
augroup END

function! s:DefineHighlight(name, pattern, gui_color, cterm_color)
	execute 'syntax match ' . a:name . ' /' . a:pattern . '/'
	execute 'highlight ' . a:name . ' ctermfg=' . a:cterm_color . ' guifg=' . a:gui_color
endfunction

function! s:DNAHighlight()
	syntax sync maxlines=0
	setlocal synmaxcol=9000
	setlocal re=1
	setlocal redrawtime=10000

	" DNA base colors
	call s:DefineHighlight('Adenine', 'A', '#009600', 28)
	call s:DefineHighlight('Cytosine', 'C', '#0000ff', 21)
	call s:DefineHighlight('Guanine',  'G', '#d17205', 208)
	call s:DefineHighlight('Thymine',  'T', '#c80000', 160)

	" CIGAR operations
	call s:DefineHighlight('CigarMatch',     '\d\+M', '#5fafff',  75)
	call s:DefineHighlight('CigarEqual',     '\d\+=', '#5fd7af',  79)
	call s:DefineHighlight('CigarMismatch',  '\d\+X', '#ff005f', 197)
	call s:DefineHighlight('CigarDeletion',  '\d\+D', '#f5f538', 228)
	call s:DefineHighlight('CigarInsertion', '\d\+I', '#be6ff2', 135)
	call s:DefineHighlight('CigarClipS',     '\d\+S', '#ff875f', 209)
	call s:DefineHighlight('CigarClipH',     '\d\+H', '#ff875f', 209)

	" Tags and sequence name lines
	call s:DefineHighlight('Tag', '\w\w\ze:.:', '#00ffff', 14)
	call s:DefineHighlight('NameLine', '^[>@][^\r\n]*', '#00ffff', 14)
endfunction

function! s:DNAClear()
	syntax clear Adenine
	syntax clear Cytosine
	syntax clear Guanine
	syntax clear Thymine

	syntax clear CigarMatch
	syntax clear CigarEqual
	syntax clear CigarMismatch
	syntax clear CigarDeletion
	syntax clear CigarInsertion
	syntax clear CigarClipS
	syntax clear CigarClipH

	syntax clear Tag
	syntax clear NameLine
endfunction

function! DNAToggle()
	if g:dna_highlight_enabled
		call s:DNAClear()
		let g:dna_highlight_enabled = 0
	else
		call s:DNAHighlight()
		let g:dna_highlight_enabled = 1
	endif
endfunction

command! DNA call DNAToggle()
