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
# ����ָ��·���»����ļ�,���ؿո�ָ����·�/�����ִ�:month_list/day_list
# 1 - �����ļ�·��
# 2 - file pattern 
# �����ڻ����ļ����а��»��߷ָ����ֶ�λ����ȫ�ֲ�����$date_in_filename,ȱʡΪ5
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
# ����ƥ����ļ�ʱ�����ļ��������ڴ�,�Կո�ָ�
# ������ƥ����ļ�ʱ���ؿ�,����ڶԷ����ִ����в���ʱ,
# Ҫ�Ƚ���-z/-n�жϺ����for day in $day_listѭ��
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
		echo "error ls: $?" # ������ls����ƥ���ļ����࣬����������ִ��;Ҳ�����ǲ�����ƥ����ļ�
		day_list=`ls -1|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	fi
	
	# reset date_in_filename to blank
	date_in_filename=""
	
	echo "<==return day_list: $day_list"
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

#--------------------------------------------------------------------#
# ���챸�ݻ���,�޲���,��ͨ��ȫ�ֱ�������
# ����need_compress����, tarǰ����compressѹ��
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
			if [ "$need_compress" = "N" ]; then	# ��ѹ������
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*" $backpath
			else	# ѹ������
				echo "...compress..."
				compress -f $srcpath/$filepattern$loop_day*
				backup_dr_to_path "${tarfile_prefix}.$loop_day" "$srcpath/$filepattern$loop_day*.Z" $backpath
			fi
			
			# ȡǰһ��
			get_last_N_day $loop_day 1
			loop_day=$last_N_day
		done
	fi
}

#--------------------------------------------------------------------#
# ��������ʽ�����ؿھ֣����챸��������ػ���,�޲���,��ͨ��ȫ�ֱ�������
# ����need_compress����, tarǰ����compressѹ��
#--------------------------------------------------------------------#
BACKUP_SHEETS_VOICE()
{
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
		
	cd $srcpath
	for gw in alcatel huawei nokia; do		# enum gateways
		echo "=========${gw}========="
		# ȡ�ļ�ʱ�䷶Χ 
		get_dr_day_range $srcpath/$gw "$filepattern"
				
		set_backpath $backbase/$gw
		if [ $min_day -le $backup_day ]; then
			# ����Ӧ���ݻ�����Χ
			if [ $max_day -ge $backup_day ]; then
				loop_day=$backup_day
			else
				loop_day=$max_day
			fi
			
			while [ $loop_day -ge $min_day ]; do
				local file_pattern
				if [ "$need_compress" = "N" ]; then	# ��ѹ�������򲻷ֹؿھ�
					backup_dr_to_path "${tarfile_prefix}.${gw}.$loop_day" "$srcpath/$gw/$filepattern$loop_day*" $backpath
				else	# ѹ������
					echo "...compress ${gw} ..."
					compress -f $srcpath/$filepattern$loop_day*
					
					# �ֹؿھֱ���,ÿ�ؿھ�ÿ��һ���ļ�
					for gateway in $(ls -1 | cut -d _ -f 1-4 | sort | uniq | awk -v ORS="" '{ print $1,$2 }'); do
						echo "backup ${gateway} ..."
						backup_dr_to_path "{tarfile_prefix}.${gateway}.$loop_day" "$srcpath/$gw/${gateway}_${loop_day}*.Z" $backpath
					done
				fi
				
				# ȡǰһ��
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
		
		# �е��ļ�����·���ڹؿھ�����(huawei/nokia/alcatel)�»���1,2,3��temp��������Ŀ¼��������src_sub_path��
		local source_path=$srcpath/$gw
		if [ -n "$src_sub_path" ]; then
			source_path=$source_path/$src_sub_path
		fi
		
		# ȡ�ļ�ʱ�䷶Χ 
		get_dr_day_list $source_path "$filepattern"
				
		set_backpath $backbase/$gw
		if [ -n "$day_list" ]; then
			
			for loop_day in $day_list; do
				if [ $loop_day -gt $backup_day ]; then
					echo "backup ok."
					break;
				fi
				
				local file_pattern
				if [ "$need_compress" = "N" ]; then	# ��ѹ�������򲻷ֹؿھ�
					backup_dr_to_path "${tarfile_prefix}.${gw}.$loop_day" "$source_path/$filepattern$loop_day*" $backpath
				else	# ѹ������
					echo "compress ${gw}.${loop_day} ..."
					compress -f $source_path/${filepattern}${loop_day}*[0-9]
					
					# �ֹؿھֱ���,ÿ�ؿھ�ÿ��һ���ļ�
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
# ���������ص�/��
# �ص�(*_dup,ÿ���ļ�200bytes)
# ��(*_err): ���ٻ�û��
# ���ݲ���: ����һ����ǰ���ļ�, ÿ��dup/err�ļ������ݳ�һ��tar�ļ�,��ѹ��
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
# 		# ȡ��һ��
# 		get_last_month $loop_month
# 		loop_month=$last_month
# 	done
# fi


#--------------------------------------------------------------------#
# �������ݵ�Ԥ������(���ޱ���)
# ���ݲ���: ����10��ǰ����,��compress��tar,ÿ��GSMC1/GSMC2��һ���ļ�
#--------------------------------------------------------------------#
log_append "backup voice prep sheets"
srcpath=/data2/wj/center/back/settle/wj/voice
backbase=$backroot/prep
backup_days_before=10

filepattern="N_GSM*"
tarfile_prefix="voice_prep"
BACKUP_SHEETS_VOICE2

#--------------------------------------------------------------------#
# ���ܱ��ݵķ�������,ֱ����Ϊ�嵥����Դ·��
# ���ݲ���: ���ر���,���ѻ����
#--------------------------------------------------------------------#
# log_append "backup voice settled sheets"
#         /data2/wj/center/back/stat/output/wj/voice/huawei
# srcpath=/data2/wj/center/back/stat/output/wj/voice

#--------------------------------------------------------------------#
# �ջ��ܱ��ݵĻ��ܻ���,�ļ�С(ÿ��3-15k����,tarǰ����ѹ��: need_compress="N")
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,Ҳ��ֱ��ɾ��
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
# ���۳��򱸷ݵ��ջ���stat�ļ�,�������۵�,���뱸��,�Ա���������
# ���ݲ���: ����10��ǰ����Ļ���,ÿ������һ�������ļ�
# ע���ļ��������Ǵ�������,���ǻ�������,��date_in_filename=2!!!
#--------------------------------------------------------------------#
log_append "backup voice daystat sheets"
# ·������: select dup_file_path from acc_settle_task_def where acc_task_id=1
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
# �嵥���ر��ݵĻ���,�����Ϻͷ������һ��
# ���ݲ���: ����10��ǰ����Ϊtar
# !!!����10��ǰ����ֱ��ɾ��
#--------------------------------------------------------------------#
log_append "backup voice settled sheets"
srcpath=/data2/wj/center/back/dataloader/cdr/wj/voice
backbase=$backroot/settle
backup_days_before=10

filepattern="N_GSM*"
tarfile_prefix="voice_settle"
BACKUP_SHEETS_VOICE2

#--------------------------------------------------------------------#
# �嵥�����������,�Ƿֱ���,�ļ���������˱���,��������gzѹ��(300k),����ѹ��
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�
# !!!����10��ǰ����ֱ��ɾ��
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
# �嵥���ص�sqlldr��־,�ļ���Ϊ:������_����.log,�ļ�С(ÿ��5k)
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,�Ҳ���ѹ��
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
# �ʵ����ص����stat�ļ�
# ���ݲ���: ����10��ǰ����Ϊtar, ע���ļ����������Ǵ�������
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
# �ʵ����ص�sqlldr��־,�ļ���Ϊstat.log,�ļ�С(ÿ��5k)
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GSMC1/GSMC2��һ���ļ�,�Ҳ���ѹ��
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
