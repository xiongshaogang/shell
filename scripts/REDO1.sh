#!/bin/sh
set -x

################################################################################
# Script for WJ-REDO
# To execute after stored procedured 'proc_redo_wj' has executed successfully
# Usage:
# 		REDO.sh <redo_task_time>
#		redo_task_time - format:'YYYYMMDDHH24MISS'
#						回退任务开始时间，与dps_redo_log一致
#			
# NOTE: 
################################################################################
# 根据回退起始进程，从数据库中获取源话单路径，目的路径(src, dst)
# 取上一进程备份路径下备份话单文件作为本次回退输入话单
# 参数：proc_fr - 回退起始进程
# 只以nokia关口局路径为准,并从路径中去掉最后的'/nokia'
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
	
	# 表中无对应记录或多于2条记录
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

# 根据匹配模式获取文件
# 参数：pattern - 文件匹配符
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

# 根据时间和地区采集文件
# param: $begin $area
fetch_files()
{
	echo
	echo === fetch_files: $1 $2 ===
	local pattern
	if [ $2 = 'all' ]; then
		pattern="N_GSM*_${1}.*"		# 一般为gz压缩文件
		get_file $pattern
	else
		# areas=`$2|cut -d ',' -f 1-10` # 最多10个地市吧，11个就用all
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

# 根据起止日期（中间跨月），返回以空格分隔的日期串，保存在list中返回
# 参数：起止日期,终止日期
get_day_list()
{
	list=$1
	local thisday=$(($1 + 1))
	local last=$thisday
	
	while [ $thisday -le $2 ]; do
		local year=`echo $thisday|cut -c 1-4`
		local month=`echo $thisday|cut -c 5-6`
		local day=`echo $thisday|cut -c 7-8`
		
		# 计算当月最大天数
		local max=31
		case $month in
			# 1|3|5|7|8|10|12) max=31;;
			4|6|9|11)	max=30;;
			2) max=28;;
		esac
		
		#echo $year $month $day $max
		
		#闰年：能被400整除，或者能被4整除而不能被100整除
		if [ $max -eq 28 ]; then 
			# 好象有问题？getdays.ksh 19000227 19000302
			if [ `expr $year%400` -eq 0 -o  `expr $year%4` -eq 0 -a `expr $year%100` -ne 0  ]; then
				max=29;
			fi
		fi
		
		# 如果日期超出当月最大天数，调整到下月1号
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
		
		# 将日期添加到list后面
		list="${list} ${thisday}"
		
		last=$thisday
		thisday=$(($thisday+1))
	done
	
	echo $list
}
################################# 脚本开始 ##################################
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


# 根据dps_redo_log表，按回退任务开始时间取当前回退任务信息
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

# 表中无对应记录或多于一条记录
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

# 存储过程未执行完成或执行失败
if [ $status -ne 1 ]; then
	echo "Stored procedure - 'proc_redo_wj' has not finished successfully."
	echo "Check the table dps_redo_log for detail."
	exit -3
fi

# 调用函数，根据回退起始进程，从数据库中获取源话单路径，目的路径
src="/data33/aijs/center/back/settle/wj/voice/*"	# 下面有三个关口局
dst="/data33/aijs/center/data/format/output/wj/voice"
get_path $proc_fr

echo ================================================
# 起止时间一致，只回退一天话单，完全根据filelist取话单
# 否则两步：
# 1.只根据filelist按文件名中日期取$from 和 $to+1两天的话单,
# 2.其余直接从文件系统中按文件名取$from+1 到 $to各天的话单

# 根据dps_redo_files表，按回退任务开始时间取回退文件列表
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

# 文件计数
count=0
# 根据文件列表取文件到处理目录
for file in $(awk -F " " ' /N_GSM/ { print $1 }' $filelist)
do
	get_file "${file}.gz"
done

	
# 从文件系统中按文件名取$from+1 到 $to各天的话单
# 注意月份切换
# 关口局话单文件名示例：N_GSM_WZ_HWGW4_20060101.00967384.gz
if [ $from != $to ]; then
	if [ $(($to - $frnext)) -le 30 ]; then 	# 无月份切换
		begin=$frnext
		while [ ${begin} -le ${to} ]; do
			fetch_files $begin $area
			begin=$(($begin + 1))
		done
		
	else # 日期中有月份切换
		list=""
		get_day_list $frnext $to
		
		day_list=$list 		# 函数调用得到
		for day in $day_list
		do
			fetch_files $day $area
		done
	fi
fi	

echo TOTAL_FILE_COUNT: $count
echo "A-OK!"

exit 0
