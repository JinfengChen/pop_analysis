echo "prepare chromosome only vcf"
ln -s ~/BigData/00.RD/Assembly/Pacbio/Pangenome/SNPs/Mandarin.pass.SNP.vcf ./
grep -v "^scaf" Mandarin.pass.SNP.vcf > Mandarin.pass.SNP.chr.vcf

echo "convert vcf to eigenstrat input"
python ../gdc/vcf2eigenstrat.py -v Mandarin.pass.SNP.chr.vcf -o Mandarin.EIG

echo "run eigenstrat"
sbatch -p stajichlab Run_EIG.sh
