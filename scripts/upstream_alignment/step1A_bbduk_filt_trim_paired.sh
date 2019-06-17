#!/bin/bash

## Quality filtering and adapter trimming using BBDuk
##
## NOTE: bbduk parameters are hard coded in the bbduk.sh call below.
## Simple multithreading can be achieved by running on a single node, specifying
## multiple cores (up to 40 in the case of the Ceres cluster). BBDuk is quite
## fast, so multithreading beyond this is probably not required, but can be
## achieved using a call to mpirun
################################################################################


#### SLURM job control ####

#SBATCH --job-name="bbduk-filt" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -N 1 #number of nodes in this job
#SBATCH -n 10 #number of cores/tasks in this job
#SBATCH -t 05:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load bbtools/37.02


#### User-defined constants ####

fastq_dir="/project/genolabswheatphg/raw_data/wheatCAP_parents"
adapt_fasta="/project/genolabswheatphg/Truseq_paired_adapters.fa"
samples="/project/genolabswheatphg/wheatCAP_samples.tsv"
out_dir="/project/genolabswheatphg/filt_fastqs/wheatCAP_parents"
ncores=10


#### Executable  ####

date
mkdir "${out_dir}"

## First recursively find all fastq files in fastq_dir
shopt -s globstar nullglob
fastqs=( "$fastq_dir"/**/*.fastq.gz )
#printf '%s\n' "${fastqs[@]}"

## Read the sample names into an array called "samps"
#mapfile -t samps < "${samples}"
samps=( $(cut -f1 "${samples}") )
#printf '%s\n' "${samps[@]}"

## Get length of adapters
ad_len=$(head -n 2 "${adapt_fasta}" | tail -n -1 | wc -c)

for i in "${samps[@]}"; do

    ## Now we have to go through the usual insane shell syntax to get all the unique
    ## lanes for sample i
    lanes=($(printf '%s\n' "${fastqs[@]}" | grep "$i" | sed 's/_R[12].*$//' | sort -u))
    #echo "***"    
    #printf '%s\n' "${lanes[@]}"

    ## Loop through each lane
    for j in "${lanes[@]}"; do

	base=$(basename "${j}")
	#echo "samp: ${i}"
        echo "lane: ${j}"

        ## Assign yet another new array, holding each of the two mated fastqs for lane i    
        mates=($(printf '%s\n' "${fastqs[@]}" | grep $j))    
        fq1="${mates[0]}"
        fq2="${mates[1]}"
        #echo "***"
        #echo $fq1
        #echo $fq2

        ## Run BBDuk
        ## Setting maq will remove entire reads based on their average qual
        ## maq=10 average error is 10%
        ## maq=13 ~5%
        ## maq=15 ~3%
        ## maq=20 1%
        bbduk.sh -Xmx10g t=$ncores \
                   in1="${fq1}" in2="${fq2}" out1="${out_dir}"/"${base}"_R1.fastq.gz out2="${out_dir}"/"${base}"_R2.fastq.gz \
                   ref="${adapt_fasta}" ktrim=r k=$ad_len mink=10 hdist=3 hdist2=1 ftm=5 maq=13 minlen=75 tpe tbo
    done
done

date
