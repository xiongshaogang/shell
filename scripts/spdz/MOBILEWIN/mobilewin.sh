#!/bin/sh
################################################################################
# Script to generate ���ݼƷѺ˼������ϱ��ļ�
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING�����������ݿ����Ӵ�
# �ϴ�����10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 

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
echo begin

ftp -i -n 10.70.96.68 <<EOF
user yddyj dyjdata@zj
cd /data
bin
get dyjresult_$MONTH.txt 
bye
EOF


mv dyjresult*$MONTH.txt dyjresult.txt

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
delete from mobilewin where bill_month=$MONTH;
commit;
exit 
SQLEOF

sqlldr aijs/aijs@zmjs control=mobilewin.ctl

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
update mobilewin set bill_month=$MONTH where bill_month is null;
commit;
insert into mobilewin values(0,'��������',0,$MONTH);
commit;
exit
SQLEOF

mv dyjresult.txt dyjresult_$MONTH.txt

echo "A-OK"
exit 0
