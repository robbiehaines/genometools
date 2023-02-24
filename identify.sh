#fastANI script for very large checks >1000 genomes
#Ask which assembly to check
echo Which assembly to check [~/Desktop/assemblies/]:
read assembly
#Ask which genus it is
echo Which genus to check against [Case sensitive]:
read genus
#UNCOMMENT TO Ask for maximum hits 
#echo How many results to display? [1-99]
maxResults=99
#read maxResults

#start the split script
len=$(ls ~/Desktop/refseqs/${genus}/${genus}Lists | wc -l)
((len=len-2))
((files=len+1))
echo ${files} files found.
i=0
until [ $i -gt $len ]
do
	if [ $i -lt 10 ]; then filepath=0${i}; else filepath=${i}; fi
	cd ~/Desktop/refseqs/${genus}
	fastANI -t 12 -q ~/Desktop/assemblies/${assembly}/annotated/genome.fna --rl ~/Desktop/refseqs/${genus}/${genus}Lists/x${filepath} -o ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}_${filepath}.txt
	cd ~/Desktop
	((i=i+1))
done
#combine all files
cat ~/Desktop/temp/fastANI_report_${assembly}**.txt > ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}_UNSORTED.txt
#sort correctly
sort -t$'\t' -k3 -rn ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}_UNSORTED.txt > ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}.txt

##UNCOMMENT NEXT LINE IF YOU WANT A COPY OF THE RAW REPORT
#cp ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}.txt ~/Desktop/fastANI_report_${assembly}_with_${genus}.txt

#script can continue as per the single reflist
#Finding the fastANI report and taking the top hits $maxResults
cut -f 2 ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}.txt > ~/Desktop/temp/temp.txt
head -${maxResults} ~/Desktop/temp/temp.txt > ~/Desktop/temp/temp2.txt
rm -f ~/Desktop/temp/temp.txt

#Some logic to stop small and large requests from breaking
realMax=$(wc -l < ~/Desktop/temp/temp2.txt)
if [ $realMax -lt $maxResults ]; then maxResults=$realMax; fi
if [ $maxResults -ge 100 ]; then maxResults=99; fi

linenum=1
until [ ${linenum} -gt ${maxResults} ]
do
	#Decompress relevant .fna files to read the header, and then store the header somewhere else
	decompressFile=$(sed -n ${linenum}p ~/Desktop/temp/temp2.txt)
	if [ $linenum -lt 10 ]; then filenameNum=0${linenum}; else filenameNum=${linenum}; fi
	gzip -dk ~/Desktop/refseqs/${genus}/${decompressFile}
	mv ~/Desktop/refseqs/${genus}/**.fna ~/Desktop/temp
	head -1 ~/Desktop/temp/**.fna > ~/Desktop/temp/name.txt
	#Find the matching score and store it elsewhere
	sed -n ${linenum}p ~/Desktop/temp/fastANI_report_${assembly}_with_${genus}.txt > ~/Desktop/temp/temp3.txt
	cut -f 3 ~/Desktop/temp/temp3.txt > ~/Desktop/temp/temp4.txt
	#Merge the .fna header and the score together
	paste ~/Desktop/temp/name.txt ~/Desktop/temp/temp4.txt > ~/Desktop/temp/result${filenameNum}.txt
	#Clean up and prepare for next match
	rm -f ~/Desktop/temp/temp4.txt
	rm -f ~/Desktop/temp/temp3.txt
	rm -f ~/Desktop/temp/**.fna
	rm -f ~/Desktop/temp/name.txt
	((linenum=linenum+1))
done
#Join all matched .fna headers and scores into a single file
cat ~/Desktop/temp/result**.txt > ~/Desktop/${assembly}_for_${genus}.txt
#More cleaning up
rm -f ~/Desktop/temp/temp2.txt
rm -f ~/Desktop/temp/**.txt
#There are a lot of temporary files that get removed at the end as well as the fastANI report
#A better coder can probably fix that
