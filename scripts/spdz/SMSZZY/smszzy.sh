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

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`

logfile=$logpath/spdz/smszzy${now}.log

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $logfile;

select '20',to_char(sysdate-1,'YYYYMMDD') from dual;

spool off;
exit
SQLEOF

yestoday=`awk ' /^20/ { print $2 }' $logfile`


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

echo $MONTH
#MONTH='200912'
echo $MONTH

# clear
echo - This will take a few minutes, pls wait ...


#--------------------------------------------------------------------#
echo begin

#ftp -i -n 10.70.18.98  << EOF
#user zzy zzy0805
#lcd /data1/home/jsusr1/center/scripts/spdz/SMSZZY
#cd /jingfen-system/$MONTH/
#bin
#mget forwardresult_*0.txt 
#mget forwardresult_*1.txt 
#mget forwardresult_*2.txt
#mget forwardresult_*3.txt
#mget forwardresult_*4.txt
#mget forwardresult_*5.txt
#mget forwardresult_*6.txt
#mget forwardresult_*7.txt
#mget forwardresult_*8.txt
#mget forwardresult_*9.txt
#bye
#EOF
#--------------------------------------------------------------------#  
#ftp -i -n 10.70.18.98  << EOF
#user zzy zzy0805
#lcd /data1/home/jsusr1/center/scripts/spdz/SMSZZY
#cd /jingfen-system/$MONTH/
#bin
#mget pushresult_*0.txt
#mget pushresult_*1.txt
#mget pushresult_*2.txt
#mget pushresult_*3.txt
#mget pushresult_*4.txt
#mget pushresult_*5.txt
#mget pushresult_*6.txt
#mget pushresult_*7.txt
#mget pushresult_*8.txt
#mget pushresult_*9.txt
#bye
#EOF
#--------------------------------------------------------------------#  



echo "A-OK!"


for file in /data1/home/jsusr1/center/scripts/spdz/SMSZZY/forwardresult*;
do
echo $file
rm /data1/home/jsusr1/center/scripts/spdz/SMSZZY/sms.ctl
smszzy.sql $file
sqlldr aijs/aijs@zmjs control=sms.ctl
done

for file in /data1/home/jsusr1/center/scripts/spdz/SMSZZY/pushresult*;
do
echo $file
rm /data1/home/jsusr1/center/scripts/spdz/SMSZZY/sms_1.ctl
smszzy_1.sql $file
sqlldr aijs/aijs@zmjs control=sms_1.ctl
done

#rm /data1/home/jsusr1/center/scripts/spdz/SMSZZY/forwardresult*
#rm /data1/home/jsusr1/center/scripts/spdz/SMSZZY/pushresult*

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

update sms_forwardresult set cp_name=replace(cp_name,chr(13),'') where to_char(send_date,'YYYYMM')=$MONTH;
update sms_pushresult set cp_name=replace(cp_name,chr(13),'') where to_char(send_date,'YYYYMM')=$MONTH;
commit;
delete from smszzy_stat where bill_month=$MONTH;
commit;
insert into smszzy_stat 
select $MONTH,count(*) counts,'1','平台当月全部种子短信下发条数' from sms_pushresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='1';
insert into smszzy_stat 
select $MONTH,count(*) counts,'2','平台当月全部短信礼包下发次数' from sms_pushresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='1' and send_reason='4';
insert into smszzy_stat 
select $MONTH,sum(sheet_cnt) counts,'3','当月业务代码为125009的所有记录条数' from stat_billing_sp_all_daily where bill_month=$MONTH and operator_code='125009';
insert into smszzy_stat 
select $MONTH,count(*) counts,'4','种子短信转发总条数' from sms_forwardresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='1';
insert into smszzy_stat 
select $MONTH,count(*) counts,'5','平台当月全部种子彩信下发条数' from sms_pushresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='2';
insert into smszzy_stat 
select $MONTH,sum(sheet_cnt) counts,'6','当月业务代码为125002的所有记录条数' from stat_billing_sp_all_daily where bill_month=$MONTH and operator_code='125002';
insert into smszzy_stat 
select $MONTH,count(*) counts,'7','平台当月全部彩信点播次数' from sms_pushresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='2' and send_reason='1';
insert into smszzy_stat 
select $MONTH,count(*) counts,'8','种子彩信转发总条数' from sms_forwardresult where to_char(send_date,'YYYYMM')=$MONTH and send_type='2';
commit;

exit
SQLEOF

echo "A-OK!"
exit 0

