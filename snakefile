#the purpose of this snakefile is to preprocess all of the sequencing data that we get back
#and get it trimmed with all of the mutliqc
#V1.0 - I basically added some lines to make the output .fastq and also add either R1 or R2 at the end of the file name.
import os

os.chdir(os.getcwd()) # change the directory to the directory this snakefile is located
wd_name = os.path.basename(os.getcwd()) #get the name of the working directory
wd = os.getcwd() + "/reads/" # gets the full path name to these files
filelist = os.listdir("reads/") #list all of the files in the reads directory

for x in filelist:
    if x[-7] == "1":
        os.rename(wd + str(x), wd + str(wd_name)+"_R1.fq.gz")
    elif x[-7] == "2":
        os.rename(wd + str(x), wd + str(wd_name)+"_R2.fq.gz")
    else:
        print("youfuckedupsomewherekehd")

s = os.listdir("reads/") # list all the files in the reads directory
S = [] # Create an open list
for x in s:
    if x[0]  == ".":
        pass
    else:
        S.append(x[:-9]) # Trim name so it is just the base without the r1

SAMPLES = list(set(S)) # this will give the unique names present in the folder since there are going to be
#replicated since there are R1 and R2 present.

rule all:
    input:
        # expand("qc/fastqc/{sample}.html", sample = SAMPLES),
        # expand("qc/fastqc/{sample}.fastqc.zip", sample = SAMPLES)
        "qc/multiqc/multiqc_report.html",
        expand("trimmed/paired/{sample}_forward_paired_R1.fastq.gz", sample = SAMPLES),
        expand("trimmed/unpaired/{sample}_forward_unpaired_R1.fastq.gz", sample = SAMPLES),
        expand("trimmed/paired/{sample}_revers_paired_R2.fastq.gz", sample = SAMPLES),
        expand("trimmed/unpaired/{sample}_revers_unpaired_R2.fastq.gz", sample = SAMPLES),
        "trimmed/paired/qc/multiqc/multiqc_report.html"

rule fastqc:
    input:
        expand("reads/{sample}_{reps}.fq.gz", sample = SAMPLES, reps = ["R1","R2"])
    output:
        expand("qc/{sample}_{reps}_fastqc.html", sample = SAMPLES,reps = ["R1","R2"]),
        expand("qc/{sample}_{reps}_fastqc.zip", sample = SAMPLES,reps = ["R1","R2"]) # the suffix _fastqc.zip is necessary for multiqc to find the file. If not using multiqc, you are free to choose an arbitrary filename
    conda:
        "envs/environment.yaml"
    shell:
        "fastqc {input} --outdir qc/"


rule multiqc:
    input:
        expand("qc/{sample}_{reps}_fastqc.html", sample= SAMPLES, reps = ["R1","R2"])
    output:
        "qc/multiqc/multiqc_report.html"

    conda:
        "envs/environment.yaml"
    shell:
        "multiqc qc -o qc/multiqc/"


rule trimmomatic:
    input:
        forward = "reads/{sample}_R1.fq.gz",
        revers = "reads/{sample}_R2.fq.gz",
    output:
        forward_paired = "trimmed/paired/{sample}_forward_paired_R1.fastq.gz",
        forward_unpaired = "trimmed/unpaired/{sample}_forward_unpaired_R1.fastq.gz",
        revers_paired = "trimmed/paired/{sample}_revers_paired_R2.fastq.gz",
        revers_unpaired = "trimmed/unpaired/{sample}_revers_unpaired_R2.fastq.gz"
    message: "Trimming Illumina adapters from {input.forward} and {input.revers}"
    shell:
        """
        java -jar /data/home/szucsm/Trimmomatic-0.39/trimmomatic-0.39.jar PE -phred33 \
        {input.forward} {input.revers} \
        {output.forward_paired} {output.forward_unpaired} \
        {output.revers_paired} {output.revers_unpaired} \
        ILLUMINACLIP:/data/home/szucsm/Trimmomatic-0.39/adapters/NexteraPE-PE.fa:2:30:10:8:TRUE LEADING:3 TRAILING:3 SLIDINGWINDOW:3:15 MINLEN:35
        """

rule fastqc_2:
    input:
        expand("trimmed/paired/{sample}_forward_paired_R1.fastq.gz", sample = SAMPLES),
        expand("trimmed/paired/{sample}_revers_paired_R2.fastq.gz", sample = SAMPLES)
    output:
        expand("trimmed/paired/qc/{sample}_forward_paired_R1_fastqc.html", sample = SAMPLES),
        expand("trimmed/paired/qc/{sample}_forward_paired_R1_fastqc.zip", sample = SAMPLES),
        expand("trimmed/paired/qc/{sample}_revers_paired_R2_fastqc.html", sample = SAMPLES),
        expand("trimmed/paired/qc/{sample}_revers_paired_R2_fastqc.zip", sample = SAMPLES)
    conda:
        "envs/environment.yaml"
    shell:
        "fastqc {input} --outdir trimmed/paired/qc"

rule multiqc_2:
    input:
        expand("trimmed/paired/{sample}_forward_paired_R1.fastq.gz", sample = SAMPLES),
        expand("trimmed/paired/{sample}_revers_paired_R2.fastq.gz", sample = SAMPLES)
    output:
        "trimmed/paired/qc/multiqc/multiqc_report.html"
    conda:
        "envs/environment.yaml"
    shell:
        "multiqc trimmed/paired/qc -o trimmed/paired/qc/multiqc/"
