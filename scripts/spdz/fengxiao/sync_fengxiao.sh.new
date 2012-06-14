#!/bin/sh

#curmonth=`date +%Y%m`
curday=`date +%d`
#echo $curmonth
echo $curday

#得到上个月的月份，比如本月是200710,那么要得到的是200709
zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 1 ]
 then
  LAST_MONTH=`expr $curmonth - 1`
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
echo $MONTH


fileName=DOIMFARE*.$MONTH
fileName2=DOIMFPRODUCT*.$MONTH
echo $fileName
echo $fileName2
#if [ "$curday" = "02" ]; then    #每月2号取网络分销的数据
if true; then
echo "getting files"
#---------------------------ftp--------------------------#
ftp -i -n 10.70.194.36  << EOF
user boss boss 
cd /usr/linghui/programer/work/doimf/doimfbackground/outputdata/out/boss/month
bin
prom off
mget $fileName 
prom on
prom off
mget $fileName2 

bye
EOF
#---------------------------end---------------------------#
cp -f $fileName DOIMFARE.txt
cp -f $fileName2 DOIMFPRODUCT.txt

sqlldr aijs/aijs@zmjs control=DOIMFARE.ctl
sqlldr aijs/aijs@zmjs control=DOIMFPRODUCT.ctl

rm -f DOIMFARE.txt
rm -f DOIMFPRODUCT.txt
fi

DB_CONNECT_STRING="aijs/aijs@zmjs" 
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
#去除字段中的换行符
update fenxiao_user set prod_fee=replace(prod_fee,chr(13),'') where count_date=$MONTH;
update fenxiao_user set user_code='fenxiao' where count_date=$MONTH;
update fenxiao_prod set user_code='fenxiao',remuneration_back=replace(remuneration_back,chr(13),'') where count_date=$MONTH;
commit;
exit
SQLEOF

exit 0

