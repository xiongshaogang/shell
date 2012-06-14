#!/bin/sh
################################################################################
# Script to generate �ֻ���Ϸ�˼������ϱ��ļ�
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING�����������ݿ����Ӵ�
# �ϴ�����10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 
#DB_CONNECT_STRING="newjs/newjs@testjs"	#testjs


logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`


logfile=$logpath/spdz/mobilegame_${now}.log

# �˷��ϱ��ļ�
mobilegame_file=/data1/home/jsusr1/center/uploadfile/DGP/DGP${curdate}$1.571	# DEDYYYYMMDDNNN.ZZZ

curfile=DGP${curdate}$1.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile

if [ -f "$mobilegame_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $mobilegame_file $mobilegame_file.bak.$now
	#exit -1
fi

# �ļ�ͷ��¼
blanks=`printf "%124s" " "`
head="1046000571  46000000  $1${now}01$blanks\r\n"
echo "$head\c" > $mobilegame_file

linefmt="000000000000000000000                                                                                                                       "

# mobilegame_file tail
tail="9046000000  46000571  $1$linefmt"
echo "$tail\r" >> $mobilegame_file

echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$mobilegame_file"

echo "ftp $curfile"
#--------------------------------------------------------------------#
echo begin

ftp -i -n 10.254.48.12  << EOF
user mcb3tran mcB3!571 
lcd /data1/home/jsusr1/center/uploadfile/DGP
cd /opt/mcb/pcs/cbbs/ded/data/outgoing/
bin
prom off
put $curfile 
bye
EOF
#--------------------------------------------------------------------#  

echo "A-OK!"

exit 0
