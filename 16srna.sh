mkdir ~/Desktop/rRNA
mkdir ~/Desktop/16S
mkdir ~/Desktop/16S/clean
#Automation loop
i=1
until [ $i -gt 33 ]
do
	if [ $i -lt 10 ]; then genomeNum=0${i}; else genomeNum=${i}; fi
barrnap ~/Desktop/assemblies/$genomeNum/FinalContigs/contigs.fasta --outseq ~/Desktop/rRNA/${genomeNum}.fasta
grep -A 1 ">16S" ~/Desktop/rRNA/${genomeNum}.fasta > ~/Desktop/16S/${genomeNum}.fasta
bash ~/Desktop/bbmap/rename.sh in=~/Desktop/16S/${genomeNum}.fasta out=~/Desktop/16S/clean/${genomeNum}.fasta prefix=MNWGS${genomeNum}_16S
((i=i+1))
done
cat ~/Desktop/16S/clean/* > ~/Desktop/16S.fasta
echo 16S Extract complete
