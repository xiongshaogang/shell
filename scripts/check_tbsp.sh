#!/bin/sh
#--------------------------------------------------------------------#
# check_tbsp.sh 
# desc	: check oracle table space and disk
# author: fanghm
#--------------------------------------------------------------------#

# set -x

logpath=$HOME/center/log

#--------------------------------------------------------------------#
# tablespace alert
echo --------------------- TABLESPACE FREE REPORT --------------------
rm $logpath/tablespace.alert

sqlplus -s << !
aijs/aijs@zmjs

set feed off
set linesize 100
set pagesize 200
col TABLESPACE_NAME for a15;
col PER_FREE for a10;
spool $logpath/tablespace.alert

SELECT 
F.TABLESPACE_NAME,
TO_CHAR ((T.TOTAL_SPACE - F.FREE_SPACE),'999,999,999') "USED (MB)", 
TO_CHAR (F.FREE_SPACE, '999,999,999') "FREE (MB)",
TO_CHAR (T.TOTAL_SPACE, '999,999,999') "TOTAL (MB)",
TO_CHAR ((ROUND ((F.FREE_SPACE/T.TOTAL_SPACE)*100)),999)||'%' "PER_FREE" 
FROM (
     SELECT TABLESPACE_NAME, 
     ROUND (SUM (BLOCKS*(
     SELECT VALUE/1024 
     FROM V\$PARAMETER --notice to remove the backslash when used in sqlplus
     WHERE NAME = 'db_block_size')/1024)) FREE_SPACE 
     FROM DBA_FREE_SPACE 
     GROUP BY TABLESPACE_NAME) F,
     (SELECT TABLESPACE_NAME,ROUND (SUM (BYTES/1048576)) TOTAL_SPACE FROM 
DBA_DATA_FILES GROUP BY TABLESPACE_NAME) T 
WHERE F.TABLESPACE_NAME = T.TABLESPACE_NAME 
--AND (ROUND ((F.FREE_SPACE/T.TOTAL_SPACE)*100)) < 10		-- only show tbsp less than 10%
ORDER BY per_free;

spool off
exit
!

line=`cat $logpath/tablespace.alert|wc -l`
if [ $line -gt 0 ];then
	# echo `cat $logpath/tablespace.alert|wc -l`
	# percent=`cat $logpath/tablespace.alert | grep DR_DATA | cut -c 57- | sed "s/ //g" | sed "s/%//g"`
	# echo "percent: $percent"
	# stop_drloader.sh
	# cat $logpath/tablespace.alert
	echo
else
	echo "No tablespace's free space is below 10%!"
fi

#--------------------------------------------------------------------#
# disk alert
#df -Pk /data[1-4] > $logpath/disk.alert
df -Pk /data* | awk 'BEGIN { printf("%15s%12s%11s%11s%6s%8s\n","Filesystem", "1024-blocks","Used",  "Available", "Used%","Mounted") } /^\/dev/ {printf("%15s%12.f%11.f%11.f%6s%8s\n",$1,$2,$3,$4,$5,$6) }'  > $logpath/disk.alert

echo ------------------------ DISK FREE REPORT -----------------------
cat $logpath/disk.alert
echo

echo "-----------------------------------------------------------------"

echo >> $logpath/tablespace.alert
cat $logpath/disk.alert >> $logpath/tablespace.alert
#mailx -s "DISK/TABLESPACE ALERT" jsusr1@zjxyjs01 < $logpath/tablespace.alert

exit 0
