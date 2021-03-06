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
		echo "backpath...existed."
	else
		echo "create backpath: $backpath"
		mkdir -p $1		# force to create the directory hierarchy
	fi
	
	backpath=$1
	echo "<==return $backpath"
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
	cd $1
	min_month=`ls -1 $2|cut -d _ -f $3|cut -c 1-6|sort|uniq|head -1`
	if [ -z "$min_month" ]; then
		echo "error occured, ret_code of last command: $?"
		exit -1
	fi
	
	# max_month=`ls -1 $2|cut -d _ -f $3|cut -c 1-6|sort|uniq|tail -1`
	echo "<==return min_month: $min_month"
}
get_dr_min_day()
{
	echo "==>get_dr_min_day $*"
	local seq=$date_in_filename
	if [ -z "$seq" ]; then
		seq=5
	fi
	
	cd $1
	min_day=`ls -1 $2|cut -d _ -f $3|cut -c 1-8|sort|uniq|head -1`
	if [ -z "$min_day" ]; then
		echo "error occured, ret_code of last command: $?"
		min_day=`ls -1|cut -d _ -f $3|cut -c 1-8|sort|uniq|head -1`
	fi
	
	# max_day=`ls -1 $2|cut -d _ -f $3|cut -c 1-6|sort|uniq|tail -1`
	
	# reset date_in_filename to blank
	date_in_filename=""
	
	echo "<==return min_day: $min_day"
}
#--------------------------------------------------------------------#
# 分析指定路径下话单文件,返回空格分隔的月份/日期字串:month_range/day_range
# 1 - 话单文件路径
# 2 - file pattern 
# 3 - 日期在话单文件名中按下划线分隔的字段位置
#--------------------------------------------------------------------#
get_dr_month_range()
{
	echo "==>get_dr_month_range $*"
	cd $1
	month_range=`ls -1 $2|cut -d _ -f $3|cut -c 1-6|sort|uniq`
	echo "<==return month_range: $month_range"
}
get_dr_day_range()
{
	echo "==>get_dr_day_range $*"
	echo "...waiting..."
	cd $1
	day_range=`ls -1 $2|cut -d _ -f $3|cut -c 1-8|sort|uniq`
	echo "<==return day_range: $day_range"
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
# 2 - N
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
######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
cur_day=`echo $now|cut -c -8`
cur_month=`echo $now|cut -c -6`

get_last_month $cur_month
last_1_month=$last_month

get_last_month $last_1_month
last_2_month=$last_month

get_last_month $last_2_month
last_3_month=$last_month

get_now_time
logfile="/data1/home/jsusr1/center/log/backup_gsmc_$now.log"
backroot=/data4/backup/wjsms

echo "$now sms backup begin..." > $logfile

#--------------------------------------------------------------------#
# 网间短信
# 错单: 量少, 备份一月以前的文件, 每月dup/err文件各备份成一个tar文件,不压缩
#--------------------------------------------------------------------#
# log_append "backup sms err/dup sheets"
# 
# srcpath=/data2/wj/center/error/format/wj/sms
# filepattern="N_CUSMS_HZ_GSMC*"	# _err
# # filepattern="N_CUSMS_HZ_GSMC*_dup"
# 
# get_dr_min_month $srcpath "$filepattern" 5
# 
# set_backpath $backroot/err
# 
# if [ $min_month -le $last_1_month ]; then
# 	loop_month=$last_1_month
# 	while [ $loop_month -ge $min_month ]; do
# 		backup_dr_to_path gsmc_err_$loop_month "$srcpath/$filepattern$loop_month*" $backpath
# 		
# 		# 取上一月
# 		get_last_month $loop_month
# 		loop_month=$last_month
# 	done
# fi

#--------------------------------------------------------------------#
# 按天备份话单,无参数,皆通过全局变量传递
# 根据need_compress参数, tar前可先compress压缩
BACKUP_SHEETS()
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
				compress $srcpath/$filepattern$loop_day*
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*.Z" $backpath
			fi
			
			# 取前一天
			get_last_N_day $loop_day 1
			loop_day=$last_N_day
		done
	fi
}

#--------------------------------------------------------------------#
# 分析备份的预处理话单
# 备份策略: 备份10天前话单,先compress再tar,每天GSMC1/GSMC2各一个文件
#--------------------------------------------------------------------#
log_append "backup sms prep sheets"
srcpath=/data2/wj/center/back/settle/wj/sms
set_backpath $backroot/prep
backup_days_before=10

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_prep_gsmc2"
BACKUP_SHEETS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_prep_gsmc1"
BACKUP_SHEETS

#--------------------------------------------------------------------#
# 汇总备份的分析话单,直接作为清单加载源路径
# 备份策略: 不必备份,自已会清的
#--------------------------------------------------------------------#
# log_append "backup sms settled sheets"
# srcpath=/data2/wj/center/back/stat/output/wj/sms

#--------------------------------------------------------------------#
# 日汇总备份的汇总话单,文件小(每个200k左右,tar前不必压缩: need_compress="N")
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件,也可直接删除
#--------------------------------------------------------------------#
log_append "backup sms stat sheets"
srcpath=/data2/wj/center/data/back/daystat/output/wj/sms
set_backpath $backroot/stat
backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_stat_gsmc2"
BACKUP_SHEETS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_stat_gsmc1"
BACKUP_SHEETS

need_compress="Y"

#--------------------------------------------------------------------#
# 批价程序备份的日汇总stat话单,用于批价的,必须备份,以备重批价用
# 备份策略: 备份10天前处理的话单,每天一个文件
# 注意文件中日期是处理日期,而非话单日期!!!
#--------------------------------------------------------------------#
log_append "backup sms daystat sheets"
# 路径配置: select dup_file_path from acc_settle_task_def where acc_task_id=2
srcpath=/data2/wj/center/data/back/daystatloader/wj/sms/4
set_backpath $backroot/daystat
backup_days_before=10

filepattern="*"		# 4_yyyymmdd_seq_n.stat
tarfile_prefix="gsmc_daystat"
date_in_filename=2	# 日期中文件名的字段系数
BACKUP_SHEETS

#--------------------------------------------------------------------#
# 清单加载备份的话单,理论上和分析输出一致
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup sms settled sheets"
srcpath=/data2/wj/center/back/dataloader/cdr/wj/sms
set_backpath $backroot/settle
backup_days_before=10

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_settle_gsmc2"
BACKUP_SHEETS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_settle_gsmc1"
BACKUP_SHEETS

#--------------------------------------------------------------------#
# 清单加载输出话单,是分表结果,文件名后加上了表名,可能已作gz压缩(300k),不再压缩
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup sms daystat sheets"
srcpath=/data2/wj/center/data/dataloader/output/wj/sms
set_backpath $backroot/drload_out
backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_drload_out_gsmc2"
BACKUP_SHEETS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_drload_out_gsmc1"
BACKUP_SHEETS

#--------------------------------------------------------------------#
# 清单加载的sqlldr日志,文件名为:话单名_表名.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup dr load log"
srcpath=/data2/wj/center/log/dataloader/wj/sms
set_backpath $backroot/drload_log
backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC*"
tarfile_prefix="gsmc_drload_log"
BACKUP_SHEETS

need_compress="Y"

#--------------------------------------------------------------------#
# 帐单加载的输出stat文件
# 备份策略: 备份10天前话单为tar, 注意文件名中日期是处理日期
#--------------------------------------------------------------------#
log_append "backup acc load file"
srcpath=/data2/wj/center/data/daydataloader/output/wj/sms
set_backpath $backroot/accload_out
backup_days_before=10

filepattern="*"
date_in_filename=2
tarfile_prefix="gsmc_accload_out"
BACKUP_SHEETS

#--------------------------------------------------------------------#
# 帐单加载的sqlldr日志,文件名为stat.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup acc load log"
srcpath=/data2/wj/center/log/daydataloader/wj/sms
set_backpath $backroot/accload_log
backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC*"
tarfile_prefix="gsmc_accload_log"
BACKUP_SHEETS

need_compress="Y"


log_append "backup end!"
echo "logfile is: $logfile"

exit 0
