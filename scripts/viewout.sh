#!/bin/sh
################################################################################
# Script to watch file process progress
# Usage:
# 		
################################################################################
for proc in acquire format settle stat daydataloader
do
	for msc in huawei alcatel nokia
	do
		path=/data2/wj/center/data/$proc/output/wj/voice/$msc
		count=`l $path |wc -w`
		echo $proc - $msc output: $count
	done
done

echo "ok"
