#!/bin/bash

## BWA alignment of paired-end reads
##
## NOTE: The samples file is used here so that you can edit it to pick up
## where you left off if you have to stop the run prematurely for any reason.
## Only its first column is used if multiple columns are present (in which
## case it must be tab-delimited).
##
## In the readgroup lines of the output BAM files, the sample name will be
## capitalized.
##
## Number of cores should match in the SLURM job control section and the user-
## defined parameters. Simple multithreading can be performed using multiple
## cores on a single node. On Ceres, each node has 40 cores (20 physical, 40 with
## hyperthreading). Parallelizing beyond this requires MPI.
################################################################################


#### SLURM job control parameters ####

#SBATCH --job-name="bwa-align-paired" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -N 1 #number of nodes in this job
#SBATCH -n 20 #number of cores/tasks in this job, you get all 20 cores with 2 threads per core with hyperthreading
#SBATCH -t 30:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load samtools/1.9
module load miniconda/3.6
source activate bwa


#### User-defined constants ####

fastq_dir="/project/genolabswheatphg/filt_fastqs/wheatCAP_parents"
ref_gen="/project/genolabswheatphg/v1_refseq/Triticum_aestivum.IWGSC.dna.toplevel.fa"
samples="/project/genolabswheatphg/wheatCAP_samps_restart.tsv"
out_dir="/project/genolabswheatphg/alignments/wheatCAP_lane_bams"
ncores=20


#### Executable ####

date
mkdir $out_dir

## First recursively find all fastq files in fastq_dir
shopt -s globstar nullglob
fastqs=( "$fastq_dir"/**/*.fastq.gz )
#printf '%s\n' "${fastqs[@]}"

## Read the sample names into an array called "samps"
#mapfile -t samps < "${samples}"
samps=( $(cut -f1 "${samples}") )
#printf '%s\n' "${samps[@]}"

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
        #echo "lane: ${j}"

        ## Assign yet another new array, holding each of the two mated fastqs for lane i    
        mates=($(printf '%s\n' "${fastqs[@]}" | grep $j))    
        fq1="${mates[0]}"
        fq2="${mates[1]}"

        #echo "**********"        
        #echo $fq1
        #echo $fq2
        
        ## For some reason, the barcode indexes in the FASTQ files contain some N
        ## values for the first few reads. I don't know the significance of this. 
        ## Let's just grab line 10,001:
        one_line=$(zcat $fq1 | head -n 10001 | tail -n -1)
        
        ## This sets the first four fields (instrument:run_id:flowcell:lane) of the 
        ## first line of the fastq file as a variable named "id"
        id=$(echo "$one_line" | cut -f 1-4 -d":" | sed 's/@//' | sed 's/:/_/g')
        
        ## Now get the barcode from the 10th field of the line
        bar=$(echo "$one_line" | cut -f 10 -d":" | sed 's/+/-/')
        #echo $id $i $bar

        ## The inconsistent capitalization on some of these files is a bit annoying
        ## In the readgroup line of the BAMs, I will change name to all caps
	up_samp=${i^^}

        ## Run BWA. -R argument inserts appropriate @RG line in output bam file header
        ## After alignment we run fixmate to correct any potential formatting issues
        ## with the paired reads, and then run markdup to mark PCR duplicates
        ## Unfortunately fixmate and markdup need different sorting schemes, so SAM file must
        ## be sorted twice
        time bwa mem -t $ncores \
                     -R $(echo "@RG\tID:${id}\tSM:${up_samp}\tLB:${id}_${up_samp}\tBC:${bar}\tPL:ILLUMINA") \
                     $ref_gen \
                     $fq1 $fq2 |
                     samtools sort -n -O SAM - |
                     samtools fixmate -m -O SAM - - |
                     samtools sort -O SAM - |
    	             samtools markdup -@ $ncores - "${out_dir}"/"${base}".bam
    done
done

source deactivate
