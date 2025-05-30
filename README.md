dna.vim is a plugin that highlights features in sequencing files (e.g., SAM, PAF, anything with a DNA sequence in it). It colors/highlights the bases ACGT (consistent with IGV colors), operation blocks in CIGAR strings, SAM tag identifiers, and sequence names in fasta/fastq files.

# Screenshots

![FASTA](images/dna-vim-fasta.png)

![PAF](images/dna-vim-paf.png)

![SAM](images/dna-vim-sam.png)

# Usage

Copy dna.vim into your ~/.vim/plugin/ directory. The plugin will automatically trigger for files with the following extensions: .sam, .paf, .fasta, .fa, .fastq, .fq, .gaf, .gfa

You can also toggle the highlighting by using the command `:DNA`. For example, to view .bam files, you can view the file with `samtools view file.bam | vim -` and then apply `:DNA` inside vim.

# Performance

The line `setlocal synmaxcol=9000` limits how far into a line the syntax matching will search. The value 9000 works well for the files I work with, but if the rendering is too slow, you can reduce lag by lowering the value.

# More Precise Matching

The default syntax matching is simple—every A/C/G/T will be colored regardless of context (e.g., the G in HG002 would also be colored). You can implement more careful matching with something like the following, which only highlights bases if they are adjacent to another A/C/G/T:

```
# checks if the character is adjacent to A/C/G/T
call s:DefineHighlight('Adenine', '\([ACGT]\)\@<=A\|A\([ACGT]\)\@=', '#009600', 28)

# default pattern that just checks for A
call s:DefineHighlight('Adenine', 'A', '#009600', 28)
```

However, the trade-off is that the more precise matching is slower. Since the capital A/C/G/T don't appear too often in sequencing files outside of DNA sequences, the plugin uses the faster simple matching.
