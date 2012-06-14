#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs" 

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`

logfile=$logpath/spdz/eb_error${now}.log

errfile=/data1/home/jsusr1/center/scripts/spdz/zhangyi/EB0705007.571.F043

rm /data1/home/jsusr1/center/scripts/spdz/zhangyi/test.ctl
test2.sql EB0705007.571
sqlldr aijs/aijs@zmjs control=test.ctl

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
SET timing off;
SET FEEDBACK OFF;
SET TERMOUT OFF;
SET ECHO OFF;
SET HEADING OFF;
SET TRIMSPOOL ON;
set wrap off;
set pagesize 0;
set verify off;
SET LINESIZE 150;
spool $logfile;
select '20'||','||err_code||','||call_cdr from eb_error_temp where err_code='F043';
spool off;
exit
SQLEOF

awk 'BEGIN { FS="," } /^20/ { printf("%-190s\r\n", $3) }' $logfile >> $errfile
exit 0
