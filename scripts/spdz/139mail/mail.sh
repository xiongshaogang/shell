#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs"

now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

#得到上个月的月份，比如本月是200710,那么要得到的是200709
zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 2 ]
 then
  LAST_MONTH=`expr $curmonth - 2`
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
MONTH="200904"
echo $MONTH


echo "ftp begin"
if true; then
ftp -i -n 10.70.13.12 << EOF
user shoujiyouxiang sjyx_zmcc
lcd /data1/home/jsusr1/center/scripts/spdz/139mail
bin
prom off
get $MONTH.txt
bye
EOF
echo "ftp end"
mv $MONTH.txt mail.txt
sqlldr aijs/aijs@zmjs control=mail.ctl
echo "sqlldr end"
sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
update mail_user set bill_month=to_char($MONTH),user_type=1;
update mail_user set user_number=replace(user_number,chr(13),'');
commit;
UPDATE mail_user a
SET region_code = (SELECT b.region_code FROM aicbs.cm_user@bca_aiqry b WHERE b.bill_id = a.user_number),
trademark = (SELECT b.trademark FROM aicbs.cm_user@bca_aiqry b WHERE b.bill_id = a.user_number)
WHERE a.bill_month=to_char($MONTH) and EXISTS (SELECT * FROM aicbs.cm_user@bca_aiqry b WHERE b.bill_id = a.user_number);
commit;
UPDATE mail_user a
SET region_code = (SELECT b.region_code FROM aicbs.cm_user@zjcsb b WHERE b.bill_id = a.user_number),
trademark = (SELECT b.trademark FROM aicbs.cm_user@zjcsb b WHERE b.bill_id = a.user_number)
WHERE a.bill_month=to_char($MONTH) and EXISTS (SELECT * FROM aicbs.cm_user@zjcsb b WHERE b.bill_id = a.user_number);
commit;
update mail_user set user_type=3 where bill_month=to_char($MONTH) and user_number in (select bill_id 
from aicbs.cm_user@bca_aiqry where acc_id in (select acc_id from aicbs.cm_account@bca_aiqry where 
bank_account_type=8));
update mail_user set user_type=3 where bill_month=to_char($MONTH) and user_number in (select bill_id   
from aicbs.cm_user@zjcsb where acc_id in (select acc_id from aicbs.cm_account@zjcsb where 
bank_account_type=8));
commit;
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_571@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='571' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_571@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_572@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='572' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_572@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_573@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='573' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_573@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_575@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='575' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_575@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_576@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='576' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_576@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_570@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='570' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_570@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_574@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='574' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_574@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_577@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='577' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_577@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_578@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='578' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_578@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_579@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='579' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_579@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_580@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='580' and a.trademark=1 and exists (select * from aicbs.acc_user_bill_580@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_571_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='571' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_571_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_572_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='572' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_572_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_573_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='573' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_573_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_575_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='575' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_575_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_576_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='576' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_576_$MONTH@bca_aiqry b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_570_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='570' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_570_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_574_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='574' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_574_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_577_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='577' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_577_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_578_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='578' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_578_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_579_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='579' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_579_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user a set a.unpay_fee=(select sum(b.unpay_fee) from aicbs.acc_user_bill_j_580_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH) where a.bill_month=to_char($MONTH) and a.region_code='580' and a.trademark<>1 and exists (select * from aicbs.acc_user_bill_j_580_$MONTH@zjcsb b where b.bill_id=a.user_number and b.bill_month=$MONTH);
update mail_user set user_type=4 where bill_month=$MONTH and unpay_fee>0 and user_type=1;
commit;
exit
SQLEOF
fi
mv mail.txt $MONTH.txt
echo "OK! END"

exit 0
