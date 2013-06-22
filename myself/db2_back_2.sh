#!/bin/bash
echo  "db2 connect to masdb"
db2 connect to masdb 

for d in 0 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
do
echo "===============export$y$d================="
db2 'export to 12$d.csv of del select msg_status,recv_status,sendtime,destaddr from tbl_smresult_$y$d'>>$db2file
done

a.sh  12

#!/bin/bash
echo "input month"
y=$1

echo  "db2 connect to masdb"


db2 connect to masdb 
echo "make db2datebase"
db2file=db2datebase
touch $db2file
case $y in
  [1,3,5,7,8,10,12])
  echo $y
for d in 0 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
do
echo "===============export$y$d================="
db2 'export to $y$d.csv of del select msg_status,recv_status,sendtime,destaddr from tbl_smresult_$y$d'>>$db2file
done
;;
  [4,6,9,11])
echo $y
for d in 0 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30
do
echo "===============export$y$d================="
db2 'export to $y$d.csv of del select msg_status,recv_status,sendtime,destaddr from tbl_smresult_$y$d'>>$db2file
done
    ;;
  esac
  ;;
esac
