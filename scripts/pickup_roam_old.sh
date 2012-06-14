#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		pickup and backup roam raw sheet files and mv stat file(*571.999/*999.571) to certain path
# Author:	fanghm@asiainfo.com
# Usage:	pickup_roam_sheets.sh
#--------------------------------------------------------------------#
# .1重复话单是否会产生，是否要处理？
	
# for debug
# set -x

#--------------------------------------------------------------------#
# 根据文件名得到文件类型(文件名前面的字母部分，错单去掉前面的E)
# 参数：文件名
# 有些文件名中包含下划线，如VCARD_DOWN_yyyymmdd571.nnn->VCARD_DOWN
#--------------------------------------------------------------------#
get_file_type()
{
	echo "==>get_file_type $* \c"
	local len=`echo $1|wc -c`
	local index=1
	
	while [ $index -lt $len ]; do
		local c=`echo $1|cut -c $index`
		case $c in
			[ABCDEFGHIJKLMNOPQRSTUVWXYZ_])	index=$(($index+1));;
			*)	break;;
		esac
	done
	
	index=$(($index-1))
	if [ $(echo $1|cut -c 1) = "E" ]; then	# error sheet
		file_type=`echo $1|cut -c 2-$index`
	elif [ $(echo $1|cut -c $index) = "_" ]; then	# remove last underline
		index=$(($index-1))
		file_type=`echo $1|cut -c -$index`
	else
		file_type=`echo $1|cut -c -$index`
	fi
	
	echo "<== return $file_type"
}

#--------------------------------------------------------------------#
# 判断是否上/下发汇总文件(*571.999/*999.571)
# 参数：文件名
#--------------------------------------------------------------------#
judge_stat_file()
{
	echo "==>judge_stat_file $* \c"
	local pos=`echo $1|cut -d . -f 1|wc -c` #文件名中点的位置
	local fr=$(($pos-3))
	local to=$(($pos-1))
	local str1=`echo $1|cut -c ${fr}-$to`
	
	fr=$(($pos+1))
	to=$(($pos+3))
	local str2=`echo $1|cut -c ${fr}-$to`
	
	if [ "$str1" = "999" -o "$str2" = "999" ]; then
		is_stat_file="Y"
	else
		is_stat_file="N"
	fi
	
	echo "<==return $is_stat_file"
}

#--------------------------------------------------------------------#
# make backup with compress
# param: <src_file> <src_path> <file_type>
#--------------------------------------------------------------------#
backup_file()
{
	echo "==>backup_file $* \c"
	local dest_path=$backroot/$3
	if [ ! -d $dest_path ]; then
		echo "--create $dest_path \c"
		mkdir -p $dest_path		# force to create the directory hierarchy
	fi
	
	cp -f $2/$1 $dest_path
	compress -f $dest_path/$1
	echo "<==backup_file end."
}

######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
# 省际话单备份根路径，下面再按话单类型细分子目录
backroot=/data4/backup/roam/raw
dstroot=/data3/center/data/acquire/output/roam

# 省际话单源路径（采集进程从集中采集机、计费主机上采集过来的上下发话单及错单）
srcpath=/data4/pickup/prov
# srcpath=$dstroot/unknown

cd $srcpath

count=0
for file in $(ls)
do
	if [ -d $file ]; then
		continue
	fi

	# test only
	# if [ $count -ge 1 ]; then
	# 	break;
	# fi
	
	count=$(($count+1))
			
	printf "--> %4d %s ...\n" $count $file
	judge_stat_file $file
	
	if [ "$is_stat_file" = "Y" ]; then
		mv $file $backroot/stat	# no compress, for process later
	else
		get_file_type $file
		echo $file_type
		case "$file_type" in
			G|FG|IG|FIG)			subpath="gprs";;
			VCARD_DOWN|VC|FVC)		subpath="refill/vc";;	# VCARD_DOWN
			VIPI|VIPO)				subpath="refill/vip";;
			CH|FCH)					subpath="sp/ch";;
			KJ)						subpath="sp/kjava";;
			MM)						subpath="sp/mms";;
			CM|YM|OS)				subpath="sp/sms";;
			W|PDA)					subpath="sp/wap";;
			IPI|IPO)				subpath="voice/ipcard";;
			K|FK)					subpath="voice/korea";;
			PPS|FPPS)				subpath="voice/pps";;
			R|FR|Q|FQ)				subpath="voice/rq";;
			D|I|RD|SD|FSD|FD|FI|FRD)subpath="voice/voice";;
			VPI|VPO)				subpath="new/vp";;
			FLH)					subpath="new/flash";;
			STM)					subpath="new/stream";;
			N_MPPE_HZ)				subpath="new/xezf";;	# N_MPPE_HZ
			N_CUSMS_HZ_GSMC)		subpath="gsmc";;		# N_CUSMS_HZ_GSMC[1|2]
			*)						subpath="unknown";;
		esac
		
		dstpath=$dstroot/$subpath
		if [ "$subpath" = "gsmc" ]; then
			dstpath="/data2/wj/center/data/acquire/output/wj/sms"
			
			date=`echo $file|cut -d _ -f 5|cut -c 1-8`
			backpath=/data4/backup/wj/sms/raw/$date
			if [ ! -d $backpath ]; then
				echo "--create $backpath \c"
				mkdir -p $backpath		# force to create the directory hierarchy
			fi
			
			# if [ $date -le 20060702 ]; then
			# 	echo "--mv $file to $backpath"
			# 	mv $file $backpath
			# 	compress -f $backpath/$file
			# else
				cp -f $file $backpath
				compress -f $backpath/$file
				
				echo "--mv $file to $dstpath"
				mv $file $dstpath
			# fi
			
			continue
		fi
		
		if [ ! -d $dstpath ]; then
			echo "--create $dstpath \c"
			mkdir -p $dstpath
		fi
		
		if [ "$file_type" = "VCARD_DOWN" ]; then		# rename VCARD_DOWN_yyyymmdd571.nnn to VCyyyymmdd571.nnn
			newname=`echo $file|sed "s/VCARD_DOWN_/VC/g"`
			
			echo "rename $file to $newname \c"
			mv $file $newname
			file_type="VC"
		fi
		
		backup_file $file $srcpath $file_type
		
		echo "mv $file to $dstpath"
		mv $file $dstpath
		
	fi
	echo " ok."
	
	
done

echo "pickup $count files."

exit 0
