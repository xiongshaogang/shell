#!/bin/sh
#--------------------------------------------------------------------#
# rm dup file from src path
# Author:       fanghm@asiainfo.com
#--------------------------------------------------------------------#

# for debug
#set -x

srcpath=/data2/wj/center/data/acquire/output/wj/voice/alcatel
dstpath=/data4/backup/wjvoice/raw/200612

cd $srcpath

count=0
for file in $(ls)
do
	if [ -f "$dstpath/29/$file.Z" -o -f "$dstpath/31/$file.Z" ]; then
		echo "DUP: $file"
		rm -f $file
	else
		echo "Normal:$file"
	fi
done

exit 0
