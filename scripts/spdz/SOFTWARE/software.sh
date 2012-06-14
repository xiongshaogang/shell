#!/bin/sh

DB_CONNECT_STRING="aijs/aijs@zjtstjs" 

now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`


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

echo $MONTH

#--------------------------------------------------------------------#
#echo begin
#手机软件的FTP服务器尚不清楚,此处需要修改
#ftp -i -n 10.70.96.68 <<EOF
#user yddyj dyjdata@zj
#cd /data
#bin
#get software$MONTH.txt 
#bye
#EOF


mv software$MONTH.txt software.txt

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
delete from plt_software where bill_month=$MONTH;
commit;
exit 
SQLEOF

sqlldr aijs/aijs@zjtstjs control=software.ctl


mv software.txt software$MONTH.txt

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_SOFTWARE($MONTH);
exit 
SQLEOF


echo "A-OK"
exit 0
