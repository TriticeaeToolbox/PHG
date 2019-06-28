1. Create bed file of reference intervals (createRefIntervalsAllFromGVCF.php)
* out file - intervals-exome-all.bed
* minQUAL = 30
* minGQ = 40
* minDP = 4
* minTaxon = 2
* expand = 200
* gap = 10000

2. Load Reference Ranges
* ./LoadGenomeIntervals.sh configSQLite-exome-all.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta intervals-exome-all.bed wheat_load_data_exome.txt

3. Filter GVCF files (filter-gVCF-all.php)
* minGQ = 30
* remove heterozygous
