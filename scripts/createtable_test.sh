#!/bin/sh
#--------------------------------------------------------------------#
# for debug
#set -x
#set roamgprs.ora
#source /data1/home/jsusr1/.cshrc
##################################
#       for Oracle
##################################
export ORACLE_BASE=/u01/oracle/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/9.2.0
export SHLIB_PATH=$ORACLE_HOME/lib32:/data1/home/jsusr1/center/lib
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib:$ORACLE_HOME/rdbms/lib

echo "SHLIB_PATH: ${SHLIB_PATH}"
echo "LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
##################################

usage()
{
	echo "this script is to create next month's tables of certain type(s)"
	echo author: fanghm
	echo Usage:
	echo "\t createtable.sh [table_type] [table_month]"
	echo Params:
	echo "\t table_month - YYYYMM, default to next month"
	echo "\t table_type - responding to a ora file under ~/center/config/tpl"
	echo "\t say: wjsettle.ora wjsmssettle.ora roamgsm.ora spgsm.ora"
	#echo "\t\t  default to create all tables!\n"
	echo "==============================================================="
}

get_next_month()
{
	local year=`echo $1|cut -c -4`
	
	local mon
	if [ $(echo $1|cut -c 5) -eq 0 ]; then
		mon=$(echo $1|cut -c 6)
	else
		mon=$(echo $1|cut -c 5-6)
	fi
	
	if [ $mon -eq 12 ]; then 	# 12月的下月为下一年1月
		local next_year=$(($year+1))
		next_month=`printf "%d%02d" ${next_year} 1`
	else
		local next_mon=$(($mon+1))
		next_month=`printf "%d%02d" ${year} ${next_mon}`
	fi
		
	#echo "<==return $next_month"
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

#--------------------------------------------------------------------#
#	BEGIN
#--------------------------------------------------------------------#
echo "==============================================================="

now=`date "+%Y-%m-%d %H:%M:%S"`

cd /data1/home/jsusr1/center/config/tpl

if [ $# -eq 0 ]; then
	usage
	exit -1
fi	

if [ "$1" = "all" ]; then
	table_type=`ls -1 *.ora |sort|awk -v ORS="" '{ print $1,$2 }'`
else
	table_type=$1
fi


echo "$now createtable.sh $*"
echo "table_type	: $table_type"

if [ "$2" = "" ]; then
this_month=`date +%Y%m`
get_next_month $this_month
else
next_month=$2
fi

echo "table_month	: $next_month"
from_day="${next_month}01"

get_month_days $next_month
echo "last_day	: $last_day"

for type in $table_type
do
	echo "=========== $type ==========="
	if [ ! -f $type ]; then
		echo "ora file not found: $file"
		usage
		exit -2
	fi
	
	# create tables
	echo "create table of $type"
        /data1/home/jsusr1/center/bin/tool/createtable -S zmjs -U aijs -P aijs -T ./$type -B $next_month -C 1	
done

#Usage: droptable -S server_name [-D database_name] -U username -P password -T tablePattern | -V serviceId -R drType 
#droptable -S zmjs -U aijs -P aijs -V 3 -R 4 -B 20060101 -C 60

# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamch.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamgprs.ora   -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamgsm.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamipc.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamkjava.ora  -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamkorea.ora  -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roammms.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roampps.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamrq.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamsms.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamvc.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamvip.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamwap.ora    -B 20060430 -C 33 &

echo "=================== OK =================="

exit 0
