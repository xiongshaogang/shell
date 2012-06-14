#!/bin/sh
# set -x	# for dubug

#--------------------------------------------------------------------#
# �����������ݽű�
# Author: fanghm
# ���Ŀ��: 
#	���ظ�ִ��,������ڱ��ݵ�Ŀ��tar�ļ�,׷��;���򴴽��µ�tar�ļ�����
#--------------------------------------------------------------------#
backup_days_before=2	# ���ݵ�ǰ������ǰN����ļ�
#==============================��Ҫ����==============================#

# calucate dates for later use
now=`date +%Y%m%d%H%M%S` # now="20060710112233" 


# NOTICE:
# tar����·��
# ls may cause error: "Arguments too long."
# compress/mv may prompt to override existed compressed file if not use -f option


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
	echo "$*" >> $logfile
}

#--------------------------------------------------------------------#
# ���ñ���·��backpath, ��ȷ��·������
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
# ����ƥ����ļ�ʱ�����ļ�����Ӧ�������б�,�Կո�ָ�
# 1 - �����ļ�·��
# 2 - file pattern 
# eg: ls -1|cut -d _ -f 5|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'
# ������ƥ����ļ�ʱ���ؿմ�,����ڶԷ����ִ����в���ʱ,
# Ҫ�Ƚ���-z/-n�жϺ����ʹ��
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
		# ������ls����ƥ���ļ����࣬����������ִ��;Ҳ�����ǲ�����ƥ����ļ�
		echo "--error cought when ls, try another way" 
		day_list=`ls -1|cut -d _ -f $seq|cut -c 1-8|sort|uniq| awk -v ORS="" '{ print $1,$2 }'`
	fi
	
	# cd $from_path
	
	echo "<==return day_list: $day_list"
}

#--------------------------------------------------------------------#
# ��Դ�ļ�����·���£����ļ���ƥ�����tar����(�����ļ�·��)
# usage: 
# 	backup_dr_to_path <filetype> <src_file_pattern> <dest_path>
#
# ����: 
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
# ȡָ���·ݵ���һ��,���ص�last_month
# ����: �·�,��ʽYYYYMM
#--------------------------------------------------------------------#
get_last_month()
{
	echo "==>get_last_month $*"
	local year=`echo $1|cut -c -4`
	
	local mon
	if [ $(echo $1|cut -c 5) -eq 0 ]; then
		mon=$(echo $1|cut -c 6)
	else
		mon=$(echo $1|cut -c 5-6)
	fi
	
	if [ $mon -eq 1 ]; then 	# 1�µ�����Ϊ��һ��12��
		local last_year=$(($year-1))
		last_month=`printf "%d%02d" ${last_year} 12`
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
	else
		# ����, ȡ����
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
		echo "--days of $last_month is: $last_day"
		
		if [ $last_day -le $(($2-$day)) ]; then
			local last_month_1=`printf "%d%02d" $last_month 1`
			get_last_N_day $last_month_1 $(($2-$day-$last_day+1))	# �����, �ݹ����
		else
			last_N_day=`printf "%d%02d" $last_month $(($last_day-$2+$day))`
		fi
	fi
	
	echo "<==return $last_N_day"
}

#--------------------------------------------------------------------#
# ���������������ݣ���alcatel huawei nokia����
# �޲���,��ͨ��ȫ�ֱ�������
# ����need_compress����, tarǰ����compressѹ��
#--------------------------------------------------------------------#
BACKUP_WJ_VOICE()
{
	echo "==>BACKUP_WJ_VOICE"
	
	get_last_N_day $cur_day $backup_days_before
	backup_day=$last_N_day
		
	for gw in alcatel huawei nokia; do		# enum gateway types
		echo "=========${gw}========="
		
		
		# �е��ļ�����·���ڹؿھ�����(huawei/nokia/alcatel)�»���1,2,3��temp��������Ŀ¼��������src_sub_path��
		local source_path=$srcpath/$gw
		if [ -n "$src_sub_path" ]; then
			source_path=$source_path/$src_sub_path
		fi
		
		# ȡ�ļ�ʱ�䷶Χ 
		get_dr_day_list $source_path "$filepattern"		# cd $source_path here!
		
		if [ -n "$day_list" ]; then
			# ���챸��
			for loop_day in $day_list; do
				local month=`echo $loop_day|cut -c -6`
				set_backpath $backroot/$month/$filetype
				
				# $loop_day ��ʱ���Ǵ�С�������У��ʵ���$backup_day ˵���������
				if [ $loop_day -gt $backup_day ]; then
					echo "--backup end."
					break;
				fi
				
				# cd $source_path
				# ��ѹ������, ��ϸ�ֹؿھ�,ÿ��ÿ�໰��ȫ��tar��һ���ļ�
				if [ "$need_compress" = "N" ]; then	
					backup_dr_to_path "${filetype}.${gw}.$loop_day" "$filepattern$loop_day*" $backpath
				
				# ѹ�����ݣ����ȼ��㵱ǰĿ¼��ȫ���ؿھ֣�ÿ��ÿ���ؿھֻ���ȫ��tar��һ���ļ�
				# �˴����������������������Ż�������
				else	
					echo "--compress ${gw}.${loop_day} ..."
					compress -f ${filepattern}${loop_day}*[0-9]
					
					local gateways=`ls -1 | cut -d _ -f 1-4 | sort | uniq | awk -v ORS="" '{ print $1,$2 }' `
					echo "--gateways: $gateways"
					for gateway in $gateways
					do
						echo "--backup ${gateway}.$loop_day ..."
						backup_dr_to_path "${filetype}.${gateway}.$loop_day" "${gateway}_${loop_day}*.Z" $backpath
					done
				fi
			done
		fi
		
	done
		
	# reset src_sub_path to blank
	unset src_sub_path
		
	# reset date_in_filename to blank
	unset date_in_filename
	
	echo "<==BACKUP_WJ_VOICE"
}
######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
echo "###############################################################"
cur_day=`echo $now|cut -c -8`
cur_month=`echo $now|cut -c -6`

get_now_time
logfile="/data1/home/jsusr1/center/log/backup/backup_voice_$now.log"
backroot=/data4/backup/wjvoice

echo "$now voice backup begin..." > $logfile

#--------------------------------------------------------------------#
# �������ݵ�Ԥ������
# ���ݲ���: ����N��ǰ����,��compress��tar,ÿ��GW��һ���ļ�
#--------------------------------------------------------------------#
log_append "backup voice prep sheets"
srcpath=/data2/wj/center/back/settle/wj/voice
# backup_days_before=2

filepattern="N_GSM*"
filetype="prep"
BACKUP_WJ_VOICE

#--------------------------------------------------------------------#
# �ջ��ܱ��ݵĻ��ܻ���,�ļ�С(ÿ��3-15k����,tarǰ����ѹ��: need_compress="N")
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GW��һ���ļ�,Ҳ��ֱ��ɾ��
#--------------------------------------------------------------------#
log_append "backup voice stat sheets"
srcpath=/data2/wj/center/data/back/daystat/output/wj/voice
# backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
filetype="stat"
BACKUP_WJ_VOICE

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

# backup_days_before=10
need_compress="N"
date_in_filename=2
filepattern="*"		# 2_yyyymmdd_seq_n.stat

filetype="daystat"
BACKUP_WJ_VOICE
need_compress="Y"

#--------------------------------------------------------------------#
# �嵥���ر��ݵĻ���,�����Ϻͷ������һ��
# ���ݲ���: ����10��ǰ����Ϊtar
# ��Ҫ������3��1�£�
#--------------------------------------------------------------------#
log_append "backup voice settled sheets"
srcpath=/data2/wj/center/back/dataloader/cdr/wj/voice
# backup_days_before=10

filepattern="N_GSM*"
filetype="settle"
BACKUP_WJ_VOICE

#--------------------------------------------------------------------#
# �嵥�����������,�Ƿֱ���,�ļ���������˱���,��������gzѹ��(300k),����ѹ��
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GW��һ���ļ�
# !!!����û�ã���ֱ��ɾ��
#--------------------------------------------------------------------#
log_append "backup voice daystat sheets"
srcpath=/data2/wj/center/data/dataloader/output/wj/voice
# backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
filetype="drload_out"
#���ڸ��ļ�ռ�ÿռ�ϴ����ޱ��ݵı�Ҫ��ֱ��ɾ�� by guyb 20070925
#BACKUP_WJ_VOICE
cd /data2/wj/center/data/dataloader/output/wj/voice/alcatel
rm *
cd /data2/wj/center/data/dataloader/output/wj/voice/huawei
rm *
cd /data2/wj/center/data/dataloader/output/wj/voice/nokia
rm *
need_compress="Y"

#--------------------------------------------------------------------#
# �嵥���ص�sqlldr��־,�ļ���Ϊ:������_����.log,�ļ�С(ÿ��5k)
# Ŀ¼�»�����������־��log.ldr_${gw_type}.yyyymmdd*,ÿ��һ��
# ���ݲ���: ����N��ǰ����Ϊtar,ÿ��ÿ��GWһ���ļ�,�Ҳ���ѹ��
# ����3��1����
#--------------------------------------------------------------------#
log_append "backup dr load log"
srcpath=/data2/wj/center/log/dataloader/wj/voice
# backup_days_before=10
need_compress="N"

filepattern="N_GSM*"
filetype="drload_log"
BACKUP_WJ_VOICE


#--------------------------------------------------------------------#
# �ʵ����ص����stat�ļ�
# ���ݲ���: ����10��ǰ����Ϊtar, ע���ļ����������Ǵ�������
# ��Ҫ������3��1�£�
#--------------------------------------------------------------------#
log_append "backup acc load file"
srcpath=/data2/wj/center/data/daydataloader/output/wj/voice
# backup_days_before=10

# filename like : 2_20060612_10004192_0.stat
date_in_filename=2
filepattern="*"

filetype="accload_out"
BACKUP_WJ_VOICE

#--------------------------------------------------------------------#
# �ʵ����ص�sqlldr��־,�ļ���Ϊstat.log,�ļ�С(ÿ��5k)
# Ŀ¼�»�����������־��log.ldr_stat_${gw_type}.yyyymmdd*,ÿ��һ��
# ���ݲ���: ����10��ǰ����Ϊtar,ÿ��GW��һ���ļ�,�Ҳ���ѹ��
# ����3��1����
#--------------------------------------------------------------------#
log_append "backup acc load log"
srcpath=/data2/wj/center/log/daydataloader/wj/voice
# backup_days_before=10
need_compress="N"

date_in_filename=2
filepattern="2_*"
filetype="accload_log"
BACKUP_WJ_VOICE
#--------------------------------------------------------------------#
#compress B wrong file
cd /data3/home/jsusr1/center/error/settle/roam
rm -r hwup;mkdir hwup
rm -r alcatelup;mkdir alcatelup
rm -r nokiaup;mkdir nokiaup
#--------------------------------------------------------------------#
log_append "backup end!"
echo "logfile is: $logfile"

exit 0
