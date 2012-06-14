#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		统计某月备份的漫游话单文件，某类型文件个数，主要是为了检查文件是否缺少
# Author:	fanghm@asiainfo.com
# Usage:	stat_backed_files.sh
#--------------------------------------------------------------------#
# .1重复话单是否会产生，是否要处理？
	
# for debug
# set -x
# set 200606

if [ $# -ne 1 ]; then
    print "Bad parameters!"
    
    print "Usage:"
    print "\t stat_backed_files.sh <stat_month>"
    print "\t stat_month - format:'YYYYMM', say '200607'"
        
    exit -1;
fi

#--------------------------------------------------------------------#
# 根据文件名分析文件属性：
# 文件类型(文件名前面的字母部分a)
# 文件名中月份（文件名中都包含yyyymmdd/mmdd, 取出月份用于分月备份）
# 同时判断是否上/下发汇总文件(*571.999/*999.571)
# 参数：文件名
# 返回：file_type / file_month / file_cat (ST|UP|DN|EUP|EDN|NA)
# NB: 有些文件名中包含下划线，如VCARD_DOWN_yyyymmdd571.nnn->VCARD_DOWN
# 特别地，对于N_CUSMS_HZ_GSMC1_20060705.9992中存在非日期数字
#--------------------------------------------------------------------#
get_file_attribute()
{
	#echo "-->get_file_attribute $* \c"
	
	local len=`echo $1|wc -c`	# 得到的长度比实际长度会多1
	
	local index=$(($len-7))
	local tail=`echo $1|cut -c $index-$len`
	if [ "$tail" = "571.999" -o "$tail" = "999.571" ]; then
		file_cat="ST"
	else
		local h=`echo $tail|cut -c 1-3`
		local t=`echo $tail|cut -c 5-7`
		
		if [ "$h" = "571" ]; then
			file_cat="DN"
		elif [ "$t" = "571" ]; then
			file_cat="UP"
		else
			file_cat="NA"
		fi
	fi
	
	index=1
	while [ $index -lt $len ]; do
		local c=`echo $1|cut -c $index`
		case $c in
			[ABCDEFGHIJKLMNOPQRSTUVWXYZ_])	index=$(($index+1));;
			*)	break;;
		esac
	done
	
	if [ $c = "2" ]; then	# yyyymm, say 200607
		local to=$(($index+5))
		file_month=`echo $1|cut -c $index-$to`
	else	# mm
		local to=$(($index+1))
		file_month=`echo $1|cut -c $index-$to`
		file_month="2006$file_month"			########### MODIFY ############
	fi
	
	index=$(($index-1))
	#if [ $(echo $1|cut -c 1) = "E" ]; then	# error sheet
	#	file_type=`echo $1|cut -c 2-$index`

	if [ $(echo $1|cut -c 1) = "E" ]; then	# error sheet
		file_cat="E"$file_cat
	elif [ $(echo $1|cut -c $index) = "_" ]; then	# remove last underline
		index=$(($index-1))
		file_type=`echo $1|cut -c -$index`
	else
		file_type=`echo $1|cut -c -$index`
	fi
	
	if [ "$file_type" = "N_CUSMS_HZ_GSMC" ]; then
		file_month=`echo $1|cut -d _ -f 5|cut -c -6`
	fi
	
	#echo "<-- return $file_type $file_month $file_cat"
}

#--------------------------------------------------------------------#
# 备份指定文件到目的路径，同时检查目的路径是否存在，不存在先创建
# 备份方式可通过$4指定,可选值：[cp]|mv
# param: <src_path> <src_file> <dest_path> <backup_cmd>
#--------------------------------------------------------------------#
backup_file()
{
	echo "-->backup $4 $2 -> $3 \c"
	
	local dest_path=$3
	if [ ! -d $dest_path ]; then
		echo "--create $dest_path \c"
		mkdir -p $dest_path		# force to create the directory hierarchy
	fi
	
	backup_cmd="$4"
	if [ -z "$backup_cmd" ]; then
		backup_cmd="cp"
	fi
	
	eval '$'backup_cmd -f $1/$2 $dest_path
		
	# compress -f $dest_path/$2
	
	echo "<-- return: $?"
}

#--------------------------------------------------------------------#
# 压缩备份指定文件到目的路径
# 参数同backup_file
#--------------------------------------------------------------------#
backup_file_with_compress()
{
	echo "-->compress\c"
	
	backup_file $*
	compress -f $3/$2
}

#--------------------------------------------------------------------#
# rename VCARD_DOWN_yyyymmdd571.nnn to VCyyyymmdd571.nnn
# 参数: 文件名
#--------------------------------------------------------------------#
rename_vcard_down_file()
{
	local newname=`echo $1|sed "s/VCARD_DOWN_/VC/g"`
	
	echo "rename $1 to $newname \c"
	mv $1 $newname
	
	file_type="VC"
	file=$newname
}

######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
# 省际话单备份根路径，下面再按月份、话单类型等细分子目录
backroot=/data4/backup/roam/raw

# 省际话单备份路径
srcpath=$backroot/$1

echo "stat path: $srcpath"
echo "this script may cost some time, pls wait..."

cd $srcpath

for subpath in CM D FLH G I IG K KJ MM OS PDA PPS Q R RD SD STM VC W YM		# $(ls)
do
	# skip stat path
	if [ "$subpath" = "stat" -o "$subpath" = "N_MPPE_HZ" ]; then
		continue
	fi
	
	# skip files
	if [ -d $srcpath/$subpath ]; then
		cd $srcpath/$subpath
		echo "=== $subpath ==="
	else
		echo "path not found: $subpath"
		continue
	fi
	
	COUNT_UP=0
	COUNT_DN=0
	COUNT_EUP=0
	COUNT_EDN=0
	COUNT_NA=0
	
	for file in $(ls)
	do
		# skip directories
		if [ -d $file ]; then
			echo "=== ERROR NOT FILE: $file ==="
			continue
		fi
		
		file1=`basename $file .Z`
		get_file_attribute $file1
		if [ "$file_month" != "$1" ]; then
			echo "=== ERROR file_month puzzle ==="
			mv $file /data4/pickup/puzzle
		fi
		
		case "$file_cat" in
			UP) 	COUNT_UP=$(($COUNT_UP+1));;
			DN) 	COUNT_DN=$(($COUNT_DN+1));;
			EUP)	COUNT_EUP=$(($COUNT_EUP+1));;
			EDN)	COUNT_EDN=$(($COUNT_EDN+1));;
			NA) 	COUNT_NA=$(($COUNT_NA+1));;
			*)  	COUNT_NA=$(($COUNT_NA+1));;
		esac
			
	done

	for count_type in COUNT_UP COUNT_DN COUNT_EUP COUNT_EDN COUNT_NA
	do
		eval count="$"$count_type
		if [ $count -gt 0 ]; then
			echo "$count_type\t: $count"
		fi
	done
	
	echo		
	#break;
	
done

echo "<== a-ok\n"

exit 0
