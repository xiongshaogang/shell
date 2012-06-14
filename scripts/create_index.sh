#!/bin/sh
#--------------------------------------------------------------------#
# for debug
# set -x

usage()
{
	echo "this script is used to create index for wj voice/sms dr-table"
	echo author: fanghm
	echo Usage:
	echo "\t create_index.sh month field VOICE|SMS"
	echo Params:
	echo "\t month - yyyymm"
	echo "\t field - ODN/TDN/COND_ID"
	echo "==============================================================="
}

get_month_days()
{
	local nmon
	if [ $(echo $1|cut -c 5) -eq 0 ]; then
		nmon=$(echo $1|cut -c 6)
	else
		nmon=$(echo $1|cut -c 5-6)
	fi
	
	# 计算上月天数
	last_day=31
	case $nmon in
		4|6|9|11)	last_day=30;;
		2) last_day=28;;
	esac
	
	local nyear=`echo $1|cut -c -4`
	
	# 如果是2月还要考虑闰年2月只有29天
	# 闰年计算: 能被400整除，或者能被4整除而不能被100整除
	if [ $last_day -eq 28 ]; then 
		if [ $(($nyear%400)) -eq 0 -o  $(($nyear%4)) -eq 0 -a $(($nyear%100)) -ne 0  ]; then
			last_day=29;
		fi
	fi
	#echo "<==return days of $1 is: $last_day"
}
##################################################
if [ $# -lt 2 ]; then
	usage
	exit -1
fi	

get_month_days $1
idx_field=$2

tbl_type=$3
if [ $tbl_type = "" ]; then
	tbl_type=VOICE
fi

now=`date "+%Y%m%d%H%M%S"`
sql_file="./temp/idx_${tbl_type}_$1_${idx_field}_$now.sql"
rm -f $sql_file
touch $sql_file

day=1
today=`date "+%d"`
while [ $day -le $last_day -a $day -lt $today ]; do
	dr_date=`printf "%d%02d" $1 $day`
	echo "create index IDX_WJ_${tbl_type}_${dr_date}_$idx_field on DR_WJ_${tbl_type}_${dr_date} ($idx_field) tablespace AIJS_DR_IDX;" >> $sql_file
	day=$(($day+1))
done
echo "exit;" >> $sql_file

nohup sqlplus aijs/aijs@zmjs @$sql_file &

echo "sqlplus is creating index:"
echo "========================================="
ps -ex|grep $sql_file|grep -v grep
echo "=================== OK =================="

exit 0


# --在cond_id上的索引，每月10号的表上必建，用于前台"帐务管理"->"对帐"->"对帐文件生成"
# create index IDX_WJ_VOICE_20060701_COND_ID on DR_WJ_VOICE_20060701 (COND_ID)
#   tablespace AIJS_DR_IDX;
#   
# --在ODN/TDN上的索引，建在所以网间详单表上，用于后台查询或前台"帐务管理"->"对帐"->"综合查询"  
# create index IDX_WJ_VOICE_20060701_ODN on DR_WJ_VOICE_20060701 (ODN)
#   tablespace AIJS_DR_IDX; 
# 
# create index IDX_WJ_VOICE_20060701_TDN on DR_WJ_VOICE_20060701 (TDN)
#   tablespace AIJS_DR_IDX;   
