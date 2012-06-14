

if [ $# -ge 1 ]; then
        path=$1
else
        path="."
fi
file=${path}/N_

echo "DATE\t\tCOUNT"
for t in $(ls -1 ${file}*|cut -d _ -f 5|cut -c 1-8|sort|uniq)
do
        n=`ls ${file}*${t}*|wc -w`
        echo "${t}\t${n}"
done

echo "--- DONE ---"
