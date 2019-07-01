#!/bin/bash

## Index a reference genome for alignment with Bowtie2
##
## This script will output a Bowtie2 index with the same base name as the
## specified reference fasta file (i.e. the index file names will have the
## same format as the input reference file name, without the ".fasta" or ".fa"
## extension).
##
## NOTE: The Bowtie2 indexer is multi-threaded. Make sure that the number of
## cores specified in the line starting SBATCH -n matches the number of threads
## in the user-defined constants section. Note that on Ceres, the max. number
## of cores per node is 40. Using more cores than this would require MPI, which
## should generally not be necessary in this case.
################################################################################


#### SLURM job control parameters ####

#SBATCH --job-name="bowtie2-index" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -N 1 #Number of nodes
#SBATCH -n 40 #number of cores/tasks
#SBATCH -t 06:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load bowtie2/2.3.4


#### User-defined constants ####

ref_file="/project/genolabswheatphg/v1_refseq/Clay_splitchroms_reference/161010_Chinese_Spring_v1.0_pseudomolecules_parts.fasta"
nthreads=40

#### Executable ####

date

ind_name="${ref_file%.*}"
bowtie2-build --threads $nthreads "${ref_file}" "${ind_name}"

date
