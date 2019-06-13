<a href=../scripts/create-reference-intervals.php>Create Reference Ranges</a>

LoadGenomeIntervals.sh configSQLite.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta intervals.bed wheat_load_data_exome.txt

<a href=../scripts/CreateHaplotypesFrom GVCF.groovy>CreateHaplotypesFromGVCF.groovy</a>

CreateConsensi.sh configSQLite.txt 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta intervals.bed GATK_PIPELINE CONSENSUS

FindPath.sh 20taxons_exome configSQLite.txt CONSENSUS 161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta HAP_COUNT_METHOD PATH_METHOD

ExportPath.sh
