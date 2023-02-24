#Automation loop
i=1
until [ $i -gt 33 ]
do
	if [ $i -lt 10 ]; then genomeNum=0${i}; else genomeNum=${i}; fi
rm ~/Desktop/assembliesforcompression/$genomeNum/**

#continue here
((i=i+1))
done

