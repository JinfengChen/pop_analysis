#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem-per-cpu=2G
#SBATCH --time=100:00:00
#SBATCH --output=Multiple_sample_GATK_Filter.sh.%A_%a.stdout
#SBATCH -p intel
#SBATCH --workdir=./


#https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php
#https://gatkforums.broadinstitute.org/gatk/discussion/5987/is-indel-realignment-necessary-when-haplotypecaller-re-assembles-all-reads-in-a-region
GATK=/opt/linux/centos/7.x/x86_64/pkgs/gatk/3.8/GenomeAnalysisTK.jar
Picard=/opt/linux/centos/7.x/x86_64/pkgs/picard/2.6.0/bin/picard
JAVA=/opt/linux/centos/7.x/x86_64/pkgs/java/jdk1.8.0_45/bin/java
samtools=/opt/linux/centos/7.x/x86_64/pkgs/samtools/0.1.19/bin/samtools
genome=~/BigData/00.RD/Assembly/Pacbio/Reference/Fairchild/Fairchild_v1.fasta


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

echo "Multi-sample SNP calling from illumina: Step 3. Hard filter"

#snp merge
merge_vcf=Mandarin.raw.vcf
prefix=${merge_vcf%.raw.vcf}

if [ ! -e $prefix.raw.SNP.vcf ]; then
$JAVA -Xmx40g -jar $GATK \
      -T SelectVariants \
      -R $genome \
      -V $merge_vcf \
      -selectType SNP \
      -o $prefix.raw.SNP.vcf
fi

if [ ! -e $prefix.raw.INDEL.vcf ]; then
$JAVA -Xmx40g -jar $GATK \
      -T SelectVariants \
      -R $genome \
      -V $merge_vcf \
      -selectType INDEL \
      -o $prefix.raw.INDEL.vcf
fi

###hardfilter indel
if [ ! -e $prefix.pass.INDEL.vcf ]; then
$JAVA -Xmx1g -jar $GATK \
      -T VariantFiltration \
      -R $genome \
      --variant $prefix.raw.INDEL.vcf \
      -o $prefix.raw.INDEL.hardfilter.vcf \
      --filterExpression "QD < 2.0" \
      --filterName "QDFilter" \
      --filterExpression "ReadPosRankSum < -20.0" \
      --filterName "ReadPosFilter" \
      --filterExpression "FS > 200.0" \
      --filterName "FSFilter" \
      --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
      --filterName "HARD_TO_VALIDATE" \
      --filterExpression "QUAL < 30.0 || DP < 6 || DP > 5000 || HRun > 5" \
      --filterName "QualFilter"

$JAVA -Xmx1g -jar $GATK -T SelectVariants -R $genome --variant $prefix.raw.INDEL.hardfilter.vcf -o $prefix.pass.INDEL.vcf --excludeFiltered

fi

###hardfilter snp
if [ ! -e $prefix.raw.SNP.hardfilter.vcf ]; then
$JAVA -Xmx1g -jar $GATK \
      -T VariantFiltration \
      -R $genome \
      --variant $prefix.raw.SNP.vcf \
      -o $prefix.raw.SNP.hardfilter.vcf \
      --clusterSize 3 \
      --clusterWindowSize 10 \
      --filterExpression "QD < 2.0" \
      --filterName "QDFilter" \
      --filterExpression "MQ < 40.0" \
      --filterName "MQFilter" \
      --filterExpression "FS > 60.0" \
      --filterName "FSFilter" \
      --filterExpression "AF < 0.05" \
      --filterName "Allele Frequency Filter" \
      --filterExpression "HaplotypeScore > 13.0" \
      --filterName "HaplotypeScoreFilter" \
      --filterExpression "MQRankSum < -12.5" \
      --filterName "MQRankSumFilter" \
      --filterExpression "ReadPosRankSum < -8.0" \
      --filterName "ReadPosRankSumFilter" \
      --filterExpression "QUAL < 30.0 || DP < 6 || DP > 5000 || HRun > 5" \
      --filterName "StandardFilters" \
      --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
      --filterName "HARD_TO_VALIDATE" \
      --genotypeFilterExpression "DP < 4 || DP > 150" \
      --genotypeFilterName "DP4_150" \
      --mask $prefix.pass.INDEL.vcf \
      --maskExtension 5 \
      --maskName "INDEL"
fi

if [ ! -e $prefix.pass.SNP.vcf ]; then
$JAVA -Xmx1g -jar $GATK -T SelectVariants -R $genome --variant $prefix.raw.SNP.hardfilter.vcf -o $prefix.pass.SNP.vcf --excludeFiltered --setFilteredGtToNocall --maxFilteredGenotypes 0 --maxNOCALLnumber 0 --excludeNonVariants -select 'vc.isBiallelic() && AF > 0.2'
python Filter_SNP.py --input $prefix.pass.SNP.vcf
fi

echo "Done!"
