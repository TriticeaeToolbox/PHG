#!/bin/bash -x
FOLDER="/Users/jj332/Documents/PHG/temp/"

docker run --name cbsu_phg_container --rm \
	-v "${FOLDER}phgSmallSeq/":/tempFileDir/outputDir/ \
	-v "${FOLDER}phgSmallSeq/ref/":/tempFileDir/data/reference/ \
	-v "${FOLDER}phgSmallSeq/data/":/tempFileDir/data/ \
	-v "${FOLDER}phgSmallSeq/answer/":/tempFileDir/answer/ \
	-t maizegenetics/phg:latest \
	/LoadGenomeIntervals.sh configSQLiteDocker.txt Ref.fa anchors.bed Ref_Assembly_load_data.txt true

