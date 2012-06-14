#!/bin/sh
################################################################################
# Script to generate 手机游戏核减数据上报文件
# author: zhangyi@asiainfo.com
# 2008-04
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

logfile=$logpath/spdz/mobilegame_${now}.log

# 退费上报文件
mobilegame_file=/data1/home/jsusr1/center/uploadfile/DGP/DGP${curdate}000.571	# DGPYYYYMMDDNNN.ZZZ
#mobilegame_file=/data1/home/jsusr1/center/scripts/spdz/DGP${curdate}000.571
curfile=DGP${curdate}000.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile

if [ -f "$mobilegame_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $mobilegame_file $mobilegame_file.bak.$now
	#exit -1
fi

# 文件头记录
blanks=`printf "%124s" " "`
head="1046000571  46000000  000${now}01$blanks\r\n"
echo "$head\c" > $mobilegame_file

#取营业库退费数据
if true; then
################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_DED;
set line 250;
set pagesize 5000; 

spool $logfile;

select rev_head,serv_type,fee_type,bill_id,sp_code,operator_code,bill_type,use_time,
ded_time,rev_fee,done_code from ded_file;

spool off;
exit
SQLEOF
################################################################################
fi


awk ' /^20/ { printf("%2s%-10s%2s%-20s%-15s%-20s%-20s%02s%14s%14s%06.f%20s\r\n", $1,$2,$3,$11,$4,$5,$6,$7,$8,$9,$10," ") }' $logfile >> $mobilegame_file

cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("lines:%d sum: %f \r\n", n, s) }'
linefmt=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("%09d%012.f%99s", n, s, " ") }'`
# lines=`awk ' /^20/ { print $1 }' $logfile | wc -l`
# fee=`cat $logfile | awk '/^20/ {print}' | awk '{ s+=$6} END { printf("%12.f", s) }'`
# linefmt=`printf "%09d%012.f%119s" $lines $fee " "`
echo $linefmt

# mobilegame_file tail
tail="9046000000  46000571  000$linefmt"
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
