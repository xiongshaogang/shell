#!/bin/sh

################################################################################
# Script for WJ-REDO
# Copyright(c) Asiainfo Inc.
# Author: fanghm
# 
# To execute after stored procedured 'proc_redo_wj' has executed successfully
# Usage:
# 		REDO.sh <redo_task_time> [db_connect_string]
#		redo_task_time - format:'YYYYMMDDHH24MISS', corresponding to dps_redo_log.begin_time
#		db_connect_string - format: user/pwd@db_name
#			
# NOTE: db_connect_stringȱʡֵ�ɴ�DB_CONNECT_STRING���滻
# 		��Ԥ����(prepmain)��ʼ����ʱ�����ڰ������ػ��ˣ������е���һ����ˣ�
#		ͬʱ����sys_module_param_detail�������ø�Ԥ������̵�backupPathΪԭʼ��������·��		
################################################################################
debug=1		# 1 - debug mode(don't really mv files for redo, just show wanted file info), 
			# 0 - normal mode

if [ $debug -eq 1 ]; then
	# set -x	# for dubug
	    
    # for test only
    set 20060324161701
fi

clear
if [ $# -eq 0 ]; then
	print "Bad parameters!"
    print "Usage:"
    print "\t $0 <redo_task_time> [db_connect_string]"
    print "\t redo_task_time - format:'YYYYMMDDHH24MISS'"
    print "\t                  corresponding to dps_redo_log.begin_time"
    print "\t db_connect_string - format: user/pwd@db_name"
    print "eg:"
    print "\t $0 20060324121449 js/js@testjs"
	
	exit -1;
fi

DB_CONNECT_STRING="aijs/aijs@testjs"
if [ -n "$2" ]; then
	DB_CONNECT_STRING="$2"
fi

################################################################################
# function definitions

# ����ƥ��ģʽ��ȡ�ļ�
# ������pattern - �ļ�ƥ���
get_file()
{
	echo
	echo === get_file: ${1}
	local n=0
	
	# all params as subdir collection 
	for subdir in huawei nokia alcatel; do
		if [ -e ${src}/${subdir}/${1} ]; then
			for file in $(ls ${src}/${subdir}/${1} )
			do
				# get_pure_name $file
				pure_name=`echo $file | sed 's/.*\///g' `

				if [ $debug -eq 0 ]; then
					echo $pure_name
					echo $file >> $log
					mv $file $dst/$subdir
		
					# ignore automatically if not gzip file
					gunzip -f $dst/$subdir/$pure_name
				
				else	# reduce output info
					if [ $n -le 2 ]; then
						echo $pure_name
					else
						echo ".\c"	# no change line
					fi
				fi
					
				n=$(($n + 1))
			done
		fi
	done
	
	if [ $n -lt 1 ]; then
		echo "\n=== Error: file not found!"
	fi
	
	count=$(($count + $n))		# added to $count
	
	echo "\n=== get ${n} file(s)."
	echo
}

# ���ݻ�����ʼ���̣������ݿ��л�ȡԴ����·����Ŀ��·��(src, dst)
# ������proc_fr - ������ʼ����
# ֻ��nokia�ؿھ�·��Ϊ׼,����·����ȥ������'/nokia'
get_path_by_proc_fr()
{
	local path_cond="'backupPath', 'inputPath'"
	local path_num=2
	if [ "$1" = "prepmain" ]; then
		path_cond="${path_cond}, 'dupPath'"
		path_num=3
	fi

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
spool $temp;
select substr(param_value,1,Length(param_value)-6), param_code from sys_module_param_detail where module_id in (
select module_id from sys_module where lower(program_name) =lower('$1') and module_code like '%_nokia'
) and param_code in ($path_cond);
spool off;
exit
SQLEOF
	
#	echo === sys_module_param_detail ===
#	cat $temp
#	echo =========================
	
	# ͳ����/��ʼ������������ַ
	line=`awk -F " " ' /^\// { print }' $temp | wc -l`
	
	# �����޶�Ӧ��¼�����2����¼
	if [ $line -ne $path_num ]; then
		echo "Unmatched records in sys_module_param_detail: $line"
		exit -6
	fi
	
	for line in $(awk -F " " ' /^\// { print}' $temp)
	do
		local path=`echo $line|cut -f 1`
		local which=`echo $line|cut -f 2`
		case $which in
			backupPath)	src=$path;;
			inputPath)	dst=$path;;
			dupPath)	dup=$path;;
		esac
	done
	
	echo "src: $src"
	echo "dst: $dst"
	echo "dup: $dup"
}

# �������ŷָ��ĵ�������Ϊ�ո�ָ��ĵ���ƴ�����
# �磺"571,572" -> "QU HZ"
# ���������ŷָ��ĵ�������
parse_area()
{
	if [ $1 = 'all' ]; then
		area_list=$1
	else
		local areas=`echo $1|awk 'BEGIN {FS=","; OFS=" "} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' `
		echo "|areas|=|${areas}|"
		
		area_list=""
		for city in $areas
		do
			case $city in
				570)	code="QZ";;
				571)	code="HZ";;
				572)	code="HU";;
				573)	code="JX";;
				574)	code="NB";;
				575)	code="SX";;
				576)	code="TZ";;
				577)	code="WZ";;
				578)	code="LS";;
				579)	code="JH";;
				580)	code="ZS";;
			esac
			
			area_list="${area_list} ${code}"
		done
	fi
	
	echo "|area_list|=|${area_list}|"
}		

# ����ʱ��͵����ɼ��ļ�
# param: date
fetch_files()
{
	echo
	echo === fetch_files: $1
	
	local pattern
	if [ "$area_list" = "all" ]; then
		pattern="N_GSM*_${1}.*"		# һ��Ϊgzѹ���ļ�
		get_file ${pattern}
	else
		for city in $area_list
		do
			pattern="N_GSM_${city}_*_${1}.*"
			get_file ${pattern}
		done
	fi
	
	echo === end of fetch_files: $1
	echo
}

# ������ֹ���ڣ��м���£��������Կո�ָ������ڴ���������list�з���
# ��������ֹ����,��ֹ����
get_day_list()
{
	list=$1
	local thisday=$(($1 + 1))
	local last=$thisday
	
	while [ $thisday -le $2 ]; do
		local year=`echo $thisday|cut -c 1-4`
		local month=`echo $thisday|cut -c 5-6`
		local day=`echo $thisday|cut -c 7-8`
		
		# ���㵱���������
		local max=31
		case $month in
			# 1|3|5|7|8|10|12) max=31;;
			4|6|9|11)	max=30;;
			2) max=28;;
		esac
		
		#echo $year $month $day $max
		
		#���꣺�ܱ�400�����������ܱ�4���������ܱ�100����
		if [ $max -eq 28 ]; then 
			# ���������⣿getdays.ksh 19000227 19000302
			if [ `expr $year%400` -eq 0 -o  `expr $year%4` -eq 0 -a `expr $year%100` -ne 0  ]; then
				max=29;
			fi
		fi
		
		# ������ڳ��������������������������1��
		if [ $day -gt $max ]; then
			day=1;
			if [ $month -eq 12 ]; then
				month=1
				year=$(($year+1))
			else
				month=$(($month+1))
			fi
			
			#echo $year $month $day $max          
			thisday=$(($year*10000 + $month*100 + $day))
			#echo "this: ${thisday}"
		fi
		
		# ��������ӵ�list����
		list="${list} ${thisday}"
		
		last=$thisday
		thisday=$(($thisday+1))
	done
	
	echo $list
}


################################# �ű���ʼ ##################################

logpath=`echo $SYS_LOG_PATH`
tail=$1		# tail=`date +%Y%m%d%H%M%S`

log=$logpath/REDO_${tail}.log
# echo $log

temp=$logpath/REDO_${tail}.temp
filelist=$logpath/REDO_${tail}.filelist


# ����dps_redo_log������������ʼʱ��ȡ��ǰ����������Ϣ
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 200;    
col area for a40;

spool $log;
select date_fr, date_to, lower(area) area, status, lower(proc_fr), 
	to_char(to_date(date_fr, 'YYYYMMDD')+1, 'YYYYMMDD') fr_next,
	to_char(to_date(date_to, 'YYYYMMDD')+1, 'YYYYMMDD') to_next from dps_redo_log
	where to_char(begin_time, 'YYYYMMDDHH24MISS') = '$1'
	--where status=1;
spool off;

exit
SQLEOF

# echo === dps_redo_log info ===
# cat $log
# echo =========================
echo

line=`awk -F " " ' /^200/ { print }' $log | wc -l`

# �����޶�Ӧ��¼�����һ����¼
if [ $line -ne 1 ]; then
	echo "current redo records != 1: $line"
	exit -2
fi

# ���˿�ʼ���ڣ���ʽ��yyyymmdd
from=`awk -F " " ' /^200/ { print $1 }' $log`
# ������ֹ���ڣ���ʽ��yyyymmdd,��ֹʱ���м��������
to=`awk -F " " ' /^200/ { print $2 }' $log`

# ���˵������룬�磺'571,574'�����ж���ö��Ÿ���, 'all' ��ʾȫ������
area=`awk -F " " ' /^200/ { print $3 }' $log`
status=`awk -F " " ' /^200/ { print $4 }' $log`

# ������ʼ����, ��sys_module.program_name ����һ��
proc_fr=`awk -F " " ' /^200/ { print $5 }' $log`

frnext=`awk -F " " ' /^200/ { print $6 }' $log`
tonext=`awk -F " " ' /^200/ { print $7 }' $log`		#tonext=$(($to+1))

echo vars: $from,$to,$frnext,$tonext,$area,$status,$proc_fr

# �洢����δִ����ɻ�ִ��ʧ��
if [ $status -ne 1 ]; then
	echo "Stored procedure - 'proc_redo_wj' has not finished successfully."
	echo "Check the table dps_redo_log for detail."
	exit -3
fi

# ���ú��������ݻ�����ʼ���̣������ݿ��л�ȡԴ����·����Ŀ��·��
src="/data33/aijs/center/back/settle/wj/voice"	# �����������ؿھ�
dst="/data33/aijs/center/data/format/output/wj/voice"
get_path_by_proc_fr $proc_fr

# ��Ԥ����ʼ����ʱ��ɾ����Ų�����������ļ�
if [ "$1" = "prepmain" ]; then
	if [ "$area" != "all" ]; then
		echo "To redo from premain, you must redo all cities together."
		exit -5
	fi
	
	if [ -d $dup/redo_bak ]; then
	
	else
		mkdir $dup/redo_bak
		
	day=$from
	while [ $day -le $to ]; do
		if [ $debug -eq 0 ]; then
			mv $dup/*/dup.$day $dup/redo_bak
		else
			echo "should del: $dup/*/dup.$day"
		fi
		
		day=$(($day + 1))
	done
fi
		
echo ================================================
# ��ֹʱ��һ�£�ֻ����һ�컰������ȫ����filelistȡ����
# ����������
# 1.ֻ����filelist���ļ���������ȡ$from �� $to+1����Ļ���,
# 2.����ֱ�Ӵ��ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���
# ����������Ϊ����filelistȡ����ֱ�Ӱ��졢������ƥ�仰����

# ����dps_redo_files������������ʼʱ��ȡ�����ļ��б�
sql="select file_name from dps_redo_files where deal_date='$1'"

if [ $from != $to ]; then
	sql="${sql} and substr( file_name, instr(file_name, '_', 1, 4)+1, 8) in ('$from', '$tonext')"
fi
		
# echo $sql

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
spool $filelist;
	${sql};
spool off;
exit
SQLEOF

# echo ==== filelist ====
# cat $filelist
# echo ==================

line=`awk -F " " ' /N_GSM/ { print }' $filelist | wc -l`
if [ $line -lt 1 ]; then
	echo "redo file list is blank: $line"
	exit -4
fi

# awk -F " " ' /N_GSM/ { print $1 }' $filelist
# awk -F " " ' /N_GSM/ { print $1 }' $filelist|wc -l

# �ļ�����
count=0
		
# �����ļ��б�ȡ�ļ�������Ŀ¼
for file in $(awk -F " " ' /N_GSM/ { print $1 }' $filelist)
do
	get_file "${file}.gz"
done

# �������ŷָ��ĵ�������Ϊ�ո�ָ��ĵ���ƴ�����
# �磺"571,572" -> "QU HZ"
parse_area $area
	
# ���ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���
# ע���·��л�
# �ؿھֻ����ļ���ʾ����N_GSM_WZ_HWGW4_20060101.00967384.gz
if [ $from != $to ]; then
	if [ $(($to - $frnext)) -le 30 ]; then 	# ���·��л�
		begin=$frnext
		while [ $begin -le $to ]; do
			fetch_files $begin
			begin=$(($begin + 1))
		done
		
	else # ���������·��л�
		list=""
		get_day_list $frnext $to
		
		day_list=$list 		# �������õõ�
		for day in $day_list
		do
			fetch_files $day
		done
	fi
fi	

echo REDO_FILE_COUNT: $count

echo "A-OK!"

exit 0

# --- �ű����� ---
