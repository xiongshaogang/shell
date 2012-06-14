#!/bin/sh
# $1 - msc

if [ $# -ne 1 ]; then
	echo "Usage:	reclaim_trunk.sh <msc_type>"
	exit -1
else
	subdir="$1"
fi

echo "--- begin ---"

# settle input path
src=/data2/wj/center/error/settle/wj/voice
dst=/data2/wj/center/data/format/output/wj/voice

for file in $(ls ERROR*) 	#ERROR_N_GSM_LS_HWGW*)  # N_GSM_WZ_HWGW9*)
do
	if [ -f $file ]; then
		# get error files due to unknown trunk
		if grep -q 130103$ $file
		then
			echo "reclaim $file"
			mv $file $dst/$subdir
		else
			mv $file useless
		fi
	fi
done

echo "--- done ---"

exit 0
