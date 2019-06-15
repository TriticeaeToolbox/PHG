#!/bin/bash -x

# Edit the code below, replacing "/Users/jj332/Documents/PHG/" 
# with your preferred directory (In this and subsequent scripts).
# Note: in some subsequent scripts /temp/ is added to FOLDER
# Then replace "${FOLDER}Scripts/configSmallSeq.txt" with the
# path on your machine that contains the configSmallSeq.txt file
FOLDER="/Users/jj332/Documents/PHG/"

GENOME_DIR="${FOLDER}temp/"
if [ ! -d "${GENOME_DIR}" ]; then
	mkdir "${GENOME_DIR}"
fi
chmod 777 "${GENOME_DIR}"

# change the local mapping for the confiSmallSeq.txt file to match
# where it lives on your machine.
docker run --name cbsu_phg_container --rm \
	-v "${FOLDER}Scripts/configSmallSeq.txt":/tempFileDir/data/configSmallSeq.txt \
	-v "${GENOME_DIR}":/root/temp/\
	-t maizegenetics/phg:latest \
	/CreateSmallDataSet.sh /tempFileDir/data/configSmallSeq.txt

