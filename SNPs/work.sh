sbatch -p batch --array 1-50 Multiple_sample_GATK_HC.sh
sbatch -p batch Multiple_sample_GATK_Merge.sh
sbatch -p batch Multiple_sample_GATK_Filter.sh

