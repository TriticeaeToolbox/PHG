#!/bin/bash

## Index a reference genome for alignment with BWA
##
## NOTE: This script assumes that BWA is installed in a conda environment
## named "bwa". The BWA version must be greater than 6.0 in order to 
## index chromosomes longer than 512Mb. However, at this point, you
## would have to go out of your way to find such an old version...
##
## The bwa index command is single-threaded, and can take a long time (perhaps
## around 8 hours, depending on clock speed) to complete for the hexaploid wheat
## genome
################################################################################


#### SLURM job control parameters ####

#SBATCH --job-name="bwa-index" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -n 1 #number of cores/tasks
#SBATCH -t 12:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load miniconda


#### User-defined constants ####

ref_file="/project/genolabswheatphg/v1_refseq/Triticum_aestivum.IWGSC.dna.toplevel.fa"


#### Executable ####

date

source activate bwa

bwa index -a bwtsw "${ref_file}"

source deactivate

date
