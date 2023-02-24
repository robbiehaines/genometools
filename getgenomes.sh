#working directory is important here probably
cd ~/Desktop/refseqs

#A fair warning
echo Warning: You are about to look into the NCBI refseq database
echo and download every assembly for a specified genus. 
echo
echo This may take a very long time when the database contains many assemblies
echo such as Staphylococcus or Escherichia. Press [Ctrl+C] to end the program.
echo
#ask for genus (case sensitive)
echo Enter genus [case sensitive]
read genus

#Always get a new database, it is only around 100MB ask for refseq update
echo Fetching the NCBI refseq database...
rsync -t -q rsync://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt ./

###DEPRECATED CODE <start>###
#This section is if you wanted to make a new refseq database option
#echo Do we require a new copy of the refseq database? [y/n]
#read refseqneeded
#if [ $refseqneeded = 'n' ]; then echo No download needed; fi
#if [ $refseqneeded = 'y' ]; then rm -f ~/Desktop/refseqs/assembly_summary_refseq.txt | rsync -t -q rsync://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt ./; fi
####DEPRECATED CODE <end>####

#generate ftp links list
grep -E ${genus}* assembly_summary_refseq.txt | cut -f 20 > ~/Desktop/refseqs/${genus}_ftp.txt
assemblyCount=$(wc -l < ~/Desktop/refseqs/${genus}_ftp.txt)
echo Downloading ${assemblyCount} assemblies...
mkdir ~/Desktop/refseqs/${genus}
cd ~/Desktop/refseqs/${genus}
awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print "rsync -t -q "ftpdir,file" ./"}' ~/Desktop/refseqs/${genus}_ftp.txt | sed 's/https/rsync/g' > ~/Desktop/refseqs/${genus}.sh
bash ~/Desktop/refseqs/${genus}.sh

#Prepare list for fastANI
echo Preparing files for fastANI...
cd ~/Desktop/refseqs/${genus}
ls > ~/Desktop/refseqs/${genus}_list.txt
cd ~/Desktop

#split into 500 assembly lists
echo Splitting files for fastANI...
mkdir ~/Desktop/refseqs/${genus}/${genus}Lists
mv ~/Desktop/refseqs/${genus}_list.txt ~/Desktop/refseqs/${genus}/${genus}Lists
cd ~/Desktop/refseqs/${genus}/${genus}Lists
split -l 500 -a 2 -d ~/Desktop/refseqs/${genus}/${genus}Lists/${genus}_list.txt
cd ~/Desktop

#remove generated scripts
echo Cleaning up...
rm -f ~/Desktop/refseqs/${genus}_ftp.txt
rm -f ~/Desktop/refseqs/${genus}.sh
rm -f ~/Desktop/refseqs/assembly_summary_refseq.txt

echo Completed

