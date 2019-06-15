#!/bin/bash -x
FOLDER="/Users/jj332/Documents/PHG/"

taxonList=(Ref LineA LineB RefA1 LineA1 LineB1)

for taxon in "${taxonList[@]}"
do
mkdir -p "${FOLDER}PHG_training_tests/dockerOutput/gvcfOut/${taxon}/"
mkdir -p "${FOLDER}PHG_training_tests/dockerOutput/gvcfOutFilter/${taxon}/"

docker run --name cbsu_phg_container_${taxon} --rm \
	-v "${FOLDER}temp/phgSmallSeq/ref/":/tempFileDir/data/reference/ \
    -v "${FOLDER}temp/phgSmallSeq/data/":/tempFileDir/data/fastq/ \
    -v "${FOLDER}temp/phgSmallSeq/phgSmallSeq.db":/tempFileDir/outputDir/phgSmallSeq.db \
	-v "${FOLDER}temp/phgSmallSeq/data/configSQLiteDocker.txt":/tempFileDir/data/configSQLiteDocker.txt \
	-v "${FOLDER}temp/phgSmallSeq/align/":/tempFileDir/data/outputs/gvcfs/ \
	-t maizegenetics/phg:latest \
	/CreateHaplotypes.sh /tempFileDir/data/configSQLiteDocker.txt \
			  ${taxon} \
			  single \
			  GATK_PIPELINE \
			  ${taxon}_R1.fastq

done
