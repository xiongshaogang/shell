#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs"

now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

#得到上个月的月份，比如本月是200710,那么要得到的是200708
zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 2 ]
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
#MONTH="200903"


echo "ftp begin"
ftp -i -n 10.70.13.12 << EOF
user dxsjb duanxinshoujibao 
lcd /data1/home/jsusr1/center/scripts/spdz/SMSNEWS
bin
get $MONTH.txt
bye
EOF
echo "ftp end"
mv $MONTH.txt smsnews.txt 
sqlldr aijs/aijs@zmjs control=smsnews.ctl
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
update smsnews set fee=fee*100 where bill_month=to_char($MONTH);
commit;
update smsnews set hplmn2=replace(hplmn2,chr(13),'') where bill_month=to_char($MONTH);
commit;
update smsnews set fee_payed=fee where bill_month=to_char($MONTH);
commit;
exit
SQLEOF
mv smsnews.txt $MONTH.txt 
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_SMSNEWS($MONTH);
exit
SQLEOF

echo "OK! END"

exit 0


