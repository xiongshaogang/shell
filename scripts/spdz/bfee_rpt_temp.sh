#!/bin/sh
################################################################################
# Script to generate 退费上报文件
# author: fanghm@asiainfo.com
# 2006/9/11
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 9/13/2006 按照《退费上报文件格式及检错标准V1.0》创建
# 2006年9月5日-8日，各省上报2006年7月、8月帐期产生的梦网业务退费金额；
# 2006年11月5日-8日，各省上报2006年9月、10月帐期产生的梦网业务退费金额。
# 上传至：10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs

if [ $# -lt 1 ]; then
    print "Usage:"
    print "\t bfee_rpt.sh <current_month> [file_seq]"
    print "\t bal_month - Format: 'YYYYMM', say '200602' every 2 month produce one"
    print "\t file_seq  - Range : 0-99(0-Normal other-ReSend)"
	
	exit -1;
fi

bal_month=$1
seq="$2"
if [ "$seq" = "" ]; then
	seq="0"
fi
file_seq=`printf %03s $seq`	

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`

logfile=$logpath/spdz/bfee_${now}.log

# 退费上报文件
bfee_file=$logpath/spdz/BFEE${bal_month}${file_seq}.571	# BFEEYYYYMMNNN.ZZZ

# clear
echo - This will take a few minutes, pls wait ...

#logfile=/data1/home/jsusr1/center/log/spdz/bfee_20060913171524.log
if true; then
################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $logfile;

SELECT 
'20', 
decode(sp.busi_type, 3, '01', 5, '02', 7, '03', 2, '04', 6, '05', '00') biz_type, 
mod(sp.oper_id,1000000),
'0' biz_code,	--a.operator_code, 
t.bill_month,
round(sum(t.refund) * DECODE(sp.busi_type, 7, 0.65, 0.85))
FROM (
SELECT 
a.fee_refund refund,	--有小数 FLH-0.65 other-0.85
a.*
FROM stat_user_acc_bill a 
WHERE a.bill_month in (to_char(add_months(to_date($1,'yyyymm'),-3),'yyyymm'),to_char(add_months(to_date($1,'yyyymm'),-2),'yyyymm'))
AND a.fee_refund>0
UNION
SELECT b.fee_unpayed refund,
b.*
FROM stat_user_acc_bill b
WHERE b.bill_month IN (to_char(add_months(to_date($1,'yyyymm'),-3),'yyyymm'),to_char(add_months(to_date($1,'yyyymm'),-2),'yyyymm')) 
AND b.fee_unpayed>0
union
SELECT 
a.fee_refund refund,	--有小数 FLH-0.65 other-0.85
a.*
FROM stat_user_acc_bill_his a 
WHERE a.bill_month in (to_char(add_months(to_date($1,'yyyymm'),-3),'yyyymm'),to_char(add_months(to_date($1,'yyyymm'),-2),'yyyymm'))
AND a.fee_refund>0
UNION
SELECT b.fee_unpayed refund,
b.*
FROM stat_user_acc_bill_his b
WHERE b.bill_month IN (to_char(add_months(to_date($1,'yyyymm'),-3),'yyyymm'),to_char(add_months(to_date($1,'yyyymm'),-2),'yyyymm')) 
AND b.fee_unpayed>0

) t,
bps_add_sp_busi_desc sp
WHERE
t.settle_side=sp.oper_id
AND sp.serv_range=3 AND sp.busi_type IN (2,3,5,6,7) --wap/pda/flh/mms/kjava
AND to_char(sysdate,'YYYYMMDD') between sp.eff_date AND sp.exp_date -- 用当前时间检查SP代码是否生效
GROUP by sp.busi_type,sp.oper_id,t.bill_month
;

spool off;
exit
SQLEOF
################################################################################
fi

#cat $logfile

if [ -f "$bfee_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $bfee_file $bfee_file.bak.$now
	#exit -1
fi

# bfee_file head
blanks=`printf "%33s" " "`
head="1046000571  46000000  ${file_seq}${now}01$blanks\r\n"
echo "$head\c" > $bfee_file

# bfee_file body
awk ' /^20/ { printf("%2s%2s%-10s%20s%-8s%012.f%20s\r\n", $1,$2,$3," ",$5,$6," ") }' $logfile >> $bfee_file

cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $6 } END { printf("lines:%d sum: %f \r\n", n, s) }'
linefmt=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $6 } END { printf("%09d%012.f%28s", n, s, " ") }'`
# lines=`awk ' /^20/ { print $1 }' $logfile | wc -l`
# fee=`cat $logfile | awk '/^20/ {print}' | awk '{ s+=$6} END { printf("%12.f", s) }'`
# linefmt=`printf "%09d%012.f%28s" $lines $fee " "`
echo $linefmt

# bfee_file tail
tail="9046000000  46000571  ${file_seq}$linefmt"
echo "$tail\r" >> $bfee_file


echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$bfee_file"
echo "ftp $bfee_file"
#--------------------------------------------------------------------#

#--------------------------------------------------------------------#    
echo Upload_OK
echo "A-OK!"

exit 0

