#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		�ּ�200607���ݵ����λ����ļ�����Ϊ���а�������6�»���
# Author:	fanghm@asiainfo.com
# Usage:	pickup_roam.sh
#--------------------------------------------------------------------#
# .1�ظ������Ƿ��������Ƿ�Ҫ����
	
# for debug
# set -x

#--------------------------------------------------------------------#
# �����ļ��������ļ����ԣ�
# �ļ�����(�ļ���ǰ�����ĸ���֣���ȥ��ǰ���E)
# �ļ������·ݣ��ļ����ж�����yyyymmdd/mmdd, ȡ���·����ڷ��±��ݣ�
# ͬʱ�ж��Ƿ���/�·������ļ�(*571.999/*999.571)
# �������ļ���
# ���أ�file_type / file_month / is_stat_file (0|1)
# NB: ��Щ�ļ����а����»��ߣ���VCARD_DOWN_yyyymmdd571.nnn->VCARD_DOWN
# �ر�أ�����N_CUSMS_HZ_GSMC1_20060705.9992�д��ڷ���������
#--------------------------------------------------------------------#
get_file_attribute()
{
	echo "-->get_file_attribute $* \c"
	
	local len=`echo $1|wc -c`	# �õ��ĳ��ȱ�ʵ�ʳ��Ȼ��1
	
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
# ����ָ���ļ���Ŀ��·����ͬʱ���Ŀ��·���Ƿ���ڣ��������ȴ���
# ���ݷ�ʽ��ͨ��$4ָ��,��ѡֵ��[cp]|mv
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
# ѹ������ָ���ļ���Ŀ��·��
# ����ͬbackup_file
#--------------------------------------------------------------------#
backup_file_with_compress()
{
	echo "-->compress\c"
	
	backup_file $*
	compress -f $3/$2
}

#--------------------------------------------------------------------#
# rename VCARD_DOWN_yyyymmdd571.nnn to VCyyyymmdd571.nnn
# ����: �ļ���
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
# ʡ�ʻ������ݸ�·���������ٰ��·ݡ��������͵�ϸ����Ŀ¼
backroot=/data4/backup/roam/raw
#dstroot=/data3/center/data/acquire/output/roam

# ʡ�ʻ���Դ·��
# srcpath=/data4/pickup/200606
srcpath=/data4/backup/roam/raw/200607

count=0

cd $srcpath
for subpath in $(ls)
do
	# skip files
	if [ -d $srcpath/$subpath ]; then
		cd $srcpath/$subpath
		echo "=== $subpath ==="
	else
		continue
	fi
	
	for file in $(ls)
	do
		# skip directories
		if [ -d $file ]; then
			echo "====ERROR===="
			continue
		fi
		
		### test only
		# if [ $count -ge 20 ]; then
		# 	break;
		# fi
		
		count=$(($count+1))
				
		printf "==> %4d %s ...\n" $count $file
		
		file1=`basename $file .Z`
		get_file_attribute $file1
		if [ "$file_month" = "200607" ]; then
			echo ".\c"
			continue
		else
			backpath=$backroot/$file_month/$subpath
			if [ ! -d $backpath ]; then
				echo "--create $backpath \c"
				mkdir -p $backpath		# force to create the directory hierarchy
			fi
			
			echo "mv $file $backpath"
			mv $file $backpath
		fi
				
		echo "<== ok\n"
		
	done

done

echo "<== a-ok\n"

echo "pickup $count files."

exit 0
