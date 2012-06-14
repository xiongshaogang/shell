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


logfile=$logpath/spdz/contentfee_${now}.log

# 退费上报文件
contentfee_file=/data1/home/jsusr1/center/uploadfile/DED/DED${curdate}$1.571	# DEDYYYYMMDDNNN.ZZZ
#contentfee_file=/data1/home/jsusr1/center/scripts/spdz/DED${curdate}$1.571
curfile=DED${curdate}$1.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile

if [ -f "$contentfee_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $contentfee_file $contentfee_file.bak.$now
	#exit -1
fi

# 文件头记录
blanks=`printf "%104s" " "`
head="1046000571  46000000  $1${now}01$blanks\r\n"
echo "$head\c" > $contentfee_file

linefmt="000000000000000000000                                                                                                   "

# contentfee_file tail
tail="9046000000  46000571  $1$linefmt"
echo "$tail\r" >> $contentfee_file

echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$contentfee_file"

echo "ftp $curfile"
#--------------------------------------------------------------------#
echo begin

ftp -i -n 10.254.48.12  << EOF
user mcb3tran mcB3!571 
lcd /data1/home/jsusr1/center/uploadfile/DED
cd /opt/mcb/pcs/cbbs/ded/data/outgoing/
bin
prom off
put $curfile 
bye
EOF

--------------------------------------------------------------------#  

echo "A-OK!"

exit 0
