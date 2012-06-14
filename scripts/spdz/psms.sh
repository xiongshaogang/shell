#!/bin/sh
################################################################################
# Script to generate 分析监控EB文件
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 上传至：10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 

logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curday=`date +%Y%m%d`

logfile=$logpath/spdz/psms${now}.log

count=0
while [ $count -le 4 ]; do


sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000;

spool $logfile;

select '20',curdate from psms_date;

spool off;
exit
SQLEOF

curdate=`awk ' /^20/ { print $2 }' $logfile`
echo "curdate  $curdate"

begin=0
while [ $begin -le 11 ]; do

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000;

spool $logfile;

select '20',$begin*2,$begin*2+1 from dual;

spool off;
exit
SQLEOF
start=`awk ' /^20/ { print $2 }' $logfile`
end=`awk ' /^20/ { print $3 }' $logfile`
start_t=`printf "%02.f" $start`
end_t=`printf "%02.f" $end`
start_time="${curdate}${start_t}0000"
end_time="${curdate}${end_t}5959"

echo "start  $start_time"

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

drop table psms_$curdate;
create table psms_$curdate as select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_hz_$curdate@snzjcba a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_hu_$curdate@snzjcba a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_jx_$curdate@snzjcba a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_sx_$curdate@snzjcba a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_tz_$curdate@snzjcba a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_qz_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_nb_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_wz_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_ls_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_jh_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
insert into psms_$curdate select  a.sequence_no sms_seq,'00' cdr_type,decode(a.trademark,1,0,1) user_type,a.user_number send_dn,'571' send_prov,a.opp_number recieve_dn,b.prov_code rcv_prov,'    0' send_sts,'13800755500' smsc_code,to_char(stop_time,'YYYYMMDDHH24MISS') apply_t,to_char(start_time,'YYYYMMDDHH24MISS') finish_t from jf.dr_sms_zs_$curdate@snzjcbb a,jfsys.gsm_hlr_info@snzjcbsys b where a.dr_type=5501 and to_char(a.start_time,'YYYYMMDDHH24MISS') between $start_time and $end_time and substr(a.opp_number,1,7)=b.hlr_code and b.prov_code<>'571' and b.hlr_type=0;
commit;
set line 250;
set pagesize 5000;

spool $logfile;

select '20',sms_seq,cdr_type,user_type,send_dn,send_prov,recieve_dn,rcv_prov,send_sts,smsc_code,apply_t,finish_t from psms_$curdate;

spool off;

exit
SQLEOF

turn=`printf "%03.f" $begin`
psmsfile=/data1/home/jsusr1/center/uploadfile/PSMS/PSMS${curdate}${turn}.571
awk ' /^20/ { printf("%020d%s%2s%s%s%s%11s%s%3s%s%11s%s%3s%s%4s%s%11s%s%14s%s%14s\r\n", $2,";",$3,";",$4,";",$5,";",$6,";",$7,";",$8,";",$9,";",$10,";",$11,";",$12) }' $logfile >> $psmsfile

gzip $psmsfile

begin=$(($begin + 1))
done

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
update psms_date set curdate=to_char(to_date(curdate,'YYYYMMDD')+1,'YYYYMMDD');
commit;
exit
SQLEOF

count=$(($count + 1))
done

exit 0
