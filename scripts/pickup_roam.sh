#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		pickup and backup roam raw sheet files
#			mv dup file to dup path
#			mv stat file(*571.999/*999.571) to stat path
# Author:	fanghm@asiainfo.com
# Usage:	pickup_roam.sh
# History:
#	2007/1/29	add to deal error sheets,YM/IPD
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

	is_stat_file=0
	is_error_088=0
	if [ "$tail" = "571.999" -o "$tail" = "999.571" ]; then
		is_stat_file=1
	elif [ "$tail" = "571.088" ]; then
		is_error_088=1
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
		file_month="2010$file_month"			########### MODIFY ############
	fi
	
	index=$(($index-1))
	is_error_file=0
	if [ $(echo $1|cut -c 1) = "E" ]; then	# error sheet
		file_type=`echo $1|cut -c 2-$index`
		if [ $is_error_088 -ne 1 ]; then
			is_error_file=1
		fi
	elif [ $(echo $1|cut -c $index) = "_" ]; then	# remove last underline
		index=$(($index-1))
		file_type=`echo $1|cut -c -$index`
	else
		file_type=`echo $1|cut -c -$index`
	fi
	
	if [ "$file_type" = "N_CUSMS_HZ_GSMC" ]; then
		file_month=`echo $1|cut -d _ -f 5|cut -c -6`
	fi
	if [ "$file_type" = "N_SMS_HZ_HWSMC" ]; then
		file_month=`echo $1|cut -d _ -f 5|cut -c -6`	
	fi
	if [ "$file_type" = "MCBBJ" ]; then
		
		file_type=`echo $1|cut -c -8`
		file_month=`echo $1|cut -d _ -f 5|cut -c -6`
		mcbbj_type=`echo $1|cut -d _ -f 4|cut -c -4`
		if [ "$mcbbj_type" = "INFO" ]; then
			file_type="MCBBJ_INFO"
		fi	
	fi
#add by guyb 4 N_GSM_IP
	if [ $(echo $1|cut -c 1-8) = "N_GSM_IP" ]; then  # error sheet
		file_type="N_GSM_IP"
	fi

#add by sunxh ---12580   20090304
      if [ $(echo $1|cut -c 1-5) = "12580" ]; then  # error sheet
		file_type="12580"
		file_month=`echo $1|cut -c 10-15`
	fi
#add by sunxh---modify YYWG's file_month 20090304
 if [ $(echo $1|cut -c 1-4) = "YYWG" ]; then  # error sheet    

		  file_month=`echo $1|cut -c 6-11`           

   fi
#####
	echo "<-- return $file_type $file_month is_stat_file:$is_stat_file is_error_file:$is_error_file"
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
backup_file_compress()
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
backroot=/data4/backup/roam
dstroot=/data3/center/data/acquire/output/roam
duppath=/data4/pickup/DUP

# 省际话单源路径（采集进程从集中采集机、计费主机上采集过来的上下发话单及错单路径）
srcpath=/data4/pickup/prov
# srcpath=$dstroot/unknown

cd $srcpath

count=0
for file in $(ls)
do
	# skip directories
	if [ -d $file ]; then
		continue
	fi

	# skip compressed file
	file2=`basename $file .Z`
	if [ "$file" != "$file2" ]; then
		backup_file $srcpath $file $duppath mv
		continue
	fi

	# test only
	# if [ $count -ge 100 ]; then
	# 	break;
	# fi
	
	count=$(($count+1))
			
	printf "==> %4d %s ...\n" $count $file
	
	get_file_attribute $file
	
	if [ $is_stat_file -eq 1 ]; then
		backup_file_compress $srcpath $file $backroot/$file_month/raw/stat	mv
	else
		case "$file_type" in
			G|IG)		subpath="gprs";;
			CNG)		subpath="cng";;
                        GP)           subpath="sp/gp";;
			12580)        subpath="sp/12580";;   #12580  add by sunxh 20090304
		     CNGO)            subpath="cngo";;
			PSMS)        subpath="sp/sms";;   #PSMS  add by sunxh 20090728
			CNGI)            subpath="cngi";;
			CG)		subpath="cg";;		#cg_moto
			CGN)		subpath="cgn";;		#cg_nokia
			VCARD_DOWN)	rename_vcard_down_file $file; subpath="refill/vc";;
			VC)		subpath="refill/vc";;	
#			VIPI|VIPO)	subpath="refill/vip";;
			GD) 		subpath="sp/kjava";;
			MM) 		subpath="sp/mms";;
			IIM) 		subpath="sp/iim";;
			MP)		subpath="sp/mp";;
			CRG)		subpath="sp/crg";;
			CM|OS|BSMS)		subpath="sp/sms";;
			SM)		subpath="sp/sm";;
			W|FLH|PDA)	subpath="sp/wap";;
			IPI|IPO)	subpath="voice/ipcard";;
#			IPG)		subpath="sp/ipg";;	# intl dialing to Internet
			K)		subpath="voice/korea";;
			B)              subpath="voice/b";;
			EB)             subpath="voice/eb";;
			PPS)		subpath="voice/pps";;
			R|Q)		subpath="voice/rq";;
			D|I|RD|SD|ID)	subpath="voice/voice";;
#			VPI|VPO)	subpath="new/vp";;
			STM)		subpath="sp/stm";;
			N_MPPE_HZ)	subpath="sp/nmpp";;	# N_MPPE_HZ
			N_CUSMS_HZ_GSMC)subpath="gsmc";;	# N_CUSMS_HZ_GSMC[1|2]
			N_SMS_HZ_HWSMC) subpath="sp/wnsms";;
			RMM)		subpath="rmm";;
			MCBBJ_01)	subpath="sp/mcbbj1";;
			MCBBJ_00)	subpath="sp/mcbbj0";;
			MTHUS)		subpath="sp/mthus";;
			MTHSP)		subpath="sp/mthsp";;
			IIS)		subpath="sp/iis";;
			MAP)		subpath="sp/map";;
			YYWG)           subpath="sp/yywg";;
			N_GSM_IP)	subpath="voice/ngsmip";;
			*)		subpath="unknown";;	# AI|AO|HU|M|VPMN|PM ...
		esac
				
		if [ "$subpath" = "gsmc" ]; then
			day=`echo $file|cut -d _ -f 5|cut -c 7-8`
			backpath=/data4/backup/wjsms/$file_month/raw/$day
			
			# checked duplicate files	
			if [ -f "$backpath/${file}.Z" ]; then
				backup_file $srcpath $file $duppath mv
				continue
			fi
					
			backup_file_compress $srcpath $file $backpath
				
			dstpath="/data2/wj/center/data/acquire/output/wj/sms"
			backup_file $srcpath $file $dstpath mv
			
		elif [ "$subpath" = "unknown" ]; then	# -o $is_error_file -eq 1
			backup_file_compress $srcpath $file $backroot/$file_month/raw/$file_type mv
		else
			if [ -f "$backroot/$file_month/raw/$file_type/${file}.Z" ]; then
				backup_file $srcpath $file $duppath mv
				continue
			fi
					
			backup_file_compress $srcpath $file $backroot/$file_month/raw/$file_type
			
			if [ "$file_type" = "MTHUS" ]; then
				backup_file $srcpath $file $dstroot/sp/mthus2
			fi	
			dstpath=$dstroot/$subpath
			backup_file $srcpath $file $dstpath mv
		fi
		
	fi
	echo "<== ok\n"
	
done

echo "pickup $count files."

exit 0
