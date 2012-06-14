#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		分拣指定srcpath下的漫游话单文件
# Author:	fanghm@asiainfo.com
# Usage:	pickup_roam.sh
#--------------------------------------------------------------------#
# .1重复话单是否会产生，是否要处理？
	
# for debug
set -x

#--------------------------------------------------------------------#
# 根据文件名分析文件属性：
# 文件类型(文件名前面的字母部分，错单去掉前面的E)
# 文件名中月份（文件名中都包含yyyymmdd/mmdd, 取出月份用于分月备份）
# 同时判断是否上/下发汇总文件(*571.999/*999.571)
# 参数：文件名
# 返回：file_type / file_month / is_stat_file (0|1)
# NB: 有些文件名中包含下划线，如VCARD_DOWN_yyyymmdd571.nnn->VCARD_DOWN
# 特别地，对于N_CUSMS_HZ_GSMC1_20060705.9992中存在非日期数字
#--------------------------------------------------------------------#
get_file_attribute()
{
	echo "-->get_file_attribute $* \c"
	
	local len=`echo $1|wc -c`	# 得到的长度比实际长度会多1
	
	local index=$(($len-7))
	local tail=`echo $1|cut -c $index-$len`
	if [ "$tail" = "571.999" -o "$tail" = "999.571" ]; then
		is_stat_file=1
	else
		is_stat_file=0
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
	if [ $(echo $1|cut -c 1) = "E" ]; then	# error sheet
		file_type=`echo $1|cut -c 2-$index`
	elif [ $(echo $1|cut -c $index) = "_" ]; then	# remove last underline
		index=$(($index-1))
		file_type=`echo $1|cut -c -$index`
	else
		file_type=`echo $1|cut -c -$index`
	fi
	
	if [ "$file_type" = "N_CUSMS_HZ_GSMC" ]; then
		file_month=`echo $1|cut -d _ -f 5|cut -c -6`
	fi
	
	echo "<-- return $file_type $file_month is_stat_file:$is_stat_file"
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
#dstroot=/data3/center/data/acquire/output/roam

# 省际话单源路径
srcpath=/data4/pickup/200606
# srcpath=$dstroot/unknown

cd $srcpath

count=0
for file in $(ls)
do
	# skip directories
	if [ -d $file ]; then
		continue
	fi
	
	file1=`basename $file .Z`
	if [ "$file" != "$file1" ]; then
		echo "compressed file"
		continue
	fi
	
	### test only
	# if [ $count -ge 100 ]; then
	# 	break;
	# fi
	
	count=$(($count+1))
			
	printf "==> %4d %s ...\n" $count $file
	
	get_file_attribute $file
	
	if [ $is_stat_file -eq 1 ]; then
		file_type=stat
	fi
	
	backpath=$backroot/$file_month/$file_type
	backpath2=$backroot/200607/$file_type
	
	if [ -f "$backpath/${file}.Z" -o -f "$backpath2/${file}.Z" ]; then
		if [ -f "$backpath2/$file" ]; then
			echo "mv existed $file"
			if [ ! -d $backpath ]; then
				echo "--create $backpath \c"
				mkdir -p $backpath		# force to create the directory hierarchy
			fi
			mv -f $backpath2/${file}.Z $backpath
		fi
		
		echo "rm existed $file"
		rm -f $file
	else
		mv -f $file /data4/pickup/prov
	fi
	
	echo "<== ok\n"
	
done

echo "pickup $count files."

exit 0
