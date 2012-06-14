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
# NOTE: DB_CONNECT_STRING�����������ݿ����Ӵ�
# 2007/1/10 ���ݡ�ƽ̨֧�ŷ���ѽ���ͳ�ƽӿڹ淶 v1.0.doc����д��
################################################################################
# FTP������IP��ַΪ��132.32.22.18, FTPĿ¼��/ftp_571/
# FTP�û��� ftp_571, ����Ϊ 571@JLWZ
# �ļ�����/�ش�ʱ��Ϊÿ��15��֮��20��֮ǰ, ASCII��ʽ����
# ���ֶ�֮����ö��š�,����ASCII��44����Ϊ�ָ�������¼֮����ûس����з���ASCII��13��10���ָ���
# �ļ����漰���ķ��úͽ�λΪ�֣�������С���㣬С���������������롣
################################################################################
# �㽭�ƶ����ϴ������ļ���
# �ֻ���(����)ҵ��	PTZC_002_YYYYMM.571		�ϱ���ʡSP����Ϊ811234�Ľ�������
# IVR(����)ҵ��     PTZC_004_YYYYMM.571		�ϱ���ʡ�û�ʹ��ȫ����IVR����ҵ��Ľ�������
# Pushmailҵ��      PTZC_008_YYYYMM.571		��ʱ��0�����ϱ�
# BlackBerryҵ��    PTZC_009_YYYYMM.571		��ʱ��0�����ϱ�
################################################################################
#   �ϱ��ļ���ʽ��
#   5.2	�ֻ��������ţ�ҵ��
#   ���	ʡ����	SP��ҵ����	SP����	ҵ�����	��Ϣ�ѣ��֣�	�й��ƶ��ֳɣ��֣�	SP�ֳɣ��֣�	�����֣�
#	
#   5.4	IVR(����)ҵ��
#   ���	ʡ����	��ҵ����	��˾����	12590���棨�֣�	1259070���棨�֣�	12586���棨�֣�	1869���棨�֣�
#
#   5.8	Pushmailҵ��
#   ���	ʡ����	���ܷ�ʵ�գ��֣�
#
#   5.9	BlackBerryҵ��
#	���	ʡ����	���ܷѣ��֣�
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
# Pushmailҵ��      PTZC_008_YYYYMM.571		��ʱ��0�����ϱ�
file=$logpath/ptzc/PTZC_008_$1.571
echo 1,571,0 > $file
################################################################################
# BlackBerryҵ��    PTZC_009_YYYYMM.571		��ʱ��0�����ϱ�
file=$logpath/ptzc/PTZC_009_$1.571
echo 1,571,0 > $file
################################################################################
#   5.2	�ֻ��������ţ�ҵ��
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
	--,SUM(sp_allot)/10 sp_allot, SUM(sp_allot)/10 sp_allot2 --��->��
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
awk ' /^50/ { row+=1; printf("%d,571,811234,׿����Ϣ,%s,%.f,%.f,%.f,%.f\r\n", row, $2, $3, $4, $3-$4, $3-$4 ) }' $logfile >> $mmsfile

################################################################################
# IVR(����)ҵ��     PTZC_004_YYYYMM.571		�ϱ���ʡ�û�ʹ��ȫ����IVR����ҵ��Ľ�������
# 12590 SP:����ƽ̨:�ƶ�=70:15:15
# 12586 SP:�ƶ�=70:30
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
                          
