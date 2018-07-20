#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=100G
#SBATCH --time=40:00:00
#SBATCH --output=run_speedseq_qsub.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./

#sbatch --array 1 run_speedseq_qsub.sh

module load samtools
PATH=$PATH:~/BigData/software/SVcaller/ROOT/bin/
genome=~/BigData/00.RD/Assembly/Pacbio/Reference/Fairchild/Fairchild_v1.fasta

CPU=$SLURM_NTASKS
if [ ! $CPU ]; then
   CPU=2
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
    N=$1
fi

echo "CPU: $CPU"
echo "N: $N"

FILE=`ls *_1.fastq.gz | grep _1\.fastq\.gz | head -n $N | tail -n 1`
R1=$FILE
R2=`echo $R1 | perl -p -e 's/_1\.fastq/_2.fastq/'`
SAMPLE=${FILE%_1.fastq.gz}
echo "File: $FILE"
echo "Read: $R1 and $R2"
echo "Sample: $SAMPLE"

if [ ! -e $SAMPLE\.bam ]; then
echo "mapping $SAMPLE ..."
/bigdata/stajichlab/cjinfeng/software/SVcaller/speedseq_20161206/speedseq/bin/speedseq align \
     -t $CPU \
     -o $SAMPLE \
     -R "@RG\tID:id\tSM:$SAMPLE\tLB:lib" \
     $genome \
     $SAMPLE\_1.fastq.gz \
     $SAMPLE\_2.fastq.gz
fi

echo "Done"
