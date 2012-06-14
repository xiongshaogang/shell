#!/bin/sh
set -x	# for dubug
clear

get_last_month()
{
	echo get_last_month $1
	year=`echo $1|cut -c -4`
	mon=`echo $1|cut -c 5-6`
	
	if [ "$mon" = "12" ]; then 	# 12月的上月为上一年1月
		local last_year=$(($year-1))
		last_month=`printf "%d%02d" ${last_year} 1`
	else
		local last_mon=$(($mon-1))
		last_month=`printf "%d%02d" ${year} ${last_mon}`
	fi
	
	echo return $last_month
}
set 20060509 1	
#--------------------------------------------------------------------#
# 取指定日期的前N天,返回到last_N_day
# get_last_N_day 20040305 5 返回20040229
# 参数: 
# 1 - 日期,格式YYYYMMDD
# 2 - N
#--------------------------------------------------------------------#
#get_last_N_day()
#{
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
#}
set_backpath()
{
	echo "==>set_back_path $*"
	if [ -d $1 ]; then
		echo "backpath...existed."
	else
		echo "backpath not existed, create it."
		mkdir -p $1		# force to create the directory hierarchy
	fi
	
	backpath=$1
	
	echo "<==return $backpath"
}
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
#################################
get_now_time()
{
	now=`date +%Y%m%d%H%M%S`
}
#################################
# 记录日志到$logfile
# 参数:日志内容
log_append()
{
	get_now_time
	echo "${now} \c" >> $logfile
	echo "$1" >> $logfile
}
#################################
#       SCRIPT BEGIN            #
#################################
# get_now_time
# logfile="/data1/home/jsusr1/center/log/backup_$now.log"
# echo "$now test begin..." > $logfile
# log_append "hello, world"
# log_append "hello mm"
# log_append "test end"

# set "/data2/wj/center/error/format/wj/sms" "*dup" 5
#get_last_month 200505
# get_last_N_day 20060509 1

#srcpath=/data2/wj/center/back/settle/wj/sms
#filepattern="N_CUSMS_HZ_GSMC1*"
#set_backpath $backroot/sms/prep
#
#get_dr_day_range $srcpath $filepattern 5
##get_dr_month_range $srcpath $filepattern 5
#
#cd $backpath
#for loop_day in "$day_range"; do
#	echo "======= $loop_day ======="
#done
exit 0	