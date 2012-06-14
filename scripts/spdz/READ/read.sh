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
#MONTH="201002"


#echo "ftp begin"
#ftp -i -n 10.211.122.4 << EOF
#user bossbill bossbill 
#lcd /data1/home/jsusr1/center/scripts/spdz/READ
#cd /lv_charge/tmp/bossbill
#bin
#get *zj*$MONTH.txt
#get *ws*$MONTH.txt
#bye
#EOF
#echo "ftp end"
mv *zj*$MONTH.txt cmreadzj.txt 
mv *ws*$MONTH.txt cmreadws.txt
sqlldr aijs/aijs@zmjs control=read_zj.ctl
sqlldr aijs/aijs@zmjs control=read_ws.ctl
#sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
#exit
#SQLEOF
mv cmreadzj.txt cmreadzj$MONTH.txt
mv cmreadws.txt cmreadws$MONTH.txt

echo "OK! END"

exit 0


