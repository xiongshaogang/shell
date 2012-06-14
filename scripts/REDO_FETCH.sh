#!/bin/sh
################################################################################
# Script to fetch src files for REDO
# Usage:
# 		REDO.sh <msc_type>
# Say:	
#		REDO.sh huawei nokia alcatel		
# NOTE to set src/dst path and proper file filter
################################################################################
filter="N_GSM*"
src=/data33/aijs/center/back/settle/wj/voice
dst=/data33/aijs/center/data/format/output/wj/voice

if [ $# -lt 1 ]; then
	echo $#
	echo "bad params!\nUsage:\t$0 <subdir>\nsay:\t$0 huawei nokia alcatel\n"
	exit -1
fi

now=`date +%Y%m%d%H%M`

for subdir in $*	# all params as subdir collection 
do
	cd $src/$subdir
	echo === switch to: $PWD
	
	count=0
	for file in $filter
	do
		type=`echo $file|cut -c 1-5`
		head=`echo $file|cut -c 1-18`
		year=`echo $file|cut -d _ -f 5|cut -c 1-4`
		month=`echo $file|cut -d _ -f 5|cut -c 1-6`
		
		# delete outdated files
		if [ "$head" = "DR_WJ_VOICE_200512" -o "$year" = "2005" ]; then
			echo rm $file
			rm $file
			
		# fetch files for redo
		elif [ "$type" = "N_GSM" -a "$month" = "200601" ]; then
			echo "mv & gunzip $file"
			mv $file $dst/$subdir

			# ignore automatically if not gzip file
			gunzip -f $dst/$subdir/$file
			
			count=$(($count+1))
		else
			echo $file
		fi
		
		#check disk space
		mod=`expr $count % 100`
		if [ $mod -eq 0 ]; then
			percent=`df -k /data33 | tail -1 | cut -c 57-58`
			if [ $percent -ge 95 ]; then
				echo ====================+====================
				echo ===  WARNING: DISK SPACE NOT ENOUGH!  ===
				echo ====================+====================
				sleep 300
			elif [ $percent -ge 97 ]; then
				echo ====================+====================
				echo ===  WARNING: DISK SPACE EXHAUSTED!!  ===
				echo ====================+====================
				exit -2
			fi
		fi
	
	done
	
	# record file number for monitoring of process progress
	echo ============================================================
	echo $subdir: $count >> ~/center/log/redo.$now.log
	echo ============================================================
done

echo "A-OK!"

exit 0
