#!/bin/bash

#!/bin/sh
# set -x	# for dubug

#--------------------------------------------------------------------#
# 网间短信话单备份脚本
# Author: fanghm
# 设计目标: 
#	可重复执行,如果存在备份的目标tar文件,追加;否则创建新的tar文件备份
#--------------------------------------------------------------------#
backup_days_before=5	# 备份当前日期起前N天的文件
#==============================重要设置==============================#

# clear

# calucate dates for later use
now=`date +%Y%m%d%H%M%S` # now="20060710112233" # get_now_time

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
# 设置备份路径backpath, 并确保路径存在
#--------------------------------------------------------------------#
set_backpath()
{
	echo "==>set_back_path $*"
	
	if [ ! -d $1 ]; then
		echo "--create backpath: $1"
		mkdir -p $1		# force to create the directory hierarchy
	fi
	
	backpath=$1
	
	# echo "<==return $backpath\n"
}

#--------------------------------------------------------------------#
# 存在匹配的文件时返回文件名对应的日期列表,以空格分隔
# 1 - 话单文件路径
# 2 - file pattern 
# eg: ls -1|cut -d _ -f 5|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'
# 不存在匹配的文件时返回空串,因此在对返回字串进行操作时,
# 要先进行-z/-n判断后才能使用
#--------------------------------------------------------------------#
get_dr_day_list()
{
	echo "==>get_dr_day_list $*"
	
	seq=5	# default date field pos in filename is 5, except defined in $date_in_filename
	if [ -n "$date_in_filename" ]; then
		seq=$date_in_filename
	fi
	
	#local from_path=$PWD
	cd $1
	day_list=`ls -1 $2|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	
	if [ -z "$day_list" ]; then
		# 可能是ls参数匹配文件过多，不带参数再执行;也可能是不存在匹配的文件
		echo "--error cought when ls, try another way" 
		day_list=`ls -1|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	fi
	
	# cd $from_path
	
	echo "<==return day_list: $day_list"
}
#--------------------------------------------------------------------#
# 在源文件所在路径下，按文件名匹配进行tar备份(不带文件路径)
# usage: 
# 	backup_dr_to_path <tarfile_prefix> <src_file_pattern> <dest_path>
#
# 参数: 
# 1 - tar file prefix
# 2 - file pattern without path
# 3 - backup dest path
#--------------------------------------------------------------------#
backup_dr_to_path()
{
	echo "==>backup_dr_to_path: $2"
	
	local tarfile="$1.tar"
	# if dest backed file existed, use -u option to update it! 
	if [ -e $tarfile ]; then	
		echo "--update existed $tarfile ..."
		tar -uf $3/$tarfile $2	# The u function key can be slow.
	else
		tar -cf $3/$tarfile $2
	fi
	
	# rm backuped files
	rm -f $2
	
	echo "<==backup_dr_to_path"
}

#--------------------------------------------------------------------#
# 取指定月份的上一月,返回到last_month
# 参数: 月份,格式YYYYMM
#--------------------------------------------------------------------#
get_last_month()
{
	echo "==>get_last_month $*"
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
	else
		# 跨月, 取上月
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
		echo "--days of $last_month is: $last_day"
		
		if [ $last_day -le $(($2-$day)) ]; then
			local last_month_1=`printf "%d%02d" $last_month 1`
			get_last_N_day $last_month_1 $(($2-$day-$last_day+1))	# 跨多月, 递归计算
		else
			last_N_day=`printf "%d%02d" $last_month $(($last_day-$2+$day))`
		fi
	fi
	
	echo "<==return $last_N_day"
}

#--------------------------------------------------------------------#
# 网间短信话单备份
# 按天备份话单,无参数,皆通过全局变量传递
# 根据need_compress参数, tar前可先compress压缩
#--------------------------------------------------------------------#
BACKUP_WJ_SMS()
{
	echo "==>BACKUP_WJ_SMS"
	
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
	
	get_dr_day_list $srcpath "$filepattern"		# cd $srcpath here!
	
	if [ -n "$day_list" ]; then
		# 按天备份
		for loop_day in $day_list; do
			local month=`echo $loop_day|cut -c -6`
			set_backpath $backroot/$month/$filetype
			
			# $loop_day 中时间是从小到大排列，故到达$backup_day 说明备份完成
			if [ $loop_day -gt $backup_day ]; then
				echo "--backup end."
				break;
			else
				echo "=== backup $loop_day ==="
			fi
			
			if [ "$need_compress" = "N" ]; then	# 不压缩备份
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$filepattern$loop_day*" $backpath
			else	# 压缩备份
				echo "--compress..."
				compress -f $filepattern${loop_day}*	# [0-9]
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$filepattern$loop_day*.Z" $backpath
			fi
		done
	fi
	
	# reset date_in_filename to blank
	unset date_in_filename
	
	echo "<==BACKUP_WJ_SMS"
}

######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
cur_day=`echo $now|cut -c -8`
cur_month=`echo $now|cut -c -6`

get_now_time
logfile="/data1/home/jsusr1/center/log/backup/backup_gsmc_$now.log"
backroot=/data4/backup/wjsms

echo "$now sms backup begin..." > $logfile

#--------------------------------------------------------------------#
# 分析备份的预处理话单
# 备份策略: 备份10天前话单,先compress再tar,每天GSMC1/GSMC2各一个文件
#--------------------------------------------------------------------#
log_append "backup sms prep sheets"
srcpath=/data2/wj/center/back/settle/wj/sms
filetype="prep"

filepattern="N_CUSMS_HZ_GSMC3*"
tarfile_prefix="gsmc_prep_gsmc3"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_prep_gsmc2"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_prep_gsmc1"
BACKUP_WJ_SMS

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
filetype="stat"
# backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC3*"
tarfile_prefix="gsmc_stat_gsmc3"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_stat_gsmc2"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_stat_gsmc1"
BACKUP_WJ_SMS

need_compress="Y"

#--------------------------------------------------------------------#
# 批价程序备份的日汇总stat话单,用于批价的,必须备份,以备重批价用
# 备份策略: 备份10天前处理的话单,每天一个文件
# 注意文件中日期是处理日期,而非话单日期!!!
#--------------------------------------------------------------------#
log_append "backup sms daystat sheets"
# 路径配置: select dup_file_path from acc_settle_task_def where acc_task_id=2
srcpath=/data2/wj/center/data/back/daystatloader/wj/sms/4
filetype="daystat"
# backup_days_before=10

filepattern="*"		# 4_yyyymmdd_seq_n.stat
tarfile_prefix="gsmc_daystat"
date_in_filename=2	# 日期中文件名的字段系数
BACKUP_WJ_SMS

#--------------------------------------------------------------------#
# 清单加载备份的话单,理论上和分析输出一致
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup sms settled sheets"
srcpath=/data2/wj/center/back/dataloader/cdr/wj/sms
filetype="settle"
# backup_days_before=10

filepattern="N_CUSMS_HZ_GSMC3*"
tarfile_prefix="gsmc_settle_gsmc3"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_settle_gsmc2"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_settle_gsmc1"
BACKUP_WJ_SMS

#--------------------------------------------------------------------#
# 清单加载输出话单,是分表结果,文件名后加上了表名,可能已作gz压缩(300k),不再压缩
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2各一个文件
# !!!或者10天前话单直接删除
#--------------------------------------------------------------------#
log_append "backup sms daystat sheets"
srcpath=/data2/wj/center/data/dataloader/output/wj/sms
filetype="drload_out"
# backup_days_before=10
need_compress="Y"

filepattern="N_CUSMS_HZ_GSMC3*"
tarfile_prefix="gsmc_drload_out_gsmc3"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC2*"
tarfile_prefix="gsmc_drload_out_gsmc2"
BACKUP_WJ_SMS

filepattern="N_CUSMS_HZ_GSMC1*"
tarfile_prefix="gsmc_drload_out_gsmc1"
BACKUP_WJ_SMS

#--------------------------------------------------------------------#
# 清单加载的sqlldr日志,文件名为:话单名_表名.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup dr load log"
srcpath=/data2/wj/center/log/dataloader/wj/sms
filetype="drload_log"
# backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC*"
tarfile_prefix="gsmc_drload_log"
BACKUP_WJ_SMS

need_compress="Y"

#--------------------------------------------------------------------#
# 帐单加载的输出stat文件
# 备份策略: 备份10天前话单为tar, 注意文件名中日期是处理日期
#--------------------------------------------------------------------#
log_append "backup acc load file"
srcpath=/data2/wj/center/data/daydataloader/output/wj/sms
filetype="accload_out"
# backup_days_before=10

filepattern="*"
date_in_filename=2
tarfile_prefix="gsmc_accload_out"
BACKUP_WJ_SMS

#--------------------------------------------------------------------#
# 帐单加载的sqlldr日志,文件名为stat.log,文件小(每个5k)
# 备份策略: 备份10天前话单为tar,每天GSMC1/GSMC2共一个文件,且不必压缩
#--------------------------------------------------------------------#
log_append "backup acc load log"
srcpath=/data2/wj/center/log/daydataloader/wj/sms
filetype="accload_log"
# backup_days_before=10
need_compress="N"

filepattern="N_CUSMS_HZ_GSMC*"
tarfile_prefix="gsmc_accload_log"
BACKUP_WJ_SMS


#--------------------------------------------------------------------#
log_append "backup end!"
echo "logfile is: $logfile"

exit 0
