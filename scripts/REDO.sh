#!/bin/sh
################################################################################
# Script to fetch src files for REDO
# Usage:
# 		REDO.sh <dr_src> <begin_time|format:'YYYYMMDDHH24MISS'>
# Say:	
#		REDO.sh huawei nokia alcatel		
# NOTE to set src/dst path and proper file filter
################################################################################
# ����dps_redo_log��ȡ��ǰ����������Ϣ
# ���ݻ�����ʼ���̣�ȡ��һ���̱���·���±��ݻ����ļ���Ϊ���λ�������
# ���ݻ�����Ŀʱ�䡢������ƥ���ļ�
# ��ʼʱ�䰴dps_redo_filesȡ����ֹʱ���һ�죬��dps_redo_filesȡ
# ����ʱ�䣱�죺��������ģ��м�İ�����ȫȡ����ͷ��dps_redo_files���ļ���ȡ
# ��Ϊ
# N_GSM_WZ_HWGW4_20060101.00967384.gz

#PROD_PA=/data32/home/aijs/center
#SYS_LOG_PATH=${PROD_PA}/log

path=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M$S`
log=$path/REDO_${now}.log
filelist=$path/REDO_${now}.filelist

echo $log

sqlplus aijs/aijs@testjs > /dev/null 2>&1 << SQLEOF
set serverout off;
set echo off;
set feedback off;
--set line 100;
col area for a10;

spool $log;

-- fetch last record for redo
select date_fr, date_to, area, status, to_char(begin_time, 'YYYYMMDDHH24MISS'), proc_fr from dps_redo_log
	--where to_char(begin_time, 'YYYYMMDDHH24MISS') = $2
	where status=1;
spool off;
exit
SQLEOF

cat $log
echo ================================================
from=`awk -F " " ' /200/ { print $1 }' $log`
to=`awk -F " " ' /200/ { print $2 }' $log`
tonext=$(($to+1))

area=`awk -F " " ' /200/ { print $3 }' $log`
status=`awk -F " " ' /200/ { print $4 }' $log`
start=`awk -F " " ' /200/ { print $5 }' $log`
#proc_fr=`awk -F " " ' /200/ { print $6 }' $log`

echo "$from|$to||$tonext|$area|$status|$proc_fr"

if [ status -ne 1 ]; then
	echo "proc_redo_wj has not finished yet."
fi

cd $1
sql="select file_name from dps_redo_files where deal_date='$start'"
# ��ֹʱ��һ�£�ֻ����һ�컰������ȫ����filelistȡ����
# ����������
# 1.ֻ����filelist���ļ���������ȡ$from �� $to+1����Ļ���,
# 2.����ֱ�Ӵ��ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���
# ע�⣺�ڣ�����ڣ������������صĻ���������ļ�ʵʱ�������ܴ�������
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

echo ================================================
cat $filelist
echo ================================================
awk -F " " ' /N_GSM/ { print $1 }' $filelist
awk -F " " ' /N_GSM/ { print $1 }' $filelist|wc -l

echo ================================================
cd /data33/aijs/center/back/settle/wj/voice/huawei
echo $PWD
for file in $(awk -F " " ' /N_GSM/ { print $1 }' $filelist)
do
	ll ${file}.gz
#	gunzip -f ${file}.gz
#	mv ${file} $dst
	
done
	
# ���ļ�ϵͳ�а��ļ���ȡ$from+1 �� $to����Ļ���
# ע���·��л�






#filter="N_GSM*"
#src=/data33/aijs/center/back/settle/wj/voice
#dst=/data33/aijs/center/data/format/output/wj/voice
#
#if [ $# -lt 1 ]; then
#	echo $#
#	echo "bad params!\nUsage:\t$0 <subdir>\nsay:\t$0 huawei nokia alcatel\n"
#	exit -1
#fi
#
#now=`date +%Y%m%d%H%M`
#
#for subdir in $*	# all params as subdir collection 
#do
#	cd $src/$subdir
#	echo === switch to: $PWD
#	
#	count=0
#	for file in $filter
#	do
#		type=`echo $file|cut -c 1-5`
#		head=`echo $file|cut -c 1-18`
#		year=`echo $file|cut -d _ -f 5|cut -c 1-4`
#		month=`echo $file|cut -d _ -f 5|cut -c 1-6`
#		
#		# delete outdated files
#		if [ "$head" = "DR_WJ_VOICE_200512" -o "$year" = "2005" ]; then
#			echo rm $file
#			rm $file
#			
#		# fetch files for redo
#		elif [ "$type" = "N_GSM" -a "$month" = "200601" ]; then
#			echo "mv & gunzip $file"
#			mv $file $dst/$subdir
#
#			# ignore automatically if not gzip file
#			gunzip -f $dst/$subdir/$file
#			
#			count=$(($count+1))
#		else
#			echo $file
#		fi
#		
#		#check disk space
#		mod=`expr $count % 100`
#		if [ $mod -eq 0 ]; then
#			percent=`df -k /data33 | tail -1 | cut -c 57-58`
#			if [ $percent -ge 95 ]; then
#				echo ====================+====================
#				echo ===  WARNING: DISK SPACE NOT ENOUGH!  ===
#				echo ====================+====================
#				sleep 300
#			elif [ $percent -ge 97 ]; then
#				echo ====================+====================
#				echo ===  WARNING: DISK SPACE EXHAUSTED!!  ===
#				echo ====================+====================
#				exit -2
#			fi
#		fi
#	
#	done
#	
#	# record file number for monitoring of process progress
#	echo ============================================================
#	echo $subdir: $count >> ~/center/log/redo.$now.log
#	echo ============================================================
#done

echo "A-OK!"

exit 0
