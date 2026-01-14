#!/bin/bash

#SBATCH --job-name fanelli_hw3
#SBATCH -A evoanalysis
#SBATCH -t 0-01:00
#SBATCH --nodes=4
#SBATCH --cpus-per-task=10
#SBATCH --mem=25G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=rfanelli@uwyo.edu
#SBATCH --array=0-37
#SBATCH -o std_make_files_%A.out
#SBATCH -e err_make_files_%A.err

# load modules 
module load fastqc

# input directory with fastq files
IN_dir=/project/evoanalysis/d3challenge_fq

# output directory 
OUT_dir=/project/evoanalysis/rfanelli/homework3/output

# save results to a text file
COUNT_file=${OUT_dir}/homework3-Fanelli.txt

# create output directory if it doesn't already exist (it does exist, but it's good practice to include incase the output folder isn't there. the -p prevents overriding folders with the same name)
mkdir -p ${OUT_dir}

# Get list of all FASTQ files in the input folder
FASTQS=(${IN_dir}/*.fastq) 


# Select FASTQ file for this array task 
FASTQ=${FASTQS[${SLURM_ARRAY_TASK_ID}]}

# Run fastqc. 
# -t = number of cpus per task, which are specified in the SBATCH code (27), but can be called using {SLURM_CPUS_PER_TASK}
# -o = output location for the specified fastq files
fastqc -t ${SLURM_CPUS_PER_TASK} -o ${OUT_dir} ${FASTQ}

# Count the number of reads in the FASTQ file
# wc = word count command
# -l = option to change the wc command to count lines instead of words
# < = argument to say perform the command on the object to the right of command/option
# $ = a command to store results
# $(( )) = store results of an arithmetic evalutation
# Code: get total number of lines using $(wc -l < ${FASTQ})
# Code: calculate read counts by dividing the total number of lines by 4, because a single read has 4 lines of information  
READS=$(( $(wc -l < ${FASTQ}) / 4 ))

#Create a header for the file (only if the file is empty)
# printf = a command to display formatted text and data (more functionality than echo command)
# -s = option to check count file only if the file exists and has content
[ -s ${COUNT_file} ] || printf "file\treads\n" >> ${COUNT_file}

# Store read counts in a text file
# -e = if the file exists (in this case, the COUNT_file), then add a line of text (echo) that has the FASTQ file name and total number of reads
echo -e "$(basename ${FASTQ})\t${READS}" >> ${COUNT_file}