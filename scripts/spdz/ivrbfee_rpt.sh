#!/bin/sh
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
cur_month=`date +%Y%m`

zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 1 ]
 then
    LAST_MONTH=`expr $curmonth - 2`
    if [ $LAST_MONTH -lt 10 ]
    then
      MONTH="$CURRENT_YEAR$zeros$LAST_MONTH"
    else
      MONTH="$CURRENT_YEAR$LAST_MONTH"
    fi
 else
   LAST_MONTH=12
   MONTH="$LAST_YEAR$LAST_MONTH"
fi
#MONTH="200912"
echo "$MONTH"
logfile=$logpath/spdz/ivrbfee_${now}.log
# 退费上报文件
bfee_file=/data1/home/jsusr1/center/uploadfile/ivr/BFIVR${cur_month}000.571	# BFEEYYYYMMNNN.ZZZ

# clear
echo - This will take a few minutes, pls wait ...

if true; then
################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_IVR($MONTH);
set line 250;
set pagesize 5000; 
spool $logfile;

select '20',serv_type,sp_code,operator_code,bill_month,bfee from ivr_bfee where bill_month=$MONTH and serv_type in ('003','004','103','008','007','009','010','109','110','201');

spool off;
exit
SQLEOF
################################################################################
fi

#cat $logfile

if [ -f "$bfee_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $bfee_file $bfee_file.bak.$now
	#exit -1
fi

# bfee_file head
blanks=`printf "%33s" " "`
head="1046000571  46000000  000${now}01$blanks\r\n"
echo "$head\c" > $bfee_file

# bfee_file body
awk ' /^20/ { printf("%2s%3s%-10s%-20s%-8s%012.f%19s\r\n", $1,$2,$3,$4,$5,$6," ") }' $logfile >> $bfee_file

cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $6 } END { printf("lines:%d sum: %f \r\n", n, s) }'
linefmt=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $6 } END { printf("%09d%012.f%28s", n, s, " ") }'`
# lines=`awk ' /^20/ { print $1 }' $logfile | wc -l`
# fee=`cat $logfile | awk '/^20/ {print}' | awk '{ s+=$6} END { printf("%12.f", s) }'`
# linefmt=`printf "%09d%012.f%28s" $lines $fee " "`
echo $linefmt

# bfee_file tail
tail="9046000000  46000571  000$linefmt"
echo "$tail\r" >> $bfee_file


echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$bfee_file"


echo "ftp $bfee_file"
#--------------------------------------------------------------------#
base_bfee_file=`basename $bfee_file`
echo begin
#ftp -i -n 10.254.48.12  << EOF
#user mcb3tran mcB3!571 
#lcd /data1/home/jsusr1/center/uploadfile/ivr
#cd /opt/mcb/pcs/data/source 
#bin
#prom off
#put $base_bfee_file 
#bye
#EOF
#--------------------------------------------------------------------#  

echo "A-OK!"

exit 0

