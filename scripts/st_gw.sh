#!/bin/sh

if [ $# -ge 1 ]; then
        path=$1
else
        path="."
fi
file=${path}/N_GSM

echo $PWD
echo "Gateway\t\tCount"
for t in $(ls -1 ${file}*|cut -d _ -f 3-4|sort|uniq)
do
        n=`ls ${file}*${t}*|wc -w`
        echo "${t}\t${n}"
done

total=`ls ${file}*|wc -w`
echo "Total\t\t$total"

echo "--- DONE ---"
