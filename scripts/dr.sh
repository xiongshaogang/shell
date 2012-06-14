#!/bin/sh
set -x	# for dubug
# ���Ŀ��: 
#	���ظ�ִ��,������ڱ��ݵ�Ŀ��tar�ļ�,׷��;���򴴽��µ�tar�ļ�����
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
# ׷����־��$logfile
# ����:��־����
#--------------------------------------------------------------------#
log_append()
{
	get_now_time
	echo "${now} \c" >> $logfile
	echo "$1" >> $logfile
}
#--------------------------------------------------------------------#
# ���ñ���·��backpath,��ȷ��·������
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
# ����ָ��·���»����ļ�,�������/��С�·�:min_month
# ����: 
# 1 - �����ļ�·��
# 2 - file pattern 
# 3 - �����ڻ����ļ����а��»��߷ָ����ֶ�λ��
# ��������: ʹ��ls���ܻ��д���"Arguments too long."
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
# ����ָ��·���»����ļ�,���ؿո�ָ����·�/�����ִ�:month_range/day_range
# 1 - �����ļ�·��
# 2 - file pattern 
# 3 - �����ڻ����ļ����а��»��߷ָ����ֶ�λ��
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
# ���ļ���ƥ����б���
# usage: 
# 	backup_dr_to_path <tarfile_prefix> <src_path_file_pattern> <dest_path>
#
# ����: 
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
# ȡָ���·ݵ���һ��,���ص�last_month
# ����: �·�,��ʽYYYYMM
#--------------------------------------------------------------------#
get_last_month()
{
	echo "==>get_last_month $1"
	local year=`echo $1|cut -c -4`
	local mon=`echo $1|cut -c 5-6`
	
	if [ "$mon" = "12" ]; then 	# 12�µ�����Ϊ��һ��1��
		local last_year=$(($year-1))
		last_month=`printf "%d%02d" ${last_year} 1`
	else
		local last_mon=$(($mon-1))
		last_month=`printf "%d%02d" ${year} ${last_mon}`
	fi
	
	echo "<==return $last_month"
}
#--------------------------------------------------------------------#
# ȡָ�����ڵ�ǰN��,���ص�last_N_day
# get_last_N_day 20040305 5 ����20040229
# ����: 
# 1 - ����,��ʽYYYYMMDD
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
	
	if [ $day -gt $2 ]; then 	# ����
		last_N_day=`printf "%d%02d" $mon $(($day-$2))`
	else	# ����
		# ȡ����
		get_last_month $mon
		
		local last_mon=`echo $last_month|cut -c 5-6`
		local last_mon_n=$(($last_mon)) 
		
		# ������������
		local last_day=31
		case $last_mon_n in
			4|6|9|11)	last_day=30;;
			2) last_day=28;;
		esac
		
		local last_year=`echo $last_month|cut -c -4`
		local nyear=$(($last_year))
		
		# �����2�»�Ҫ��������2��ֻ��29��
		# �������: �ܱ�400�����������ܱ�4���������ܱ�100����
		if [ $last_day -eq 28 ]; then 
			if [ $(($nyear%400)) -eq 0 -o  $(($nyear%4)) -eq 0 -a $(($nyear%100)) -ne 0  ]; then
				last_day=29;
			fi
		fi
		echo "Days of $last_month is: $last_day"
		
		if [ $last_day -le $(($2-$day)) ]; then	# �����, �ݹ�
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
# �������
# ��: ����, ����һ����ǰ���ļ�, ÿ��dup/err�ļ������ݳ�һ��tar�ļ�,��ѹ��
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
# 		# ȡ��һ��
# 		get_last_month $loop_month
# 		loop_month=$last_month
# 	done
# fi

#--------------------------------------------------------------------#
# ���챸�ݻ���,�޲���,��ͨ��ȫ�ֱ�������
# ����need_compress����, tarǰ����compressѹ��
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
			if [ "$need_compress" = "N" ]; then	# ��ѹ������
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*" $backpath
			else	# ѹ������
				echo "...compress..."
				compress $srcpath/$filepattern$loop_day*
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*.Z" $backpath
			fi
			
			# ȡǰһ��
			get_last_N_day $loop_day 1
			loop_day=$last_N_day
		done
	fi
}

#--------------------------------------------------------------------#
# �������ݵ�Ԥ������
# ���ݲ���: ����10��ǰ����,��compress��tar,ÿ��GSMC1/GSMC2��һ���ļ�
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
# ���ܱ��ݵķ�������,ֱ����Ϊ�嵥����Դ·��
# ���ݲ���: ���ر���,���ѻ����
#--------------------------------------------------------------------#
# log_append "backup sms settled sheets"
# srcpath=/data2/wj/center/back/stat/output/wj/sms

#--------------------------------------------------------------------#
# �ջ��ܱ��ݵĻ��ܻ���,�ļ�С(ÿ��200k����,tarǰ����ѹ��: need_compress="N")
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,Ҳ��ֱ��ɾ��
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
# ���۳��򱸷ݵ��ջ���stat����,�������۵�,���뱸��,�Ա���������
# ���ݲ���: ����10��ǰ����Ļ���,ÿ��һ���ļ�
# ע���ļ��������Ǵ�������,���ǻ�������!!!
#--------------------------------------------------------------------#
log_append "backup sms daystat sheets"
# ·������: select dup_file_path from acc_settle_task_def where acc_task_id=2
srcpath=/data2/wj/center/data/back/daystatloader/wj/sms/4
set_backpath $backroot/daystat
backup_days_before=10

filepattern="*"		# 4_yyyymmdd_seq_n.stat
tarfile_prefix="gsmc_daystat"
date_in_filename=2	# �������ļ������ֶ�ϵ��
BACKUP_SHEETS

#--------------------------------------------------------------------#
# �嵥���ر��ݵĻ���,�����Ϻͷ������һ��
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�
# !!!����10��ǰ����ֱ��ɾ��
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
# �嵥�����������,�Ƿֱ���,�ļ���������˱���,��������gzѹ��(300k),����ѹ��
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�
# !!!����10��ǰ����ֱ��ɾ��
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
# �嵥���ص�sqlldr��־,�ļ���Ϊ:������_����.log,�ļ�С(ÿ��5k)
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,�Ҳ���ѹ��
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
# �ʵ����ص����stat�ļ�
# ���ݲ���: ����10��ǰ����Ϊtar, ע���ļ����������Ǵ�������
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
# �ʵ����ص�sqlldr��־,�ļ���Ϊstat.log,�ļ�С(ÿ��5k)
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,�Ҳ���ѹ��
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
