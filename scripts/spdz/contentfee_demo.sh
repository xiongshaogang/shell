#!/bin/sh
################################################################################
# Script to generate 内容计费核减数据上报文件
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 上传至：10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 
#DB_CONNECT_STRING="newjs/newjs@testjs"	#testjs


logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

#得到上个月的月份，比如本月是200710,那么要得到的是200709
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


logfile=$logpath/spdz/contentfee_${now}.log
ilogfile=$logpath/spdz/contentfeejf_${now}.log

# 退费上报文件
contentfee_file=/data1/home/jsusr1/center/uploadfile/DED/DED${curdate}000.571	# DEDYYYYMMDDNNN.ZZZ
#contentfee_file=/data1/home/jsusr1/center/scripts/spdz/DED${curdate}000.571
curfile=DED${curdate}000.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile

if [ -f "$contentfee_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $contentfee_file $contentfee_file.bak.$now
	#exit -1
fi

# 文件头记录
blanks=`printf "%104s" " "`
head="1046000571  46000000  000${now}01$blanks\r\n"
echo "$head\c" > $contentfee_file



#取营业库退费数据
if true; then
################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $logfile;

select '20',decode(b.serv_type,001103,'CM        ',000103,'MMS       ',000104,'WAP       ',
000105,'FLASH     ',000005,'GD        '),'01',a.bill_id,a.sp_ecode,
a.sp_code,'03',to_char(sysdate, 'YYYYMMDDHH24MISS'),to_char(a.op_date, 'YYYYMMDDHH24MISS'),
a.rev_fee rev_fee,to_char(a.done_code) 
from aicbs.fee_rev_info@bca_aicbs a,bps_mcbbj0_oper b
where to_char(a.op_date, 'YYYYMMDD') = to_char(sysdate-1,'YYYYMMDD') 
#where to_char(a.op_date, 'YYYYMM') = '200708'
and a.REV_FEE_MODULE=1 and a.sp_ecode=b.sp_code and a.sp_code=b.operator_code and b.bill_flag > 1 and  
b.serv_type in ('001103','000103','000104','000105','000005') and b.expire_date >= to_char(sysdate, 'YYYYMMDD') 
and a.sp_ecode not in ('900002','900101','900103','900113','900109','900127','900110','900107','900112','900116',
'900128','900108','900132','900119','900120','900124','900117','900114','900105','900130',
'900129','900115','900104','900102','900126','900131','900125','900111','900122','801008',
'801062','801075','817027','819204','801344','801175','801233','801110','801241','801237',
'801228','819248','801217','801225') 
group by to_char(a.op_date, 'YYYYMMDDHH24MISS'), a.bill_id,a.sp_ecode,b.operator_code,
a.rev_fee,b.serv_type,a.sp_code,b.bill_flag,a.done_code;

select '20',decode(b.serv_type,001103,'CM        ',000103,'MMS       ',000104,'WAP       ',
000105,'FLASH     ',000005,'GD        '),'01',a.bill_id,a.sp_ecode,
a.sp_code,'03',to_char(sysdate, 'YYYYMMDDHH24MISS'),to_char(a.op_date, 'YYYYMMDDHH24MISS'),
a.rev_fee rev_fee,to_char(a.done_code) 
from aicbs.fee_rev_info@bcb_aicbs a,bps_mcbbj0_oper b
where to_char(a.op_date, 'YYYYMMDD') = to_char(sysdate-1,'YYYYMMDD') 
#where to_char(a.op_date, 'YYYYMM') = '200708'
and a.REV_FEE_MODULE=1 and a.sp_ecode=b.sp_code and a.sp_code=b.operator_code and b.bill_flag > 1 and 
b.serv_type in ('001103','000103','000104','000105','000005') and b.expire_date >= to_char(sysdate, 'YYYYMMDD') 
and a.sp_ecode not in ('900002','900101','900103','900113','900109','900127','900110','900107','900112','900116',
'900128','900108','900132','900119','900120','900124','900117','900114','900105','900130',
'900129','900115','900104','900102','900126','900131','900125','900111','900122','801008',
'801062','801075','817027','819204','801344','801175','801233','801110','801241','801237',
'801228','819248','801217','801225') 
group by to_char(a.op_date, 'YYYYMMDDHH24MISS'), a.bill_id,a.sp_ecode,b.operator_code,
a.rev_fee,b.serv_type,a.sp_code,b.bill_flag,a.done_code;

spool off;
exit
SQLEOF
################################################################################
fi


awk ' /^20/ { printf("%2s%-10s%2s%-20s%-15s%-20s%-20s%02s%14s%14s%06.f%20s\r\n", $1,$2,$3,$11,$4,$5,$6,$7,$8,$9,$10," ") }' $logfile >> $contentfee_file
cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("lines:%d sum: %f \r\n", n, s) }'
ncount=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; } END { printf("%d", n) }'`
nsum=`cat $logfile | awk '/^20/ {print}' | awk '{ s+= $10; } END { printf("%.f", s) }'`


#每个月10号取经分自消费和恶意欠费数据
#if [ "$curday" = "10" ]; then
if true; then

################################自消费##############################
#select '20',decode(a.type,'短信梦网业务','CM        ','MMS业务','MMS       ','WAP业务','WAP       ',
#'百宝箱业务','GD        '),'03','00000000000000000000',a.bill_id,a.sp_code,a.service_code,
#'03',to_char(sysdate, 'YYYYMMDDHH24MISS'),a.sp费用*100 fee  
#from dw.DW_SP_JKYIFZ01_$MONTH@REPORT2 a where a.type in ('短信梦网业务','MMS业务','WAP业务',
#'百宝箱业务') and a.sp费用<10000.00;

########################################################################################
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $ilogfile;

select '20',decode(a.busi_type,'短信梦网','CM        ','彩信','MMS       ','WAP','WAP       ',
'百宝箱','GD        ','手机动画','FLASH     '),'02',row_number() over(order by a.bill_id) iNumber,a.bill_id,a.sp_code,
'000000              ','03',to_char(sysdate, 'YYYYMMDDHH24MISS'),a.info_fee*100 fee,a.bill_month||'30000000' bill_month 
from dw.jkyifz04_stop_200709_new@REPORT2 a where a.busi_type in 
('短信梦网','彩信','WAP','百宝箱','手机动画') and decode(a.busi_type,'短信梦网','001103','彩信','000103','WAP','000104',
'百宝箱','000005','手机动画','000105') in (select b.serv_type from bps_mcbbj0_oper b
where b.sp_code=a.sp_code and b.bill_flag >1 and a.bill_month||'01'<b.expire_date) and a.info_fee>0 and a.info_fee<10000 and a.sp_code not in 
('900002','900101','900103','900113','900109','900127','900110','900107','900112','900116',
'900128','900108','900132','900119','900120','900124','900117','900114','900105','900130',
'900129','900115','900104','900102','900126','900131','900125','900111','900122','801008',
'801062','801075','817027','819204','801344','801175','801233','801110','801241','801237',
'801228','819248','801217','801225');

select '20',decode(a.busi_type,'短信梦网','CM        ','彩信','MMS       ','WAP','WAP       ',
'百宝箱','GD        ','手机动画','FLASH     '),'02',row_number() over(order by a.bill_id) iNumber,a.bill_id,a.sp_code,
'000000              ','03',to_char(sysdate, 'YYYYMMDDHH24MISS'),a.info_fee*100 fee,a.bill_month||'30000000' bill_month 
from dw.jkyifz04_stop_200710_new@REPORT2 a where a.busi_type in 
('短信梦网','彩信','WAP','百宝箱','手机动画') and decode(a.busi_type,'短信梦网','001103','彩信','000103','WAP','000104',
'百宝箱','000005','手机动画','000105') in (select b.serv_type from bps_mcbbj0_oper b
where b.sp_code=a.sp_code and b.bill_flag >1 and a.bill_month||'01'<b.expire_date) and a.info_fee>0 and a.info_fee<10000 and a.sp_code not in 
('900002','900101','900103','900113','900109','900127','900110','900107','900112','900116',
'900128','900108','900132','900119','900120','900124','900117','900114','900105','900130',
'900129','900115','900104','900102','900126','900131','900125','900111','900122','801008',
'801062','801075','817027','819204','801344','801175','801233','801110','801241','801237',
'801228','819248','801217','801225');

select '20',decode(a.busi_type,'短信梦网','CM        ','彩信','MMS       ','WAP','WAP       ',
'百宝箱','GD        ','手机动画','FLASH     '),'02',row_number() over(order by a.bill_id) iNumber,a.bill_id,a.sp_code,
'000000              ','03',to_char(sysdate, 'YYYYMMDDHH24MISS'),a.info_fee*100 fee,a.bill_month||'30000000' bill_month
from dw.jkyifz04_stop_200711_new@REPORT2 a where a.busi_type in 
('短信梦网','彩信','WAP','百宝箱','手机动画') and decode(a.busi_type,'短信梦网','001103','彩信','000103','WAP','000104',
'百宝箱','000005','手机动画','000105') in (select b.serv_type from bps_mcbbj0_oper b
where b.sp_code=a.sp_code and b.bill_flag >1 and a.bill_month||'01'<b.expire_date) and a.info_fee>0 and a.info_fee<10000 and a.sp_code not in 
('900002','900101','900103','900113','900109','900127','900110','900107','900112','900116',
'900128','900108','900132','900119','900120','900124','900117','900114','900105','900130',
'900129','900115','900104','900102','900126','900131','900125','900111','900122','801008',
'801062','801075','817027','819204','801344','801175','801233','801110','801241','801237',
'801228','819248','801217','801225');

spool off;
exit
SQLEOF
########################################################################################	


awk ' /^20/ { printf("%2s%-10s%2s%-20s%-15s%-20s%-20s%02s%14s%14s%06.f%20s\r\n", $1,$2,$3,$4,$5,$6,$7,$8,$9,$11,$10," ") }' $ilogfile >> $contentfee_file

cat $ilogfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("lines:%d sum: %f \r\n", n, s) }'
ncount=$(($ncount+`cat $ilogfile | awk '/^20/ {print}' | awk '{ n+=1; } END { printf("%d", n) }'`))
nsum=$(($nsum+`cat $ilogfile | awk '/^20/ {print}' | awk '{ s+= $10; } END { printf("%.f", s) }'`))

ncount=`printf "%09d" $ncount`
nsum=`printf "%012.f" $nsum`
blanks=`printf "%99s" " "`
linefmt="$ncount$nsum$blanks"
#linefmt=`cat $ilogfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("%09d%012.f%99s", $ncount, $nsum, " ") }'`
else
linefmt=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=1; s+= $10 } END { printf("%09d%012.f%99s", n, s, " ") }'`
fi

echo $linefmt


# contentfee_file tail
tail="9046000000  46000571  000$linefmt"
echo "$tail\r" >> $contentfee_file

echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$contentfee_file"

#echo "ftp $curfile"
##--------------------------------------------------------------------#
#echo begin

#ftp -i -n 10.70.11.77  << EOF
#user mcb3tran mcB3!571 
#lcd /data1/home/jsusr1/center/uploadfile/DED
#cd /opt/mcb/pcs/cbbs/ded/data/outgoing/
#bin
#prom off
#put $curfile 
#bye
#EOF
##--------------------------------------------------------------------#  

echo "A-OK!"

exit 0
