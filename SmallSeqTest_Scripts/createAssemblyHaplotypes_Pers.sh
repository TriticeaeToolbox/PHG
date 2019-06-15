#!/bin/bash -x

# This example is a bit different than how you would normally run the assemblies.
# Normally, a user would process all chromosomes for an assembly within a loop.
# Because our smallSeq dataset has only 1 chromosome, but multiple assemblies, we
# are looping on the assembly name, with the chromosome number remaining constant.
# The reference fasta also remains constant as it contains only 1 chromosome.
FOLDER="/Users/jj332/Documents/PHG/temp/"

#chromList=(1 2 3 4 5 6 7 8 9 10)
assemblyList=(LineA1 LineB1)

#for chrom in "${chromList[@]}"
for assembly in "${assemblyList[@]}"
do

#echo "Starting chrom ${chrom} "
echo "Starting assembly ${assembly} "

docker run --name phg_assembly_container_${assembly} --rm \
        -v "${FOLDER}phgSmallSeq/":/tempFileDir/outputDir/ \
        -v "${FOLDER}phgSmallSeq/ref/":/tempFileDir/data/reference/ \
        -v "${FOLDER}phgSmallSeq/data/":/tempFileDir/data/ \
        -v "${FOLDER}phgSmallSeq/answer/":/tempFileDir/data/assemblyFasta/ \
        -v "${FOLDER}phgSmallSeq/align/":/tempFileDir/outputDir/align/ \
        -t maizegenetics/phg:latest \
        /LoadAssemblyAnchors.sh configSQLiteDocker.txt \
                Ref.fa \
                ${assembly}.fa \
                ${assembly}_Assembly \
                1


echo "Finished chrom  ${assembly} "
done
