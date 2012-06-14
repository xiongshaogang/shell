#!/bin/sh
################################################################################
# Script to generate adc interface files
# author: fanghm@asiainfo.com
# 2007/2/13~
# Usage:
# 		adc_intf.sh <bal_month>
#		bal_month - format:'YYYYMM', say '200702'
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
################################################################################
# FTP服务器IP地址为：10.70.148.137, FTP目录：-/Interface/ADC/receive/
# FTP用户名 -zjadctest2\ftp , 密码为 -Password@1
# 文件传送/重传时间为每月8日12点之前, ASCII方式传送
# 各字段之间采用逗号“,”（ASCII码44）作为分隔符，记录之间采用回车换行符（ASCII码13、10）分隔。
# 文件中涉及到的费用和金额单位为分，不保留小数点，小数点后采用四舍五入。
################################################################################
#   文件格式(19个字段)：
#   SI企业编码, SI企业名称, 帐单月份, 结算地, 用户品牌, 业务类型, 应收功能费, 应收信息费, 其他应收费用, 实收费用, 拒收费用, 退费, 欠费, 公免费用, 其它未收费用, 移动分成, SI分成, SI调帐额, SI结算额
################################################################################

#set -x		# for debug
#set 200612	# for test

if [ $# -ne 1 ]; then
	print "Bad parameters!"
	print "Usage:"
	print "\t adc_intf.sh <bal_month>"
	print "\t bal_month - format:'YYYYMM', say '200602'"
	exit -1;
fi

DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs
logpath=`echo $SYS_LOG_PATH`
################################################################################
echo - Begin ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/adc/adc_intf_${now}.log
adcfile=$logpath/adc/ADC_INTF_$1

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 350;   
set pagesize 0; 
col sp_name for a50;

spool $logfile;

SELECT '50' --flag
	, b.sp_code, b.sp_name
	, '$1', a.hplmn2, a.trademark
	, nvl(a.operator_code,'-')
	, 0, SUM(a.charge4)/10 info_fee, 0
	, SUM(a.fee_payed)/10, SUM(a.fee_refused)/10, SUM(a.fee_refund)/10
	, SUM(a.fee_unpayed)/10, SUM(a.fee_free)/10, 0
	, SUM(a.self_allot)/10 self_allot 
	, SUM(a.sp_allot)/10 sp_allot
	, 0 adjust_fee
	--, SUM(sp_allot)/10 sp_allot
FROM acc_settle_sp a
	, bps_add_sp_busi_desc b
WHERE a.settle_side = b.oper_id
	and a.BILL_MONTH='$1' AND a.ACC_SETTLE_ID = 410200                                          
GROUP BY b.sp_code, b.sp_name,a.hplmn2,a.trademark,a.operator_code
;
--union adjust fee

spool off;

exit
SQLEOF

if [ -f "$adcfile" ]; then	#regenerate
	echo - Old files $adcfile renamed to ${adcfile}.bak.$now.
	mv -f $adcfile $adcfile.bak.$now
fi

# adcfile body
awk ' /^50/ { printf("%s,%s,%s,%s,%s,%s,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f,%.f\r\n", $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $18+$19 ) }' $logfile > $adcfile

echo - output files:
echo "\t$adcfile"
echo "\t$logfile"

echo "A-OK!"

exit 0

