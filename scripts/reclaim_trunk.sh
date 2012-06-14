#!/bin/sh
# $1 - msc
# step: stop settle processes; reclaim files; start settle processes

if [ $# -eq 0 ]; then
	echo "Usage:	reclaim_trunk.sh <[huawei] [alcatel] [nokia]|all>"
	exit -1
else
	msc="$*"
	if [ "$msc" = "all" ]; then
		msc="huawei alcatel nokia"
	fi
fi

now=`date +%Y%m%d%H%M`
mon=`date +%Y%m`

echo "--- stop settle processes ---"
#setenv SYS_IPC_KEY 92000
#taskmgr -s jsanalyze
#Settle -s settle_hw
#Settle -s settle_hw2
#Settle -s settle_nokia
#Settle -s settle_alcatel
#Settle -s settle_alcatel2
#ps -ex|grep settle_|grep -v grep

echo "--- begin ---"

# settle error path
src=/data2/wj/center/error/settle/wj/voice

# settle input path
dst=/data2/wj/center/data/format/output/wj/voice

# settle temp bak path for files errcode!=130103, may clean
back=/data4/backup/wjvoice/settle_error

for subdir in $msc
do
	echo $src/$subdir
	cd $src/$subdir
	mkdir -p useless		# store unreclaimable sheets
	
	for file in *
	do
	if [ -f $file ]; then
		# get error files due to unknown trunk
		if grep -q 130103$ $file
		then
			echo "reclaim $file"
			mv $src/$subdir/$file $dst/$subdir
			
#			mon=`echo $file| cut -d _ -f 6 | cut -c 1-6`
#			if [ $mon = "200601" ]; then
#				echo "reclaim $file"
#				mv $src/$subdir/$file $dst/$subdir
#			elif [ $mon = "200602" ]; then
#				mv $src/$subdir/$file $src/$subdir/200602
#			else
#				mv $src/$subdir/$file $src/$subdir/useless
#			fi
		else
			mv $src/$subdir/$file $src/$subdir/useless
		fi
	fi
	done
	
	echo "--- backup error sheets ---"
	cd $src/$subdir/useless
	tar -cvf $back/settle_err_${subdir}_${now}_$mon.tar ERROR*${mon}*	#current month
	rm -f ERROR*${mon}*
	
	tar -cvf $back/settle_err_${subdir}_${now}_other.tar ERROR*
	rm -f ERROR* &
done

echo "--- start settle processes ---"
sleep 10	# sleep 10 seconds

#setenv SYS_IPC_KEY 92000
#taskmgr -m jsanalyze &
#Settle -m settle_hw
#Settle -m settle_hw2
#Settle -m settle_nokia
#Settle -m settle_alcatel
#Settle -m settle_alcatel2
ps -ex|grep settle_|grep -v grep

echo "--- done ---"

exit 0
