#!/bin/sh
set -x

script=pickup_roam_temp.sh

pn=`ps -ef|grep $script|grep -v grep|wc -l`

# execute script only when there's no other pickup process
if [ $pn -eq 0 ]; then
	now=`date +%Y%m%d%H%M%S`
	nohup /data1/home/jsusr1/center/scripts/$script > /data1/home/jsusr1/center/log/pickup/pickup_roam_temp_${now}.log 2>&1 &
	
	tail -f /data1/home/jsusr1/center/log/pickup/pickup_roam_temp_${now}.log 2>&1 &
fi

exit 0
