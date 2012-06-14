#!/bin/sh
################################################################################
# Script to generate spdz files
# author: fanghm@asiainfo.com
# 2006/4/30
# Usage:
# 		spdz_rpt_new.sh <bal_month>
#		bal_month - format:'YYYYMM', say '200602'
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 8/8/2008 按照《移动梦网业务对帐平台文件接口规范（省）1.1.doc》修改“结算对帐分项总单文件”
################################################################################
#set -x
#set 200607	# for debug

if [ $# -ne 1 ]; then
	print "Bad parameters!"
    print "Usage:"
    print "\t spdz_rpt_new <bal_month>"
    print "\t bal_month - format:'YYYYMM', say '200602'"
	
	exit -1;
fi

DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`

logfile=$logpath/spdz/spdz_${now}.log
tmpfile=$logpath/spdz/spdz_${now}.tmp

sumfile=$logpath/spdz/spdz_sum_001_$1.571	# 结算单文件
subfile=$logpath/spdz/spdz_sub_001_$1.571	# 结算对帐分项总单文件,版本修改

# clear
echo - Begin ...

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;   
set pagesize 5000; 
--col area for a40;

--show 12 blanks if zero for fields: 8-16,18

spool $logfile;
--select flag,month,sp_code,unit,

select '50;${1};' || sp_code || ';571;' ||
to_char(round( sum(INFO_FEE_TTL+FEE_ERROR)/10)) 		||';'|| -- 5: total_info_fee
to_char(round( sum(FEE_ERROR)/10)) 						||';'|| -- 6: error_dup_fee
to_char(round( sum(INFO_FEE_TTL)/10)) 					||';'|| -- 7: checked_info_fee
decode(round(sum(FEE_BAR)/10), 0, '            ', to_char(round(sum(FEE_BAR)/10)) ) ||';'|| -- stop_fee
decode(round(sum(FEE_STOP_SRV+FEE_PRE_STOP)/10), 0, '            ', to_char(round(sum(FEE_STOP_SRV+FEE_PRE_STOP)/10)) ) ||';'|| -- off_fee
decode(round(sum(FEE_REL_ABN)/10), 0, '            ', to_char(round(sum(FEE_REL_ABN)/10)) ) ||';'|| -- 10: order_ex_fee
decode(round(sum(FEE_SIL)/10), 0, '            ', to_char(round(sum(FEE_SIL)/10)) ) ||';'|| -- silence_fee
decode(round(sum(FEE_OVER_PAY)/10), 0, '            ', to_char(round(sum(FEE_OVER_PAY)/10)) ) ||';'|| -- single_high_fee
decode(round(sum(REFN_FEE+adjust_fee)/10), 0, '            ', to_char(round(sum(REFN_FEE+adjust_fee)/10)) ) ||';'|| -- refund_fee
decode(round(sum(PEN_FEE)/10), 0, '            ', to_char(round(sum(PEN_FEE)/10)) ) ||';'|| -- penalty_fee
decode(round(sum(DBL_COMP_FEE)/10), 0, '            ', to_char(round(sum(DBL_COMP_FEE)/10)) ) ||';'|| -- 15: dbl_return_fee
decode(round(sum(OTHER_FEE)/10), 0, '            ', to_char(round(sum(OTHER_FEE)/10)) ) ||';'|| -- other_fee,
to_char(round( sum(sp_allot)/10) ) 			-- 17: INFO_FEE_STL
||';            ;' 							-- 18: comm_fee, 
-- || to_char(round( sum(sp_allot)/10) ) 	-- 19: settle_fee
"DATA"
from acc_settle_mcas where bal_month='$1'
group by sp_code
having round( sum(sp_allot)/10, 0)<>0
;

spool off;

exit
SQLEOF

# cat $logfile
if [ -f "$sumfile" or -f "$subfile" ]; then
	echo - Old files renamed if existed.
	mv -f $sumfile $sumfile.bak.$now
	mv -f $subfile $subfile.bak.$now
fi

# wc to get total line number
lines=`awk -F ";" ' /^50;/ { print $1 }' $logfile | wc -l`
linefmt=`printf "%09s" $lines`

# sumfile head
blanks=`printf "%58s" " "`
head1="10sum571001$1$now$linefmt$blanks"
echo "$head1\r\n\c" > $sumfile

# subfile head
blanks=`printf "%208s" " "`
head2="10sub571001$1$now$linefmt$blanks"
echo "$head2\r\n\c" > $subfile

# sumfile body
awk -F ";" ' /^50;/ { printf("%2s%6s%10s%3s%012s%012s%012s%41s\r\n", $1,$2,$3,$4,$17,$18,$17, " ") }' $logfile >> $sumfile

# subfile body
awk -F ";" ' /^50;/ { printf("%2s%6s%10s%3s%012.f%012s%012.f%012s%012s%012s%012s%012s%012s%012s%012s%012s%012s%012s%012s%47s\r\n", $1,$2,$3,$4,
$6+$8+$9+$10+$11+$12+$13+$14+$15+$16+$17,
$6,
$8+$9+$10+$11+$12+$13+$14+$15+$16+$17,
$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$17," ") }' $logfile >> $subfile


echo - Execute spdz_rpt_new.awk to analyse selected data...
awk -f $PROD_PA/scripts/spdz/spdz_rpt_new.awk $logfile > $tmpfile

# tails
feepart1=`tail -1 $tmpfile`
echo "90sum571001$1$linefmt$feepart1" >> $sumfile

feepart2=`head -1 $tmpfile`
echo "90sub571001$1$linefmt$feepart2" >> $subfile

# check
#awk -f $PROD_PA/scripts/spdz/spdz_check_new.awk $logfile
echo

echo - Temp files:
echo "\t$logfile"
echo "\t$tmpfile"

echo - Result files:
echo "\t$sumfile"
echo "\t$subfile"

# cat $tmpfile

echo "A-OK!"

exit 0

select '50' flag, '200610' month, sp_code, '571' unit,                  
round( sum(INFO_FEE_TTL+FEE_ERROR)/10, 0) total_info_fee,  -- field: 5  
round( sum(FEE_ERROR)/10, 0) pause_fee,                                 
round( sum(INFO_FEE_TTL)/10, 0) checked_info_fee,                       
round( sum(FEE_BAR)/10, 0) stop_fee,                                    
round( sum(FEE_STOP_SRV+FEE_PRE_STOP)/10, 0) off_fee,                   
round( sum(FEE_REL_ABN)/10, 0) order_ex_fee,               -- 10        
round( sum(FEE_SIL)/10, 0) silence_fee,                                 
round( sum(FEE_OVER_PAY)/10, 0) single_high_fee,                        
round( sum(REFN_FEE+adjust_fee)/10, 0) return_fee,                      
round( sum(PEN_FEE)/10, 0) penalty_fee,                                 
round( sum(DBL_COMP_FEE)/10, 0) refund_fee,                        -- 15
round( sum(OTHER_FEE)/10, 0) other_fee,                                 
round( sum(sp_allot)/10, 0) info_fee,                  -- 17: sp_allot  
0 comm_fee,                                                             
round( sum(sp_allot)/10, 0) real_fee                               -- 19
from acc_settle_mcas where bal_month='200610'  --AND reserved1 IS NULL  
group by sp_code                                                        
having round( sum(sp_allot)/10, 0)<>0                                   
;                                                                       
