The findpath.sh step creates a fasta file of all haplotypes then indexes this file with "bwa index".
This a a slow process because "bwa index" is a single threaded process. The wheat 1A chromosome is about 590MB.
A PHG with 10 taxon gives a haplotype file of about 6G which takes about 12 hourse to index.
A PHG of the full wheat genome would give a file of 150G and may take 12 days to index.

We plan to switch from "bwa index" to minmap2 which will provide a 10x improvement is speed. https://github.com/lh3/minimap2
