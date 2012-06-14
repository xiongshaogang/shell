#!/bin/csh

#--------------------得到昨天的日期----------------------------------#
yy=`date +%Y` #Year yyyy
mm=`date +%m` #Month mm
dd=`date +%d` #Day dd
#echo $dd $yy $mm
if [ "$dd" = "01" ] 
then
 lm=`expr $mm - 1 ` 
  if [ $lm -eq 0 ]
  then 
    lm=12
     yy=`expr $yy - 1 ` 
  fi
  echo lm=$lm
   case $lm in
     1|3|5|7|8|10|12) Yesterday=31 ;;
     4|6|9|11) Yesterday=30 ;;
     2) 
     if [ ` expr $yy % 4 ` -eq 0 -a `expr $yy % 100 ` -ne 0 -o ` expr $yy % 400 ` -eq 0 ]
     then Yesterday=29
     else Yesterday=28
     fi ;;
   esac 
   mm=$lm
   echo Yesterday=$Yesterday
   echo $mm
 else 
   Yesterday=`expr $dd - 1 ` 
 fi
 case $Yesterday
     in 1|2|3|4|5|6|7|8|9) Yesterday='0'$Yesterday
    esac
  case $mm in
       1|2|3|4|5|6|7|8|9) mm='0'$mm ;;
  esac
 
  Yesterday=$yy$mm$Yesterday
# echo '数据日期（昨天）   :'$Yesterday
  Today=`date +%Y%m%d`
# echo '文件生成日期（今天） :'$Today
#----------------------------end--------------------------------------#

#----------------------------ftp DED file-------------------------------------#
ftp -i -n 10.70.11.77  << EOF
user mcb3tran mcB3!571 
lcd /data1/home/jsusr1/center/uploadfile/error/DED
cd /opt/mcb/pcs/cbbs/ded/error/incoming/
bin
prom off
get  *DED$Yesterday000.571
bye
EOF
#--------------------------------------------------------------------#  

#-------------得到上个月的月份，比如本月是200710,那么要得到的是200709----------#
zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 1 ]
 then
  LAST_MONTH=`expr $curmonth - 1`
  if [ $LAST_MONTH -lt 10 ]
   then
  	MONTH="$CURRENT_YEAR$zeros$LAST_MONTH"
  else
    MONTH="$CURRENT_YEAR$LAST_MONTH"
  fi
 else
  LAST_MONTH=12
  MONTH="$LAST_YEAR$LAST_MONTH"
fi
#----------------------------end---------------------------------------#

now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

#---------------------------ftp ivr file------------------------------#
if [ "$curday" = "12" ]; then
ftp -i -n 132.32.22.18  << EOF
user ftp_571 571@JLWZ 
lcd /data1/home/jsusr1/center/uploadfile/ptzc
asc
prom off
mput PTZC_*$1.571 
bye
EOF
fi