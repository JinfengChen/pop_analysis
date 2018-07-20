echo "download mandarin fastq: MP wild mandarin"
python SRA_down.py --input SRA.list > log 2>&1 &
python SRA_merge.py --input Citrus_RNAseq/ > log 2>&1 &

echo "rename"
mkdir Mandarin_fastq
mv Citrus_RNAseq/*/*.gz Mandarin_fastq/
python name.py --input Mandarin_fastq/ --table SRA.list > Mandarin_fastq.mv.sh
bash Mandarin_fastq.mv.sh

echo "subsample"
mkdir subsample
cd subsample/
mv ../Mandarin_fastq/CM14_* ./
batch -p batch --array 1-2 subsample_fq.sh


#SRA_NG_2017_Xu.list
#Mandarin from NG 2017 Xu are all included in MP wild mandarin dataset except two.
#There two are not used in there comparative analysis either in the NG paper.
python ~/BigData/software/bin/listdiff.py SRA.list SRA_NG_2017_Xu.list | less -S


#SRA_Nature_2018_Wu.list
python SRA_down.py --input SRA_Nature_2018_Wu.list > log 2>&1 &
python SRA_merge.py --input Citrus_RNAseq > log 2>&1 &
python name.py --input Mandarin_fastq --table SRA_Nature_2018_Wu.list > Mandarin_fastq.Nature_2018.mv.sh 
bash Mandarin_fastq.Nature_2018.mv.sh


#Fairchild
ln -s ~/BigData/00.RD/Assembly/Pacbio/Citrus_Pollen/fastq/Fairchild_1.fastq.gz Mandarin_fastq/FCM_1.fastq.gz
ln -s ~/BigData/00.RD/Assembly/Pacbio/Citrus_Pollen/fastq/Fairchild_2.fastq.gz Mandarin_fastq/FCM_2.fastq.gz

