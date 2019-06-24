# Description of steps to create PHG database

## The database can be downloads at 
<a href="https://app.globus.org/file-manager?origin_id=940c21fe-377d-11e8-b96a-0ac6873fc732&origin_path=%2Fhome%2Fjj332_pgh%2Fphg-5A%2F" target="_new">phg-5A</a>

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

4. Load 10 taxons
* ./tempFileDir/data/exome-hapmap-test5A.sh

5. CreateConsi.sh
* ./tempFileDir/data/CreateConsensi.sh /tempFileDir/data/configSQLite-exome5A.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta GATK_PIPELINE CONSENSUS

6. Index Haplotypes
* ./tempFileDir/data/IndexPangenome.sh 10taxontest configSQLite-exome5A.txt CONSENSUS 10G 21 11 

7. FindPathMinimap2.sh
* ./tempFileDir/data/FindPathMinimap2.sh 10taxontest configSQLite-exome5A.txt CONSENSUS CONSENSUS HAP_COUNT_METHOD PATH_METHOD false

8.  ExportPath.sh
* ExportPath.sh configSQLite-exome5A.txt CONSENSUS testOutput.vcf
