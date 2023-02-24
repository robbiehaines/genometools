cd ~/Desktop
echo Which assembly number?
read asmNum
cat ${asmNum}**.txt > ${asmNum}cat.txt
sort -t$'\t' -k2 -rn ${asmNum}cat.txt > Report_for_${asmNum}.txt
rm -f ${asmNum}**.txt
