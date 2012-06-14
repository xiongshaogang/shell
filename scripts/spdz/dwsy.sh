#!/bin/sh
################################################################################
# Script to generate 内容计费核减数据上报文件
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 上传至：10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 


logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

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
echo "$MONTH"


sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

exec PRC_ZY_DWSY($MONTH);
exec PRC_ZY_GPRS($MONTH,1);
exit
SQLEOF

echo "A-OK!"

exit 0
