#!/bin/sh

#DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs
DB_CONNECT_STRING="aijs/aijs@zmjs"

logfile=/data1/home/jsusr1/center/log/dr_20061010_tel_sms_hz1.zmcc

################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 100;
set pagesize 0; 
col content for a50;

spool $logfile;
--create table tmp_20061010_hzsms1_cond_id
--as 
--select distinct cond_id  -- count: 74
--from stat_wj_sms_daily_res 
--where acc_settle_id=120102 and FINISH_DATE='20061010' and region_code='571';

select /*+ parallel(a,8) */ odn || ';' || tdn || ';' || FINISH_time content 
from dr_wj_sms_20061010 a 
where EXISTS (select 1 from tmp_20061010_hzsms1_cond_id b where b.cond_id=a.cond_id);

spool off;
exit
SQLEOF
################################################################################

#cat $logfile

echo "A-OK!"
exit 0;
