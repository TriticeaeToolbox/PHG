# Description of steps to create PHG database
# The database can be downloads at 
<a href="https://app.globus.org/file-manager?origin_id=940c21fe-377d-11e8-b96a-0ac6873fc732&origin_path=%2Fhome%2Fjj332_pgh%2Fphg-5A%2F">phg-5A</a>

# Load Reference Ranges
./LoadGenomeIntervals.sh configSQLite-exome5A.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta intervals-exome-5A.bed wheat_load_data_exome.txt

# Load 10 taxons
tempFileDir/data/exome-hapmap-test5A.sh

# CreateConsi.sh
./tempFileDir/data/CreateConsensi.sh /tempFileDir/data/configSQLite-exome5A.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta GATK_PIPELINE CONSENSUS

# Index Haplotypes
./tempFileDir/data/IndexPangenome.sh 10taxontest configSQLite-exome5A.txt CONSENSUS 10G 21 11 

# FindPathMinimap2.sh
./tempFileDir/data/FindPathMinimap2.sh 10taxontest configSQLite-exome5A.txt CONSENSUS CONSENSUS HAP_COUNT_METHOD PATH_METHOD false

# ExportPath.sh
ExportPath.sh configSQLite-exome5A.txt CONSENSUS testOutput.vcf
