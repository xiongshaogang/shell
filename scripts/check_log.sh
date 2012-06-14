cd /data1/home/jsusr1/center/log
if [ "$1" = "" ]; then
	file="sys200610*.log"
fi
grep "“Ï≥£" $file|grep -v grep

exit 0