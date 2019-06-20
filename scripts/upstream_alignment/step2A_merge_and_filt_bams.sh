#!/bin/bash

## Create single BAM alignment per genotype
##
## NOTE: This script uses a simple sequential workflow. A parallel implementation
## should be feasible using gnu parallel with a function containing the samtools 
## merge and samtools view commands, but this will be a bit more involved.
##
## Notes on isolating "uniquely mapping" reads:
##
## This is not a straightforward topic, especially because the concept of
## "uniquely mapping" is ill-defined. Nevertheless, there are a few steps that
## people often take to try and isolate uniquely mapping reads. I'll list them
## out below, with some commentary that is specific to BWA-generated SAM/BAM files.
##
##   1. Filter by mapping quality (MAPQ). For instance, samtools view -q 10 ...
##      removes reads with MAPQ < 10. This is a tactic that works with the
##      output from some aligners, but not others. Different aligners use 
##      different MAPQ scoring schemes, so the whole thing is a mess. My
##      understanding is that BWA actually follows the SAM specification, so that
##      MAPQ is a phred-scaled likelihood estimate. That being said, I believe
##      that for BWA, if a read maps to multiple locations, it may have a high
##      MAPQ score in each location, so this strategy won't necessarily work.
##   2. Remove reads containing bitwise flag 256, e.g. samtools view -F 256 ...
##      The 256 flag is applied to all secondary alignments. However, removing
##      these will still leave the primary alignments which also had secondary
##      alignments, so they can't be considered "uniquely mapping".
##   3. Tag-based filtering. This is the most strict, and at least in the case of
##      BWA, probably the right way to go. BWA uses the XA tag for alternative
##      alignments for a read, and the SA flag for chimeric alignments (where a
##      read is split into two different locations). Therefore, we can remove all
##      reads with alternative and secondary alignments with:
##         
##          samtools view -h [sam-file] | grep -v -e 'XA:Z:' -e 'SA:Z:' | ...
##      
##      This will remove A LOT of reads (probably around 50%), but is the only
##      way to ensure that we get uniquely mapping ones, at least for BWA output.
##
##   See: https://bioinformatics.stackexchange.com/questions/508/obtaining-uniquely-mapped-reads-from-bwa-mem-alignment
##   and: https://sequencing.qcfail.com/articles/mapq-values-are-really-useful-but-their-implementation-is-a-mess/
################################################################################      


#### SLURM job control parameters ####

#SBATCH --job-name="bwa-align-paired" #name of the job submitted
#SBATCH -p short #name of the queue you are submitting job to
#SBATCH -N 1 #number of nodes in this job
#SBATCH -n 1 #number of cores/tasks in this job, you get all 20 cores with 2 threads per core with hyperthreading
#SBATCH -t 10:00:00 #time allocated for this job hours:mins:seconds
#SBATCH --mail-user=bpward2@ncsu.edu #enter your email address to receive emails
#SBATCH --mail-type=BEGIN,END,FAIL #will receive an email when job starts, ends or fails
#SBATCH -o "stdout.%j.%N" # standard out %j adds job number to outputfile name and %N adds the node name
#SBATCH -e "stderr.%j.%N" #optional but it prints our standard error
module load samtools/1.9


#### User-defined Constants ####

in_bams_dir="/project/genolabswheatphg/alignments/wheatCAP_lane_bams"
out_bams_dir="/project/genolabswheatphg/alignments/wheatCAP_merged_bams"
samples="/project/genolabswheatphg/wheatCAP_first19_samps.tsv"


#### Executable ####

date
mkdir -p $out_bams_dir

## First find all .bam files in the input directory
in_bams=( "${in_bams_dir}"/*.bam )

## Read the sample names into an array called "samps"
#mapfile -t samps < "${samples}"
samps=( $(cut -f1 "${samples}") )

## Now loop through the sample names
## Find the matching single-lane .bam files for each
## Merge these together, filter, and output 
for i in "${samps[@]}"; do

    up_samp="${i^^}"

    ## Dump names of lane bams into a temporary file
    printf '%s\n' "${in_bams[@]}" | grep "$i" > "${out_bams_dir}"/sample_bams.txt

	## First merge the lanes together into an uncompressed BAM
	samtools merge -f -u -b "${out_bams_dir}"/sample_bams.txt "${out_bams_dir}"/temp_merged.bam
	
	## Now a pipe. Here we perform the steps:
	##   1. Discard any read with a secondary alignment (these will contain flags XA or SA)
	##      in other words, only keep UNIQUELY MAPPED reads
    ##   2. Sort by coordinates
    ##   3. Write out the merged, sorted bam file
	samtools view -h "${out_bams_dir}"/temp_merged.bam | 
		grep -v -e 'XA:Z:' -e 'SA:Z:' |
    	samtools sort -O BAM - -o "${out_bams_dir}"/"${up_samp}".bam
	
    ## Index the merged bam file
    samtools index -c "${out_bams_dir}"/"${up_samp}".bam

    rm "${out_bams_dir}"/sample_bams.txt
    rm "${out_bams_dir}"/temp_merged.bam
done

date
