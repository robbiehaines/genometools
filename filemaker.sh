i=1
until [ $i -gt 33 ]
do
	if [ $i -lt 10 ]; then genomeNum=0${i}; else genomeNum=${i}; fi
	echo $genomeNum
	((i=i+1))
done
