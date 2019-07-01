#!/bin/bash

## Index a reference genome for alignment with Hisat2
##
## This script will output a Hisat2 index with the same base name as the
## specified reference fasta file (i.e. the index file names will have the
## same format as the input reference file name, without the ".fasta" or ".fa"
## extension).
##
## NOTE: The Hisat2 indexer appears to be single-threaded, unlike the Bowtie2
## indexer
################################################################################


#### SLURM job control parameters ####

#SBATCH --job-name="hisat2-index" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -N 1 #Number of nodes
#SBATCH -n 1 #number of cores/tasks
#SBATCH -t 10:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load hisat2/2.0.5


#### User-defined constants ####

ref_file="/project/genolabswheatphg/v1_refseq/Clay_splitchroms_reference/161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta"


#### Executable ####

date

ind_name="${ref_file%.*}"
hisat2-build "${ref_file}" "${ind_name}"

date
