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
#DB_CONNECT_STRING="newjs/newjs@testjs"	#testjs


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

logfile=$logpath/spdz/DIMPP_${now}.log

# 退费上报文件
#contentfee_file=/data1/home/jsusr1/center/uploadfile/DED/DED${curdate}$1.571	# DEDYYYYMMDDNNN.ZZZ
dimpp_file=/data1/home/jsusr1/center/scripts/spdz/DIMP_P_${MONTH}000.571
curfile=DIMP_P_${MONTH}000.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile


# 文件头记录
blanks=`printf "%39s" " "`
head="1046000571          46000000  000                    ${now}01$blanks\r\n"
echo "$head\c" > $dimpp_file

#linefmt="000000000000000000000                                                                                                   "
blanks=`printf "%66s" " "`
# contentfee_file tail
tail="9046000000          46000571  000000000000$blanks\r\n"
echo "$tail\c" >> $dimpp_file


echo "ftp $curfile"
#--------------------------------------------------------------------#
echo begin

#ftp -i -n 10.70.11.77  << EOF
#user mcb3tran mcB3!571 
#cd /opt/mcb/pcs/cbbs/impp/data/outgoing/
#bin
#prom off
#put $curfile 
#bye
#EOF
#--------------------------------------------------------------------#  

echo "A-OK!"

exit 0
