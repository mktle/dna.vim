if exists('g:loaded_dna_colors')
	finish
endif

let g:loaded_dna_colors = 1
let g:dna_enabled = 0

augroup dna_colors
	autocmd!
	autocmd BufRead,BufNewFile *.sam set filetype=sam
	autocmd BufRead,BufNewFile *.fasta,*.fa set filetype=fasta
	autocmd BufRead,BufNewFile *.fastq,*.fq set filetype=fastq
	autocmd BufRead,BufNewFile *.paf set filetype=paf
	autocmd BufRead,BufNewFile *.gaf set filetype=gaf
	autocmd BufRead,BufNewFile *.gfa set filetype=gfa
	autocmd FileType sam,fasta,fastq,paf,gaf,gfa call DNAToggle()
augroup END

function! s:DefineHighlight(name, pattern, gui_color, cterm_color)
	execute 'syntax match ' . a:name . ' /' . a:pattern . '/'
	execute 'highlight ' . a:name . ' ctermfg=' . a:cterm_color . ' guifg=' . a:gui_color
endfunction

function! s:BaseHighlight()
	syntax sync maxlines=0
	setlocal synmaxcol=5000
	setlocal re=1
	setlocal redrawtime=10000

	" DNA base colors
	call s:DefineHighlight('Adenine', 'A', '#009600', 28)
	call s:DefineHighlight('Cytosine', 'C', '#0000ff', 21)
	call s:DefineHighlight('Guanine',  'G', '#d17205', 208)
	call s:DefineHighlight('Thymine',  'T', '#c80000', 160)
	call s:DefineHighlight('Uracil', 'U', '#ff6f61', 203)
	call s:DefineHighlight('Ambiguous', 'N', '#8e7cc3', 104)

	" Tags and sequence name lines
	call s:DefineHighlight('Tag', '\w\w\ze:.:', '#00ffff', 14)
	call s:DefineHighlight('NameLine', '^[>@][^\r\n]*', '#00ffff', 14)
endfunction

function! s:CIGARHighlight()
	call s:DefineHighlight('CigarMatch',     '\d\+M', '#5fafff',  75)
	call s:DefineHighlight('CigarEqual',     '\d\+=', '#5fd7af',  79)
	call s:DefineHighlight('CigarMismatch',  '\d\+X', '#ff005f', 197)
	call s:DefineHighlight('CigarDeletion',  '\d\+D', '#f5f538', 228)
	call s:DefineHighlight('CigarInsertion', '\d\+I', '#be6ff2', 135)
	call s:DefineHighlight('CigarClipS',     '\d\+S', '#ff875f', 209)
	call s:DefineHighlight('CigarClipH',     '\d\+H', '#ff875f', 209)
endfunction

function! s:BaseClear()
	syntax clear Adenine
	syntax clear Cytosine
	syntax clear Guanine
	syntax clear Thymine
	syntax clear Uracil
	syntax clear Ambiguous

	syntax clear Tag
	syntax clear NameLine
endfunction

function! s:CIGARClear()
	syntax clear CigarMatch
	syntax clear CigarEqual
	syntax clear CigarMismatch
	syntax clear CigarDeletion
	syntax clear CigarInsertion
	syntax clear CigarClipS
	syntax clear CigarClipH
endfunction

function! DNAToggle()
	if g:dna_enabled
		call s:BaseClear()
		if &filetype != 'fasta' && &filetype != 'fastq' && &filetype != 'gfa'
			call s:CIGARClear()
		endif
		let g:dna_enabled = 0
	else
		call s:BaseHighlight()
		if &filetype != 'fasta' && &filetype != 'fastq' && &filetype != 'gfa'
			call s:CIGARHighlight()
		endif
		let g:dna_enabled = 1
	endif
endfunction

command! DNA call DNAToggle()

function! GetFieldNum()
	let l:line = getline('.')
	let l:col = col('.')
	
	let l:before_cursor = strpart(l:line, 0, l:col - 1)
	let l:fields = split(l:before_cursor, '\t', 1)
	let l:field_num = len(l:fields)

	" If cursor is at the very beginning, we're in field 1
	if l:field_num == 0
		let l:field_num = 1
	endif
	return l:field_num
endfunction

function! GetFieldValue()
	let l:line = getline('.')
	let l:fields = split(l:line, '\t')
	let l:fieldnum = GetFieldNum()
	if l:fieldnum <= len(l:fields)
		return str2nr(l:fields[l:fieldnum - 1])
	endif
	return 0
endfunction

let g:sam_fields = {
	\ 1: 'QNAME: Query template NAME',
	\ 2: 'FLAG: bitwise FLAG',
	\ 3: 'RNAME: Reference sequence NAME',
	\ 4: 'POS: 1-based leftmost mapping POSition',
	\ 5: 'MAPQ: MAPping Quality',
	\ 6: 'CIGAR: CIGAR string',
	\ 7: 'RNEXT: Reference name of the mate/next read',
	\ 8: 'PNEXT: Position of the mate/next read',
	\ 9: 'TLEN: observed Template LENgth',
	\ 10: 'SEQ: segment SEQuence',
	\ 11: 'QUAL: ASCII of Phred-scaled base QUALity+33'
	\}

let g:sam_flag_bits = {
	\ 0x1:   'paired in sequencing',
	\ 0x2:   'properly paired',
	\ 0x4:   'unmapped',
	\ 0x8:   'mate unmapped',
	\ 0x10:  'reverse strand',
	\ 0x20:  'mate on reverse strand',
	\ 0x40:  'first in pair',
	\ 0x80:  'second in pair',
	\ 0x100: 'not primary alignment',
	\ 0x200: 'fails platform/vendor quality checks',
	\ 0x400: 'PCR or optical duplicate',
	\ 0x800: 'supplementary alignment'
	\}

function! DecodeSAMFlag(flag)
	let l:bits = []
	for l:bit in keys(g:sam_flag_bits)
		if and(a:flag, str2nr(l:bit))
			call add(l:bits, g:sam_flag_bits[l:bit])
		endif
	endfor
	return join(l:bits, ', ')
endfunction

function! ShowSAMField()
	let l:fieldnum = GetFieldNum()
	if l:fieldnum == 2
		let l:flagval = GetFieldValue()
		let l:decoded = DecodeSAMFlag(l:flagval)
		echo 'FLAG: ' . l:flagval . ' -- ' . l:decoded
  	else
	  	let l:field = get(g:sam_fields, l:fieldnum, 'AUX: AUXiliary fields')
		echo l:field
	endif
endfunction

let g:paf_fields = {
	\ 1: 'Query sequence name',
	\ 2: 'Query sequence length',
	\ 3: 'Query start (0-based; BED-like; closed)',
	\ 4: 'Query end (0-based; BED-like; open)',
	\ 5: 'Relative strand: "+" or "-"',
	\ 6: 'Target sequence name',
	\ 7: 'Target sequence length',
	\ 8: 'Target start on original strand (0-based)',
	\ 9: 'Target end on original strand (0-based)',
	\ 10: 'Number of residue matches',
	\ 11: 'Alignment block length',
	\ 12: 'Mapping quality (0-255; 255 for missing)'
	\}

function! ShowPAFField()
  let l:field = get(g:paf_fields, GetFieldNum(), 'Auxiliary fields')
  echo l:field
endfunction

let g:gaf_fields = {
	\ 1: 'Query sequence name',
	\ 2: 'Query sequence length',
	\ 3: 'Query start (0-based; closed)',
	\ 4: 'Query end (0-based; open)',
	\ 5: 'Strand relative to the path: "+" or "-"',
	\ 6: 'Path matching /([><][^\s><]+(:\d+-\d+)?)+|([^\s><]+)/',
	\ 7: 'Path length',
	\ 8: 'Start position on the path (0-based)',
	\ 9: 'End position on the path (0-based)',
	\ 10: 'Number of residue matches',
	\ 11: 'Alignment block length',
	\ 12: 'Mapping quality (0-255; 255 for missing)'
	\}

function! ShowGAFField()
  let l:field = get(g:gaf_fields, GetFieldNum(), 'Auxiliary fields')
  echo l:field
endfunction

command! BAM call ShowSAMField()
command! SAM call ShowSAMField()
command! PAF call ShowPAFField()
command! GAF call ShowGAFField()
