#!/bin/bash
#SBATCH --time=16:00:00
#SBATCH --job-name="qc"
#SBATCH --output=qc.out
#SBATCH --mail-user=myemail@domain.com
#SBATCH --mail-type=ALL
#SBATCH -p normal

start_time=$SECONDS

source activate conda_env_nextflow
cd /dir/containing/nf/script
nextflow run main.nf -c lugh.config --samplesheet mysamplesheet.csv --outdir /path/to/outdir/ 
elapsed=$(( SECONDS - start_time ))
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')"
