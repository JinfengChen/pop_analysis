#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=100G
#SBATCH --time=40:00:00
#SBATCH --output=Run_EIG.sh.%A_%a.stdout
#SBATCH -p intel
#SBATCH --workdir=./

#sbatch --array 1 run_speedseq_qsub.sh


start=`date +%s`

CPU=$SLURM_NTASKS
if [ ! $CPU ]; then
   CPU=2
fi

N=$SLURM_ARRAY_TASK_ID
if [ ! $N ]; then
    N=1
fi

echo "CPU: $CPU"
echo "N: $N"

~/BigData/00.RD/Assembly/Pacbio/Pangenome/SNPs_PCA/EIG/bin/smartpca -p Mandarin.input
#~/BigData/00.RD/Assembly/Pacbio/Pangenome/SNPs_PCA/EIG/bin/ploteig -i Mandarin.EIG.evec -c 1:2 -p Wild:Hybrid:Cultivar_M1:Cultivar_M2 -x
~/BigData/00.RD/Assembly/Pacbio/Pangenome/SNPs_PCA/EIG/bin/ploteig -i Mandarin.EIG.evec -c 1:2 -p Wild:Hybrid:Cultivar_M1:Cultivar_M2 -x -o Mandarin.EIG.plot.xtxt

end=`date +%s`
runtime=$((end-start))

echo "Start: $start"
echo "End: $end"
echo "Run time: $runtime"

echo "Done"
