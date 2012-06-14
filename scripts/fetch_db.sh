#!/bin/sh

DB_CONNECT_STRING="aijs/aijs@zmjs" #testjs
logfile=/data1/home/jsusr1/center/log/dr_20060510_telecom_nb_2.log

################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $logfile;

SELECT odn||';'||tdn||';'||start_time||';'||duration||';'||msc||';'||trunk_in||';'||trunk_out||';'
FROM dr_wj_voice_20060510 
WHERE call_type='02' AND trunk_out_oper=1 AND tdn_long=0 AND odn<>0
AND odn_acc_type in (2,3) and region_code=574;

spool off;
exit
SQLEOF
################################################################################

#cat $logfile

echo "A-OK!"
exit 0;