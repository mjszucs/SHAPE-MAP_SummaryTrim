Hey yall,

Before you run the SHAPE-Mapper2 pipeline, it is useful to assess the quality of the sequencing reads and perform adapter trimming. This repository contains a snakefile that will do just that. 

This snakefile will: 
1. Rename the files for use with shapemapper2
2. Perform initial QC with fastqc and multiqc
3. Trim adapters from sequencing reads 
4. Perform QC on the trimmed reads
5. Output correctly named files for shapemapper2 analysis



How to use: 

This part is hyperspecific to our current situation:
	-DMS or 1m7 library prepped with the Illumina Nextera kit
	-Performing all of the analysis on the Kieftserv
	
Step1: Place the raw files from Novogene in the reads folder. Make sure these files are only the forward and reverse reads from one experimental condition. For example, you will only want to add the forward and reverse reads from the 1m7 modified rep1 you have. 
	-Make sure the file extention is .fq.gz and you do not change anything. 


Step2: Initiate the snakemake environment using the conda package manager.

conda activate snakemake


Step3: Run snakemake

snakemake -cores 10

Step4: Wait