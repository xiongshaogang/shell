#!/bin/sh
set -x	# for dubug
# 设计目标: 
#	可重复执行,如果存在备份的目标tar文件,追加;否则创建新的tar文件备份
#

# clear

# calucate dates for later use
now="20060710112233" # get_now_time

#--------------------------------------------------------------------#
get_now_time()
{
	now=`date +%Y%m%d%H%M%S`
}
#--------------------------------------------------------------------#
# 追加日志到$logfile
# 参数:日志内容
#--------------------------------------------------------------------#
log_append()
{
	get_now_time
	echo "${now} \c" >> $logfile
	echo "$1" >> $logfile
}
#--------------------------------------------------------------------#
# 设置备份路径backpath,并确保路径存在
#--------------------------------------------------------------------#
set_backpath()
{
	echo "==>set_back_path $*"
	if [ -d $1 ]; then
		echo
	else
		echo "create backpath: $1"
		mkdir -p $1		# force to create the directory hierarchy
	fi
	
	backpath=$1
	cd $backpath
	
	echo "<==return $backpath\n"
}

#--------------------------------------------------------------------#
# 分析指定路径下话单文件,返回最大/最小月份:min_month
# 参数: 
# 1 - 话单文件路径
# 2 - file pattern 
# 3 - 日期在话单文件名中按下划线分隔的字段位置
# 可能问题: 使用ls可能会有错误"Arguments too long."
#--------------------------------------------------------------------#
get_dr_min_month()
{
	echo "==>get_dr_min_month $*"
	
	local seq=$3
	if [ -z "$3" ]; then
		seq=5
	fi
	
	cd $1
	min_month=`ls -1 $2|cut -d _ -f $seq|cut -c 1-6|sort|uniq|head -1`
	if [ -z "$min_month" ]; then
		echo "error occured, ret_code of last command: $?"
		exit -1
	fi
	
	# max_month=`ls -1 $2|cut -d _ -f $seq|cut -c 1-6|sort|uniq|tail -1`
	echo "<==return min_month: $min_month"
}
get_dr_day_range()
{
	echo "==>get_dr_day_range $*"
	local seq=$3
	if [ -z "$3" ]; then
		seq=5
	fi
	
	cd $1
	min_day=`ls -1 $2|cut -d _ -f $seq|cut -c 1-8|sort|uniq|head -1`
	if [ -z "$min_day" ]; then
		echo "error occured, ret_code of last command: $?"
		min_day=`ls -1 |cut -d _ -f $seq|cut -c 1-8|sort|uniq|head -1`
	fi
	
	max_day=`ls -1 $2|cut -d _ -f $seq|cut -c 1-8|sort|uniq|tail -1`
	if [ -z "$max_day" ]; then
		echo "error occured, ret_code of last command: $?"
		max_day=`ls -1 |cut -d _ -f $seq|cut -c 1-8|sort|uniq|tail -1`
	fi
	
	printf "<==return: min_day=%s max_day=%s\n" $min_day $max_day
}
#--------------------------------------------------------------------#
# 分析指定路径下话单文件,返回空格分隔的月份/日期字串:month_list/day_list
# 1 - 话单文件路径
# 2 - file pattern 
# 日期在话单文件名中按下划线分隔的字段位置在全局参数中$date_in_filename,缺省为5
#--------------------------------------------------------------------#
get_dr_month_list()
{
	echo "==>get_dr_month_list $*"
	
	if [ -n "$date_in_filename" ]; then
		seq=$date_in_filename
	else
		seq=5
	fi
	
	cd $1
	# eg: ls -1|cut -d _ -f 5|cut -c 1-6|sort|uniq| awk -v ORS="" '{ print $1,$2 }'
	month_list=`ls -1 $2|cut -d _ -f $seq|cut -c 1-6|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	if [ -z "$month_list" ]; then
		echo "error ls: $?"
		month_list=`ls -1|cut -d _ -f $seq|cut -c 1-6|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	fi
	
	# reset date_in_filename to blank
	date_in_filename=""
	
	echo "<==return month_list: $month_list"
}
#--------------------------------------------------------------------#
# 存在匹配的文件时返回文件名的日期串,以空格分隔
# 不存在匹配的文件时返回空,因此在对返回字串进行操作时,
# 要先进行-z/-n判断后才能for day in $day_list循环
#--------------------------------------------------------------------#
get_dr_day_list()
{
	echo "==>get_dr_day_list $*"
	
	seq=5
	if [ -n "$date_in_filename" ]; then
		seq=$date_in_filename
	fi
	echo "seq: $seq"
	
	cd $1
	# eg: ls -1|cut -d _ -f 5|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'
	day_list=`ls -1 $2|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	if [ -z "$day_list" ]; then
		echo "error ls: $?" # 可能是ls参数匹配文件过多，不带参数再执行;也可能是不存在匹配的文件
		day_list=`ls -1|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	fi
	
	# reset date_in_filename to blank
	date_in_filename=""
	
	echo "<==return day_list: $day_list"
}
#--------------------------------------------------------------------#
# 按文件名匹配进行备份
# usage: 
# 	backup_dr_to_path <tarfile_prefix> <src_path_file_pattern> <dest_path>
#
# 参数: 
# 1 - tar file prefix
# 2 - file pattern with path
# 3 - backup dest path
#--------------------------------------------------------------------#
backup_dr_to_path()
{
	echo "==>BACKUP TASK BEGIN: $2"
	cd $3	# cd to dest backup path
	
	# judge whether there're matched files
	# local file_count=`ls $2|wc -w`	# may cause error: "Arguments too long."
	# if [ $file_count -gt 0 ]; then
		local tarfile="$1.tar"
	# 		echo "Backup $file_count matched file to $tarfile..."
		
		if [ -e $tarfile ]; then	# if dest backed file existed, append (or use -u option to update) to it!
			tar -rf $tarfile $2	
		else
			tar -cf $tarfile $2
		fi
		
		rm -f $2
	# else
	# 	echo "No matched files for $2"
	# fi
	
	echo "<==BACKUP TASK END"
}

#--------------------------------------------------------------------#
# 取指定月份的上一月,返回到last_month
# 参数: 月份,格式YYYYMM
#--------------------------------------------------------------------#
get_last_month()
{
	echo "==>get_last_month $1"
	local year=`echo $1|cut -c -4`
	local mon=`echo $1|cut -c 5-6`
	
	if [ "$mon" = "12" ]; then 	# 12月的上月为上一年1月
		local last_year=$(($year-1))
		last_month=`printf "%d%02d" ${last_year} 1`
	else
		local last_mon=$(($mon-1))
		last_month=`printf "%d%02d" ${year} ${last_mon}`
	fi
	
	echo "<==return $last_month"
}
#--------------------------------------------------------------------#
# 取指定日期的前N天,返回到last_N_day
# get_last_N_day 20040305 5 返回20040229
# 参数: 
# 1 - 日期,格式YYYYMMDD
# 2 - N, days_before_to_backup
#--------------------------------------------------------------------#
get_last_N_day()
{
	echo "==>get_last_N_day $*"
	
	local mon=`echo $1|cut -c -6`
	local day
	if [ $(echo $1|cut -c 7) -eq 0 ]; then
		day=$(echo $1|cut -c 8)
	else
		day=$(echo $1|cut -c 7-8)
	fi
	
	if [ $day -gt $2 ]; then 	# 当月
		last_N_day=`printf "%d%02d" $mon $(($day-$2))`
	else	# 跨月
		# 取上月
		get_last_month $mon
		
		local last_mon=`echo $last_month|cut -c 5-6`
		local last_mon_n=$(($last_mon)) 
		
		# 计算上月天数
		local last_day=31
		case $last_mon_n in
			4|6|9|11)	last_day=30;;
			2) last_day=28;;
		esac
		
		local last_year=`echo $last_month|cut -c -4`
		local nyear=$(($last_year))
		
		# 如果是2月还要考虑闰年2月只有29天
		# 闰年计算: 能被400整除，或者能被4整除而不能被100整除
		if [ $last_day -eq 28 ]; then 
			if [ $(($nyear%400)) -eq 0 -o  $(($nyear%4)) -eq 0 -a $(($nyear%100)) -ne 0  ]; then
				last_day=29;
			fi
		fi
		echo "Days of $last_month is: $last_day"
		
		if [ $last_day -le $(($2-$day)) ]; then	# 跨多月, 递归
			local last_month_1=`printf "%d%02d" $last_month 1`
			get_last_N_day $last_month_1 $(($2-$day-$last_day+1))
		else
			last_N_day=`printf "%d%02d" $last_month $(($last_day-$2+$day))`
		fi
	fi
	
	echo "<==return $last_N_day"
}

#--------------------------------------------------------------------#
# 按天备份话单,无参数,皆通过全局变量传递
# 根据need_compress参数, tar前可先compress压缩
#--------------------------------------------------------------------#
BACKUP_SHEETS_SMS()
{
	get_dr_min_day $srcpath "$filepattern" 5
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
	
	cd $backpath
	if [ $min_day -le $backup_day ]; then
		loop_day=$backup_day
		while [ $loop_day -ge $min_day ]; do
			local file_pattern
			if [ "$need_compress" = "N" ]; then	# 不压缩备份
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*" $backpath
			else	# 压缩备份
				echo "...compress..."
				compress -f $srcpath/$filepattern$loop_day*
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*.Z" $backpath
			fi
			
			# 取前一天
			get_last_N_day $loop_day 1
			loop_day=$last_N_day
		done
	fi
}

#--------------------------------------------------------------------#
# 按话单格式／按关口局／按天备份语音相关话单,无参数,皆通过全局变量传递
# 根据need_compress参数, tar前可先compress压缩
#--------------------------------------------------------------------#
BACKUP_SHEETS_VOICE()
{
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
		
	cd $srcpath
	for gw in alcatel huawei nokia; do		# enum gateways
		echo "=========${gw}========="
		# 取文件时间范围 
		get_dr_day_range $srcpath/$gw "$filepattern"
				
		set_backpath $backbase/$gw
		if [ $min_day -le $backup_day ]; then
			# 计算应备份话单范围
			if [ $max_day -ge $backup_day ]; then
				loop_day=$backup_day
			else
				loop_day=$max_day
			fi
			
			while [ $loop_day -ge $min_day ]; do
				local file_pattern
				if [ "$need_compress" = "N" ]; then	# 不压缩备份则不分关口局
					backup_dr_to_path "${tarfile_prefix}.${gw}.$loop_day" "$srcpath/$gw/$filepattern$loop_day*" $backpath
				else	# 压缩备份
					echo "...compress ${gw} ..."
					compress -f $srcpath/$filepattern$loop_day*
					
					# 分关口局备份,每关口局每天一个文件
					for gateway in $(ls -1 | cut -d _ -f 1-4 | sort | uniq | awk -v ORS="" '{ print $1,$2 }'); do
						echo "backup ${gateway} ..."
						backup_dr_to_path "{tarfile_prefix}.${gateway}.$loop_day" "$srcpath/$gw/${gateway}_${loop_day}*.Z" $backpath
					done
				fi
				
				# 取前一天
				get_last_N_day $loop_day 1
				loop_day=$last_N_day
			done
		fi
		
	done
}

BACKUP_SHEETS_VOICE2()
{
	echo "==>BACKUP_SHEETS_VOICE2"
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
		
	cd $srcpath
	for gw in alcatel huawei nokia; do		# enum gateways
		echo "=========${gw}========="
		
		# 有的文件所在路径在关口局类型(huawei/nokia/alcatel)下还有1,2,3或temp这样的子目录，定义在src_sub_path中
		local source_path=$srcpath/$gw
		if [ -n "$src_sub_path" ]; then
			source_path=$source_path/$src_sub_path
		fi
		
		# 取文件时间范围 
		get_dr_day_list $source_path "$filepattern"
				
		set_backpath $backbase/$gw
		if [ -n "$day_list" ]; then
			
			for loop_day in $day_list; do
				if [ $loop_day -gt $backup_day ]; then
					echo "backup ok."
					break;
				fi
				
				local file_pattern
				if [ "$need_compress" = "N" ]; then	# 不压缩备份则不分关口局
					backup_dr_to_path "${tarfile_prefix}.${gw}.$loop_day" "$source_path/$filepattern$loop_day*" $backpath
				else	# 压缩备份
					echo "compress ${gw}.${loop_day} ..."
					compress -f $source_path/${filepattern}${loop_day}*[0-9]
					
					# 分关口局备份,每关口局每天一个文件
					local gateways=`ls -1 | cut -d _ -f 1-4 | sort | uniq | awk -v ORS="" '{ print $1,$2 }' `
					echo "gateways: $gateways"
					for gateway in $gateways
					do
						echo "backup ${gateway} ..."
						backup_dr_to_path "{tarfile_prefix}.${gateway}.$loop_day" "$source_path/${gateway}_${loop_day}*.Z" $backpath
					done
				fi
			done
		fi
		
	done
		
	# reset src_sub_path to blank
	src_sub_path=""
	
	echo "<==BACKUP_SHEETS_VOICE2"
}

######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
echo #################################################################
cur_day=`echo $now|cut -c -8`
cur_month=`echo $now|cut -c -6`

# get_last_month $cur_month
# last_1_month=$last_month
# 
# get_last_month $last_1_month
# last_2_month=$last_month
# 
# get_last_month $last_2_month
# last_3_month=$last_month

get_now_time
logfile="/data1/home/jsusr1/center/log/backup_voice_$now.log"
backroot=/data4/backup/wj/voice

echo "$now voice backup begin..." > $logfile

#--------------------------------------------------------------------#
# 网间语音重单/错单
# 重单(*_dup,每个文件200bytes)
# 错单(*_err): 量少或没有
# 备份策略: 备份一月以前的文件, 每月dup/err文件各备份成一个tar文件,不压缩
#--------------------------------------------------------------------#
# log_append "backup voice err/dup sheets"
#         /data2/wj/center/error/format/wj/voice/huawei
# srcpath=/data2/wj/center/error/format/wj/voice
# filepattern="N_GSM*"
# 
# get_dr_min_month $srcpath "$filepattern" 5
# 
# set_backpath $backroot/err
# 
# if [ $min_month -le $last_1_month ]; then
# 	loop_month=$last_1_month
# 	while [ $loop_month -ge $min_month ]; do
# 		backup_dr_to_path voice_err_$loop_month "$srcpath/$filepattern$loop_month*" $backpath
# 		
# 		# 取上一月
# 		get_last_month $loop_month
# 		loop_month=$last_month
# 	done
# fi


#--------------------------------------------------------------------#
# 分析备份的预处理话单(暂无备份)
# 备份策略: 备份10天前话单,先compress再tar,每天GSMC1/GSMC2各一个文件
#--------------------------------------------------------------------#
log_append "backup voice prep sheets"
srcpath=/data2/wj/center/back/settle/wj/voice
backbase=$backroot/prep
backup_days_before=10

filepattern="N_GSM*"
tarfile_prefix="voice_prep"
BACKUP_SHEETS_VOICE2

#--------------------------------------------------------------------#
# 汇总备份的分析话单,直接作为清单加载源路径
# 备份策略: 不必备份,自已会清的
#--------------------------------------------------------------------#
# log_append "backup voice settled sheets"
#         /data2/wj/center/back/stat/output/wj/voice/huawei
# srcpath=/data2/wj/center/back/stat/output/wj/voice

#--------------------------------------------------------------------#
# 日汇总备份的汇总话单,文件小(每个3-15k左右,tar前不必压缩: need_compress="N")
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件,也可直接删除
#--------------------------------------------------------------------#
log_append "backup voice stat sheets"
srcpath=/data2/wj/center/data/back/daystat/output/wj/voice
backbase=$backroot/stat
backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
tarfile_prefix="voice_stat"
BACKUP_SHEETS_VOICE2

need_compress="Y"

#--------------------------------------------------------------------#
# 批价程序备份的日汇总stat文件,用于批价的,必须备份,以备重批价用
# 备份策略: 备份10天前处理的话单,每天生成一个备份文件
# 注意文件中日期是处理日期,而非话单日期,且date_in_filename=2!!!
#--------------------------------------------------------------------#
log_append "backup voice daystat sheets"
# 路径配置: select dup_file_path from acc_settle_task_def where acc_task_id=1
srcpath=/data2/wj/center/data/back/daystatloader/wj/voice		#/$gw/2	# /4
src_sub_path=2
backbase=$backroot/daystat
backup_days_before=10
need_compress="N"
date_in_filename=2

filepattern="*"		# 4_yyyymmdd_seq_n.stat
tarfile_prefix="voice_daystat"
BACKUP_SHEETS_VOICE2
need_compress="Y"

#--------------------------------------------------------------------#
# 清单加载备份的话单,理论上和分析输出一致
# 备份策略: 备份10天前话单为tar
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup voice settled sheets"
srcpath=/data2/wj/center/back/dataloader/cdr/wj/voice
backbase=$backroot/settle
backup_days_before=10

filepattern="N_GSM*"
tarfile_prefix="voice_settle"
BACKUP_SHEETS_VOICE2

#--------------------------------------------------------------------#
# 清单加载输出话单,是分表结果,文件名后加上了表名,可能已作gz压缩(300k),不再压缩
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup voice daystat sheets"
srcpath=/data2/wj/center/data/dataloader/output/wj/voice
backbase=$backroot/drload_out
backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
tarfile_prefix="voice_drload_out"
BACKUP_SHEETS_VOICE2
need_compress="Y"

#--------------------------------------------------------------------#
# 清单加载的sqlldr日志,文件名为:话单名_表名.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup dr load log"
srcpath=/data2/wj/center/log/dataloader/wj/voice
backbase=$backroot/drload_log
backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
tarfile_prefix="voice_drload_log"
BACKUP_SHEETS_VOICE2


#--------------------------------------------------------------------#
# 帐单加载的输出stat文件
# 备份策略: 备份10天前话单为tar, 注意文件名中日期是处理日期
#--------------------------------------------------------------------#
log_append "backup acc load file"
srcpath=/data2/wj/center/data/daydataloader/output/wj/voice
backbase=$backroot/accload_out
backup_days_before=10
date_in_filename=2

filepattern="*"
tarfile_prefix="gsmc_accload_out"
BACKUP_SHEETS_VOICE2

#--------------------------------------------------------------------#
# 帐单加载的sqlldr日志,文件名为stat.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup acc load log"
srcpath=/data2/wj/center/log/daydataloader/wj/voice
backbase=$backroot/accload_log
backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
tarfile_prefix="voice_accload_log"
BACKUP_SHEETS_VOICE2

# need_compress="Y"


log_append "backup end!"
echo "logfile is: $logfile"

exit 0
