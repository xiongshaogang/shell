#!/bin/sh
################################################################################
# Script to generate ptzc files
# will indirect execute ptzc_rpt_new.awk script
# author: fanghm@asiainfo.com
# 2007/1/10~
# Usage:
# 		ptzc_rpt.sh <last_month>
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
	print "\t ptzc_rpt <prev_month>"
	print "\t prev_month - format:'YYYYMM', say '200602'"
	exit -1;
fi

DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs
logpath=`echo $SYS_LOG_PATH`

################################################################################
# Pushmailҵ��      PTZC_008_YYYYMM.571		ʵ�շ���
#file=$logpath/ptzc/PTZC_008_$1.571
#echo 1,571,0 > $file

echo - Begin Pushmail ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_pushmail_008_${now}.log
pmailfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_008_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

create table temp_pushmail_bill_$1 as select * from aicbs.acc_user_bill_dtl_571_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_572_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_573_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_575_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_576_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_570_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_574_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_577_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_578_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_579_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_580_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_571@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_572@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_573@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_575@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_576@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_570@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_574@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_577@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_578@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_579@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42001860;
insert into temp_pushmail_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_580@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42001860;
commit;

set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
	, 571
	, sum(card_payed_fee+other_payed_fee)
FROM temp_pushmail_bill_$1;                                             


spool off;

exit
SQLEOF

if [ -f "$pmailfile" ]; then	#regenerate
	echo - Old files $pmailfile renamed to ${pmailfile}.bak.$now.
	mv -f $pmailfile $pmailfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row=1; printf("%d,571,%.f\r\n", row, $3 ) }' $logfile >> $pmailfile
################################################################################
# BlackBerryҵ��ʵ��    PTZC_009_YYYYMM.571		
#file=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_009_$1.571
#echo 1,571,0 > $file
echo - Begin BlackBerry ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_blackberry_009_${now}.log
berryfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_009_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

create table temp_blackberry_bill_$1 as select * from aicbs.acc_user_bill_dtl_571_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_572_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_573_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_575_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_576_$1@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_570_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_574_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_577_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_578_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_579_$1@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_580_$1@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_571@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_572@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_573@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_575@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_576@ZWBCA_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_570@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_574@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_577@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_578@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_579@ZWBCB_AICBS where 
bill_month='$1' and acc_code=42000030;
insert into temp_blackberry_bill_$1 select * from aicbs.acc_user_bill_dtl_unpay_580@ZWBCC_AICBS where 
bill_month='$1' and acc_code=42000030;
commit;

set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
	, 571
	, sum(card_payed_fee+other_payed_fee)
FROM temp_blackberry_bill_$1;                                             


spool off;

exit
SQLEOF

if [ -f "$berryfile" ]; then	#regenerate
	echo - Old files $pmailfile renamed to ${berryfile}.bak.$now.
	mv -f $berryfile $berryfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row=1; printf("%d,571,%.f\r\n", row, $3 ) }' $logfile >> $berryfile
###############################################################################
# Pushmailҵ��      PTZC_010_YYYYMM.571         Ӧ�շ���
#file=$logpath/ptzc/PTZC_010_$1.571
#echo 1,571,0 > $file

echo - Begin Pushmail ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_pushmail_010_${now}.log
pushmailfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_010_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
	, 571
	, sum(total_fee)
FROM temp_pushmail_bill_$1;                                             

spool off;
drop table temp_pushmail_bill_$1;
exit
SQLEOF

if [ -f "$pushmailfile" ]; then	#regenerate
	echo - Old files $pushmailfile renamed to ${pushmailfile}.bak.$now.
	mv -f $pushmailfile $pushmailfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row=1; printf("%d,571,%.f\r\n", row, $3 ) }' $logfile >> $pushmailfile
################################################################################
# BlackBerryҵ��Ӧ��    PTZC_011_YYYYMM.571         
#file=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_011_$1.571
#echo 1,571,0 > $file

echo - Begin BlackBerry ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_blackberry_011_${now}.log
berryfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_011_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
	, 571
	, sum(total_fee)
FROM temp_blackberry_bill_$1;                                             

spool off;
drop table temp_blackberry_bill_$1;
exit
SQLEOF

if [ -f "$berryfile" ]; then	#regenerate
	echo - Old files $berryfile renamed to ${berryfile}.bak.$now.
	mv -f $berryfile $berryfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row=1; printf("%d,571,%.f\r\n", row, $3 ) }' $logfile >> $berryfile
################################################################################
#   5.2	�ֻ��������ţ�ҵ��
################################################################################
echo - Begin mms ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_mms_${now}.log
mmsfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_002_$1.571

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
#�����ֻ���ҵ��  PTZC_016_YYYYMM.571  �ϱ���ʡ�û�ʹ�ð����ֻ���ҵ��Ľ�������
#�������    �ƶ� 100%   SP  0
#ȡ�ϸ��µ�Ӧ�շ���
################################################################################
echo - Begin aoyun ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_aoyun_${now}.log
aoyunfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_016_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_PTZC_AOYUN($1);
set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
,sp_code,operator_code,fee 
from ptzc_aoyun order by sp_code,operator_code;

spool off;

exit
SQLEOF

if [ -f "$aoyunfile" ]; then
	echo - Old files $aoyunfile renamed to ${aoyunfile}.bak.$now.
	mv -f $aoyunfile $aoyunfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row+=1; printf("%d,571,%s,���ƶ��㽭����ҵ��,%s,%.f,%.f,0,0\r\n", row, $2, $3, $4, $4 ) }' $logfile >> $aoyunfile
################################################################################################
#����ҵ��   PTZC_017_YYYYMM.571  �ϱ���ʡ�û�ʹ�÷���ҵ��Ľ�������
#ȡ�ϸ��µ�Ӧ�շ���
################################################################################################
echo - Begin Fetion ...
now=`date +%Y%m%d%H%M%S`
logfile=$logpath/ptzc/ptzc_fetion_${now}.log
fetionfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_017_$1.571

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_ZY_PTZC_FETION($1);
set line 250;   
set pagesize 0; 

spool $logfile;

SELECT '50' --flag to filter by awk
,sp_code,operator_code,fee,ded_fee 
from ptzc_fetion order by sp_code,operator_code;

spool off;

exit
SQLEOF

if [ -f "$fetionfile" ]; then
	echo - Old files $fetionfile renamed to ${fetionfile}.bak.$now.
	mv -f $fetionfile $fetionfile.bak.$now
fi

# sumfile body
awk ' /^50/ { row+=1; printf("%d,571,%s,�й��ƶ�ͨ�ż��ű������޹�˾,%s,%.f,%.f\r\n", row, $2, $3, $4, $5 ) }' $logfile >> $fetionfile

################################################################################
# IVR(����)ҵ��     PTZC_004_YYYYMM.571		�ϱ���ʡ�û�ʹ��ȫ����IVR����ҵ��Ľ�������
# 12590 SP:����ƽ̨:�ƶ�=70:15:15
# 12586 SP:�ƶ�=70:30
################################################################################
#echo - Begin ivr ...
#now=`date +%Y%m%d%H%M%S`
#logfile=$logpath/ptzc/ptzc_ivr_${now}.log
#ivrfile=/data1/home/jsusr1/center/uploadfile/ptzc/PTZC_004_$1.571
#
#sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
#set line 250;   
#set pagesize 0; 
#col sp_name for a50;
#
#spool $logfile;
#
#SELECT '50' --flag to filter by awk
#	, sp_code, sp_name
#	, SUM(decode(sp_code, '500000', 0, info_fee))/10 "12590"
#	, SUM(decode(sp_code, '500000', info_fee, 0))/10 "1259070"
#FROM fhm_statics_gsm_sp WHERE sp_code IS NOT NULL
#GROUP BY sp_code,sp_name
#;
#
#spool off;
#
#exit
#SQLEOF
#
#if [ -f "$ivrfile" ]; then
#	echo - Old files $ivrfile renamed to ${ivrfile}.bak.$now.
#	mv -f $ivrfile $ivrfile.bak.$now
#fi
#
## sumfile body
#awk ' /^50/ { row+=1; printf("%d,571,%s,%s,%.f,%.f,0,0\r\n", row, $2, $3, $4, $5 ) }' $logfile >> $ivrfile

echo - output files:
#echo "\t$ivrfile"
echo "\t$mmsfile"

echo "- to transfer:"
#echo "\tcd /data1/home/jsusr1/center/log/ptzc"
#echo "\tftp 132.32.22.18"
#echo "\tuser/pwd: ftp_571 / 571@JLWZ"
#echo "\tasc"
#echo "\tmput PTZC_*$1.571"

#--------------------------------------------------------------------#
echo begin
ftp -i -n 132.32.22.18  << EOF
user ftp_571 571@JLWZ 
lcd /data1/home/jsusr1/center/uploadfile/ptzc
asc
prom off
mput PTZC_*$1.571 
bye
EOF
#--------------------------------------------------------------------#    
echo Upload_OK

echo "A-OK!"

exit 0
                          
