#!/bin/sh
#--------------------------------------------------------------------#
# Desc:		ͳ��ĳ�±��ݵ����λ����ļ���ĳ�����ļ���������Ҫ��Ϊ�˼���ļ��Ƿ�ȱ��
# Author:	fanghm@asiainfo.com
# Usage:	stat_backed_files.sh
#--------------------------------------------------------------------#
# .1�ظ������Ƿ��������Ƿ�Ҫ����
	
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
# �����ļ��������ļ����ԣ�
# �ļ�����(�ļ���ǰ�����ĸ����a)
# �ļ������·ݣ��ļ����ж�����yyyymmdd/mmdd, ȡ���·����ڷ��±��ݣ�
# ͬʱ�ж��Ƿ���/�·������ļ�(*571.999/*999.571)
# �������ļ���
# ���أ�file_type / file_month / file_cat (ST|UP|DN|EUP|EDN|NA)
# NB: ��Щ�ļ����а����»��ߣ���VCARD_DOWN_yyyymmdd571.nnn->VCARD_DOWN
# �ر�أ�����N_CUSMS_HZ_GSMC1_20060705.9992�д��ڷ���������
#--------------------------------------------------------------------#
get_file_attribute()
{
	#echo "-->get_file_attribute $* \c"
	
	local len=`echo $1|wc -c`	# �õ��ĳ��ȱ�ʵ�ʳ��Ȼ��1
	
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

# ʡ�ʻ�������·��
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
