#!/bin/sh
# set -x	# for dubug
#--------------------------------------------------------------------#
# 文件批量改名
# Author: fanghm
#--------------------------------------------------------------------#
# set "*tarfile*" "{tarfile_prefix}" voice_prep /data4/backup/wjvoice/prep/alcatel
# set rename.sh "*GSM*" GSM GSMSP /data1/home/jsusr1/center/zwjf_scripts/data

# echo $*
if [ $# -lt 3 ]; then
    print "Bad parameters!"
    print "Usage: rename.sh <file_pattern> <src_str> <dest_str> [src_path]"
    print "Notice to add '\' before special character in src_str/dest_str!"
    exit -1;
fi

if [ -n "$4" ]; then
	cd $4
	echo $PWD
fi

count=`ls -l $1|wc -l`
echo "$count files to be renamed..."

count=0
for file in $(ls $1)
do
	if [ -f "$file" ]; then
		newfile=`echo "$file"|sed "s/$2/$3/g"`
		#newfile=`echo "$file"|sed "s/{tarfile_prefix}/voice_prep/g"`
		
		if [ -f "$newfile" ]; then
			echo "Error: $newfile existed."
			newfile="$newfile_1"	# add "." to filename tail
		fi
		
		echo "rename $file to $newfile ..."
		mv -f "$file" "$newfile"	# if run under background, add -f option
		count=$(($count + 1))
	fi
	
	# if [ $count -gt 0 ]; then
	# 	break
	# fi
done

echo $count files renamed.
