#!/bin/sh
set -x

script=pickup_roam.sh

pn=`ps -ef|grep $script|grep -v grep|wc -l`

# execute script only when the script is not running or editing or else...
if [ $pn -eq 0 ]; then
	now=`date +%Y%m%d%H%M%S`
	nohup /data1/home/jsusr1/center/scripts/$script > /data1/home/jsusr1/center/log/pickup/pickup_roam_${now}.log 2>&1 &
fi

exit 0
