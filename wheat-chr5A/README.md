# Description of steps to create PHG database

The database (size is 2G) can be downloads using Globus.org at 
 <a href="https://app.globus.org/file-manager?origin_id=6977f294-99a9-11e9-8e6e-029d279f7e24&origin_path=%2F" target="_blank">HapMap-5A</a>. This link works for anyone with Globus account.

1. Create bed file of reference intervals (createRefIntervalsFromGVCF.php)
* output file - intervals_exome-5A.bed
* $minQUAL = 30;  //variant must have QUAL greater than 30
* $minGQ = 40;    //variant must have GQ greater than 40
* $minDP = 4;     //variant must have DP greater than 4
* $minTaxon = 2;  //variant must be present in more than 2 taxons
* $expand = 200;
* $gap = 10000;

2. Load Reference Ranges
* ./LoadGenomeIntervals.sh configSQLite-exome5A.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta intervals-exome-5A.bed wheat_load_data_exome.txt

3. Filter GVCF files (filter-gVCF.php)
* minGQ = 40
* remove heterozygous sites

4. Load 20 taxons
* ./tempFileDir/data/exome-hapmap-test5A.sh

5. CreateConsi.sh
* ./tempFileDir/data/CreateConsensi.sh /tempFileDir/data/configSQLite-exome5A.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta GATK_PIPELINE CONSENSUS

6. Index Haplotypes
* ./tempFileDir/data/IndexPangenome.sh 10taxontest configSQLite-exome5A.txt CONSENSUS 10G 21 11 

7. FindPathMinimap2.sh
* ./tempFileDir/data/FindPathMinimap2.sh 10taxontest configSQLite-exome5A.txt CONSENSUS CONSENSUS HAP_COUNT_METHOD PATH_METHOD false

8.  ExportPath.sh
* ExportPath.sh configSQLite-exome5A.txt CONSENSUS testOutput.vcf
