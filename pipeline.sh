#temporary automation loop for my 33 samples
#i=1
#until [ $i -gt 33 ]
#do
#	if [ $i -lt 10 ]; then genomeNum=0${i}; else genomeNum=${i}; fi
#	

#For this to work put all 8 files (forward and reverse for each lane in the ~/Desktop/assemblies folder in its own directory and enter this when prompted
mkdir ~/Desktop/rRNA
mkdir ~/Desktop/16S
mkdir ~/Desktop/16S/clean
#Get input information (4 lane paired Illumina)
echo Read location:
read genomeNum
contigMax=200
qtrim=20

#Concatenate forward and reverse reads
echo concatenating
cat ~/Desktop/assemblies/$genomeNum/*R1* > ~/Desktop/assemblies/$genomeNum/1.fastq
cat ~/Desktop/assemblies/$genomeNum/*R2* > ~/Desktop/assemblies/$genomeNum/2.fastq
echo finished concatenating

#BBDuk (Trimming)
echo trimming with bbduk
bash ~/Desktop/bbmap/bbduk.sh ktrimright=t k=27 hdist=1 edist=0 ref=adapters.fa qtrim=r trimq=$qtrim minlength=100 ordered=t qin=33 in1=~/Desktop/assemblies/$genomeNum/1.fastq in2=~/Desktop/assemblies/$genomeNum/2.fastq out1=~/Desktop/assemblies/$genomeNum/_1.fastq out2=~/Desktop/assemblies/$genomeNum/_2.fastq
echo finished trimming with bbduk

#SPAdes (Contig assembly)
echo assembling with SPAdes
cd /
cd ~/Desktop/spades/bin
spades.py --careful -1 ~/Desktop/assemblies/$genomeNum/_1.fastq -2 ~/Desktop/assemblies/$genomeNum/_2.fastq -o ~/Desktop/assemblies/$genomeNum/SPAdes
cd /
cd ~/Desktop
echo finished assembling with SPAdes

#Cull contigs with bbduk
echo culling contigs less than or equal to $contigMax bases
bash ~/Desktop/bbmap/reformat.sh in=~/Desktop/assemblies/$genomeNum/SPAdes/contigs.fasta out=~/Desktop/assemblies/$genomeNum/FinalContigs/contigs.fasta minlength=200
echo cull complete
echo 

#Annotate with dfast
echo annotating with dfast as best as possible
dfast --genome ~/Desktop/assemblies/$genomeNum/FinalContigs/contigs.fasta -o ~/Desktop/assemblies/$genomeNum/annotated --no_hmm
echo

###############################
#Extract 16S region separately#
###############################
#Pull all rRNA out
barrnap ~/Desktop/assemblies/$genomeNum/FinalContigs/contigs.fasta --outseq ~/Desktop/rRNA/${genomeNum}.fasta
#Pull only 16S sequences out
grep -A 1 ">16S" ~/Desktop/rRNA/${genomeNum}.fasta > ~/Desktop/16S/${genomeNum}.fasta
#Rename to something sensible
bash ~/Desktop/bbmap/rename.sh in=~/Desktop/16S/${genomeNum}.fasta out=~/Desktop/16S/clean/${genomeNum}.fasta prefix=Sample${genomeNum}_16S


#((i=i+1))
#done

#Join all files together and get rid of the trash
cat ~/Desktop/16S/clean/* > ~/Desktop/assemblies/16S.fasta
rm -r ~/Desktop/16S
rm -r ~/Desktop/rRNA

