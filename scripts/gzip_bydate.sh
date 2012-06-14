#!/bin/sh
#
#按日期压缩备份文件
#$1,定义文件中日期的格式和位置,如:...YYYYMMDD
#$2,需日期存放的完整文件名
#$3,是否压缩,1为压缩,0为不压缩
#gzip_bydate.sh ...YYYYMMDD /data02/home/hujie/center/back/dataloader/cdr/roam/billing/kjava/KJ20060701571.000 1
#

if [ "$#" -ne 3 ]
then
	echo "----------------------------------------"
        echo "Usage: $0 ...YYYYMMDD YOURDIR/ ISGZIP"
        echo "----------------------------------------"
        exit -1
fi

if [ "$1" = "NODATE" ]
then
	if [ "$3" -eq 1 ]
	then
		gzip -f $2
		exit 0
	fi
	if  [ "$3" -eq 0 ]
	then
		exit 0
	fi
	
fi

#得到所配"."的长度
digitnumber=`echo $1|tr "." "\n"|wc -l`
digitlength=`expr $digitnumber - 1`
echo "digitlength="$digitlength

#得到文件名,路径名
filename=`basename $2`
filedir=`dirname $2`

#得到所配年份格式的长度
yearnumber=`echo $1|tr "Y" "\n"|wc -l`
yearlength=`expr $yearnumber - 1`
echo "yearlength="$yearlength

if [ 0 -eq "$yearlength" ];then
	yeardir=""
else
	fileyear=`expr substr $filename $digitnumber $yearlength`
	yeardir="$fileyear/"
fi
echo "yeardir= "$yeardir

#月份配置一般为MM,主要是考虑不配的情况
monthnumber=`echo $1|tr "M" "\n"|wc -l`
monthlength=`expr $monthnumber - 1`
echo "monthlenth="$monthlength

if [ 2 -eq "$monthlength" ];then
	monthpos=`expr $digitlength + $yearlength + 1`
	filemonth=`expr substr $filename $monthpos 2`
	monthdir="$filemonth/"
		
	daypos=`expr $monthpos + 2`

else
	monthdir=""
	daypos=`expr $digitlength + $yearlength + 1`	

fi
echo "monthdir="$monthdir

#得到日期,日期配置一般为DD,主要是考虑不配的情况
daynumber=`echo $1|tr "D" "\n"|wc -l`
daylength=`expr $daynumber - 1`
echo "daylength="$daylength

if [ 2 -eq "$daylength" ];then
	fileday=`expr substr $filename $daypos 2`
	daydir="$fileday/"
else
	daydir=""
fi
echo "daydir="$daydir

if [ ! -d "$filedir/$yeardir$filemonth$daydir" ]; then
	mkdir -p $filedir/$yeardir$monthdir$daydir
	echo "mkdir -p $filedir/$yeardir$monthdir$daydir"
fi

if [ "$yeardir"!="" ]||[ "$monthdir"!="" ]||[ "$daydir"!="" ];then
	mv $2 $filedir/$yeardir$monthdir$daydir
fi

if [ "$3" -eq 1 ]
then
	gzip -f $filedir/$yeardir$monthdir$daydir$filename
fi

if [ $? -eq 0 ];then
	exit 0
else
	exit -1
fi
