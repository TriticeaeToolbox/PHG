#!/bin/bash -x

# Sample script to run findPath and then export a vcf file.
# Replace "outputJLJ.vcf" in the last line with your preferred filename
FOLDER="/Users/jj332/Documents/PHG/temp/"

docker run --name cbsu_phg_container_consensus --rm \
	-v "${FOLDER}phgSmallSeq/":/tempFileDir/outputDir/ \
 	-v "${FOLDER}phgSmallSeq/ref/":/tempFileDir/data/reference/ \
	-v "${FOLDER}phgSmallSeq/data/":/tempFileDir/data/fastq/ \
	-v "${FOLDER}phgSmallSeq/phgSmallSeq.db":/tempFileDir/outputDir/phgSmallSeq.db \
	-v "${FOLDER}phgSmallSeq/data/configSQLiteDocker.txt":/tempFileDir/data/configSQLiteDocker.txt \
	-t maizegenetics/phg:latest \
	/FindPath.sh phgSmallSeq.db configSQLiteDocker.txt CONSENSUS Ref.fa HAP_COUNT_METHOD PATH_METHOD

echo "Run second docker container - ExportPath.sh"

docker run --name cbsu_phg_container_consensus --rm \
	-v "${FOLDER}phgSmallSeq/":/tempFileDir/outputDir/ \
 	-v "${FOLDER}phgSmallSeq/ref/":/tempFileDir/data/reference/ \
	-v "${FOLDER}phgSmallSeq/data/":/tempFileDir/data/fastq/ \
	-v "${FOLDER}phgSmallSeq/data/configSQLiteDocker.txt":/tempFileDir/data/configSQLiteDocker.txt \
	-t maizegenetics/phg:latest \
	/ExportPath.sh configSQLiteDocker.txt CONSENSUS outputJLJ.vcf
