#!/bin/sh
################################################################################
# Script to generate ptzc files
# will indirect execute ptzc_rpt_new.awk script
# author: fanghm@asiainfo.com
# 2007/1/10~
# Usage:
# 		ptzc_rpt.sh <bal_month>
#		bal_month - format:'YYYYMM', say '200702'
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 2007/1/10 根据《平台支撑服务费结算统计接口规范 v1.0.doc》编写：
################################################################################
# FTP服务器IP地址为：132.32.22.18, FTP目录：/ftp_571/
# FTP用户名 ftp_571, 密码为 571@JLWZ
# 文件传送/重传时间为每月15日之后、20日之前, ASCII方式传送
# 各字段之间采用逗号“,”（ASCII码44）作为分隔符，记录之间采用回车换行符（ASCII码13、10）分隔。
# 文件中涉及到的费用和金额单位为分，不保留小数点，小数点后采用四舍五入。
################################################################################
# 浙江移动需上传以下文件：
# 手机报(彩信)业务	PTZC_002_YYYYMM.571		上报我省SP代码为811234的结算数据
# IVR(话音)业务     PTZC_004_YYYYMM.571		上报我省用户使用全网的IVR语音业务的结算数据
# Pushmail业务      PTZC_008_YYYYMM.571		暂时按0费用上报
# BlackBerry业务    PTZC_009_YYYYMM.571		暂时按0费用上报
################################################################################
#   上报文件格式：
#   5.2	手机报（彩信）业务
#   序号	省代码	SP企业代码	SP名称	业务代码	信息费（分）	中国移动分成（分）	SP分成（分）	结算额（分）
#	
#   5.4	IVR(话音)业务
#   序号	省代码	企业代码	公司名称	12590收益（分）	1259070收益（分）	12586收益（分）	1869收益（分）
#
#   5.8	Pushmail业务
#   序号	省代码	功能费实收（分）
#
#   5.9	BlackBerry业务
#	序号	省代码	功能费（分）
################################################################################

#set -x		# for debug
#set 200612	# for test

if [ $# -ne 1 ]; then
	print "Bad parameters!"
	print "Usage:"
	print "\t ptzc_rpt <bal_month>"
	print "\t bal_month - format:'YYYYMM', say '200602'"
	exit -1;
fi

DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs
logpath=`echo $SYS_LOG_PATH`

################################################################################
# Pushmail业务      PTZC_008_YYYYMM.571		暂时按0费用上报
file=$logpath/ptzc/PTZC_008_$1.571
echo 1,571,0 > $file
################################################################################
# BlackBerry业务    PTZC_009_YYYYMM.571		暂时按0费用上报
file=$logpath/ptzc/PTZC_009_$1.571
echo 1,571,0 > $file
################################################################################
#   5.2	手机报（彩信）业务
################################################################################
echo - Begin mms ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_mms_${now}.log
mmsfile=$logpath/ptzc/PTZC_002_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
	, operator_code
	, SUM(charge4)/10 info_fee, SUM(self_allot)/10 self_allot 
	--,SUM(sp_allot)/10 sp_allot, SUM(sp_allot)/10 sp_allot2 --厘->分
FROM acc_settle_sp                                             
WHERE BILL_MONTH='$1' AND ACC_SETTLE_ID = 410200                                          
	AND settle_side=100811234                                                                      
GROUP BY operator_code
	having sum(sp_allot)>0
;

spool off;

exit
SQLEOF

if [ -f "$mmsfile" ]; then	#regenerate
	echo - Old files $mmsfile renamed to ${mmsfile}.bak.$now.
	mv -f $mmsfile $mmsfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row+=1; printf("%d,571,811234,卓望信息,%s,%.f,%.f,%.f,%.f\r\n", row, $2, $3, $4, $3-$4, $3-$4 ) }' $logfile >> $mmsfile

################################################################################
# IVR(话音)业务     PTZC_004_YYYYMM.571		上报我省用户使用全网的IVR语音业务的结算数据
# 12590 SP:高阳平台:移动=70:15:15
# 12586 SP:移动=70:30
################################################################################
echo - Begin ivr ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_ivr_${now}.log
ivrfile=$logpath/ptzc/PTZC_004_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;   
set pagesize 0; 
col sp_name for a50;

spool $logfile;

SELECT '50' --flag to filter by awk
	, sp_code, sp_name
	, SUM(decode(sp_code, '500000', 0, info_fee))/10 "12590"
	, SUM(decode(sp_code, '500000', info_fee, 0))/10 "1259070"
FROM fhm_statics_gsm_sp WHERE sp_code IS NOT NULL
GROUP BY sp_code,sp_name
;

spool off;

exit
SQLEOF

if [ -f "$ivrfile" ]; then
	echo - Old files $ivrfile renamed to ${ivrfile}.bak.$now.
	mv -f $ivrfile $ivrfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row+=1; printf("%d,571,%s,%s,%.f,%.f,0,0\r\n", row, $2, $3, $4, $5 ) }' $logfile >> $ivrfile

echo - output files:
echo "\t$ivrfile"
echo "\t$mmsfile"

echo "- to transfer:"
echo "\tcd /data1/home/jsusr1/center/log/ptzc"
echo "\tftp 132.32.22.18"
echo "\tuser/pwd: ftp_571 / 571@JLWZ"
echo "\tasc"
echo "\tmput PTZC_*$1.571"

echo "A-OK!"

exit 0
                          
