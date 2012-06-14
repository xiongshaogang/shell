#!/bin/sh
set -x

################################################################################
# Script for WJ-REDO
# To execute after stored procedured 'proc_redo_wj' has executed successfully
# Usage:
# 		REDO.sh <redo_task_time>
#		redo_task_time - format:'YYYYMMDDHH24MISS'
#						��������ʼʱ�䣬��dps_redo_logһ��
#			
# NOTE: 
################################################################################
# ���ݻ�����ʼ���̣������ݿ��л�ȡԴ����·����Ŀ��·��(src, dst)
# ȡ��һ���̱���·���±��ݻ����ļ���Ϊ���λ������뻰��
# ������proc_fr - ������ʼ����
# ֻ��nokia�ؿھ�·��Ϊ׼,����·����ȥ������'/nokia'
get_path()
{
sqlplus aijs/aijs@testjs > /dev/null 2>&1 << SQLEOF
spool $temp;
select substr(param_value,1,Length(param_value)-6) from sys_module_param_detail where module_id in (
select module_id from sys_module where program_name ='$1' and module_code like '%_nokia'
) and param_code in ('backupPath', 'inputPath');
spool off;
exit
SQLEOF
	
	echo === sys_module_param_detail ===
	cat $temp
	echo =========================
	
	line=`awk -F " " ' /\// { print }' $temp | wc -l`
	
	# �����޶�Ӧ��¼�����2����¼
	if [ $line -ne 2 ]; then
		echo "bad records in sys_module_param_detail."
		exit -5
	fi
	
	local n=1
	for line in $(awk -F " " ' /\// { print $1 }' $temp)
	do
		if [ n -eq 1 ]; then
			src=$line
		else
			dst=$line
		fi
		
		n=$(($n+1))
	done
	
	echo "src: ${src}"
	echo "dst: ${dst}"
}

# ����ƥ��ģʽ��ȡ�ļ�
# ������pattern - �ļ�ƥ���
get_file()
{
	echo === get_file: ${1} ===
	local n=0
	
	# all params as subdir collection 
	for subdir in huawei nokia alcatel; do
		if [ -e ${src}/${subdir}/${1} ]; then
		for file in $(ls ${src}/${subdir}/${1} )
		do
			echo $file
			# echo $file >> $log
			# mv $file $dst/$subdir
	
			# ignore automatically if not gzip file
			# gunzip -f $dst/$subdir/$file
				
			n=$(($n + 1))
		done
		fi
	done
	
	if [ $n -lt 1]; then
		echo "=== Error: file not found!"
	fi
	
	count=$(($count + $n))		# added to $count
	
	echo "=== end of ${1}: $n ==="
}

# ����ʱ��͵����ɼ��ļ�
# param: $begin $area
fetch_files()
{
	echo
	echo === fetch_files: $1 $2 ===
	local pattern
	if [ $2 = 'all' ]; then
		pattern="N_GSM*_${1}.*"		# һ��Ϊgzѹ���ļ�
		get_file $pattern
	else
		# areas=`$2|cut -d ',' -f 1-10` # ���10�����аɣ�11������all
		local areas=`echo $2|awk 'BEGIN {FS=","; OFS=" "} {print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10}' `
		echo "|areas|=|${areas}|"
		
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
			
			pattern="N_GSM_${code}_*_${begin}.*"
			get_file $pattern
		done
	fi
	
	echo === end of fetch_files: $1 $2 ===
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
clear
if [ $# -ne 1 ]; then
	print "Bad parameters!"
    print "Usage:"
    print "\t $0 <redo_task_time>"
    print "\t redo_task_time - format:'YYYYMMDDHH24MISS', corresponding to begin_time of dps_redo_log"
    print "eg:"
    print "\t $0 20060324121449"
    
    # for test only
    set 20060324161701
    echo $1
    
    # exit -1;
fi

logpath=`echo $SYS_LOG_PATH`
tail=$1		# tail=`date +%Y%m%d%H%M$S`

log=$logpath/REDO_${tail}.log
echo $log

temp=$logpath/REDO_${tail}.temp
filelist=$logpath/REDO_${tail}.filelist


# ����dps_redo_log������������ʼʱ��ȡ��ǰ����������Ϣ
sqlplus aijs/aijs@testjs > /dev/null 2>&1 << SQLEOF
set line 200;    
col area for a40;

spool $log;
select date_fr, date_to, lower(area) area, status, proc_fr, 
	to_char(to_date(date_fr, 'YYYYMMDD')+1, 'YYYYMMDD') fr_next,
	to_char(to_date(date_to, 'YYYYMMDD')+1, 'YYYYMMDD') to_next from dps_redo_log
	--where to_char(begin_time, 'YYYYMMDDHH24MISS') = '$1'
	where status=1;
spool off;

exit
SQLEOF

echo === dps_redo_log info ===
cat $log
echo =========================
echo

line=`awk -F " " ' /^200/ { print }' $log | wc -l`

# �����޶�Ӧ��¼�����һ����¼
if [ $line -ne 1 ]; then
	echo "current redo records != 1: $line"
	exit -2
fi

from=`awk -F " " ' /^200/ { print $1 }' $log`
to=`awk -F " " ' /^200/ { print $2 }' $log`

area=`awk -F " " ' /^200/ { print $3 }' $log`
status=`awk -F " " ' /^200/ { print $4 }' $log`
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
src="/data33/aijs/center/back/settle/wj/voice/*"	# �����������ؿھ�
dst="/data33/aijs/center/data/format/output/wj/voice"
get_path $proc_fr

echo ================================================
# ��ֹʱ��һ�£�ֻ����һ�컰������ȫ����filelistȡ����
# ����������
# 1.ֻ����filelist���ļ���������ȡ$from �� $to+1����Ļ���,
# 2.����ֱ�Ӵ��ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���

# ����dps_redo_files������������ʼʱ��ȡ�����ļ��б�
sql="select file_name from dps_redo_files where deal_date='$1'"

if [ $from != $to ]; then
	sql="${sql} and substr( file_name, instr(file_name, '_', 1, 4)+1, 8) in ('$from', '$tonext')"
fi		
echo $sql

sqlplus aijs/aijs@testjs > /dev/null 2>&1 << SQLEOF
spool $filelist;
	${sql};
spool off;
exit
SQLEOF

echo ==== filelist ====
cat $filelist
echo ==================

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

	
# ���ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���
# ע���·��л�
# �ؿھֻ����ļ���ʾ����N_GSM_WZ_HWGW4_20060101.00967384.gz
if [ $from != $to ]; then
	if [ $(($to - $frnext)) -le 30 ]; then 	# ���·��л�
		begin=$frnext
		while [ ${begin} -le ${to} ]; do
			fetch_files $begin $area
			begin=$(($begin + 1))
		done
		
	else # ���������·��л�
		list=""
		get_day_list $frnext $to
		
		day_list=$list 		# �������õõ�
		for day in $day_list
		do
			fetch_files $day $area
		done
	fi
fi	

echo TOTAL_FILE_COUNT: $count
echo "A-OK!"

exit 0
