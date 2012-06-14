#!/bin/sh

now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
yestoday=$((curdate-1))
echo $yestoday
ftp -i -n 10.70.11.77  << EOF
user mcb3tran mcB3!571 
bin
prom off
lcd /data1/home/jsusr1/center/uploadfile/EDED
cd /opt/mcb/pcs/cbbs/ded/error/incoming
mget *$yestoday*
bye
EOF

exit 0
