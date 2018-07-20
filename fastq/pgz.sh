#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --mem=20G
#SBATCH --time=10:00:00
#SBATCH --output=pgz.sh.stdout
#SBATCH -p intel
#SBATCH --workdir=./


for i in `ls *.fastq | sed 's/@//'`
do
   echo $i
   if [ ! -e $i.gz ]; then
      pigz $i -p 16
      chmod 664 $i.gz
      #gzip $i
   fi
done

echo "Done"
