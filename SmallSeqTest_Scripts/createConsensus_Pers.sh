# sample script to create consensus for small sequence testing\
# the last 2 parameters are method name for haplotypes (must match
# the value from createHaplotypesAlls.sh script) and the method
# name for this consensus run.
# The method descriptions are created programmatically
FOLDER="/Users/jj332/Documents/PHG/temp/"

docker run --name cbsu_phg_container_consensus --rm \
	-v "${FOLDER}phgSmallSeq/ref/":/tempFileDir/data/reference/ \
    -v "${FOLDER}phgSmallSeq/phgSmallSeq.db":/tempFileDir/outputDir/phgSmallSeq.db \
    -v "${FOLDER}phgSmallSeq/data/configSQLiteDocker.txt":/tempFileDir/data/configSQLiteDocker.txt \
	-v "${FOLDER}phgSmallSeq/pangenome/":/tempFileDir/data/outputs/mergedVCFs/ \
	-t maizegenetics/phg:latest \
	/CreateConsensi.sh /tempFileDir/data/configSQLiteDocker.txt Ref.fa GATK_PIPELINE CONSENSUS
