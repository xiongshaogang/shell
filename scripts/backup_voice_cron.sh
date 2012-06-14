#!/bin/sh

script=backup_voice.sh
pn=`ps -ef|grep $script|grep -v grep|wc -l`

# execute backup script only when there's no other backup process is running
if [ $pn -eq 0 ]; then
	now=`date +%Y%m%d%H%M%S`
	nohup /data1/home/jsusr1/center/scripts/$script > /data1/home/jsusr1/center/log/backup/backup_voice_${now}_detail.log 2>&1 &

	# tail -f /data1/home/jsusr1/center/log/backup/backup_voice_${now}_detail.log
fi

exit 0
