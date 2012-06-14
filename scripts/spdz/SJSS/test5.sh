#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs"


sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
create table temp_gd_200811  as 
select  * from aicbs.acc_user_bill_dtl_571@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_572@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert nto temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_573@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select * from aicbs.acc_user_bill_dtl_575@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_576@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_570@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_574@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_577@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_578@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_579@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_580@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select * from aicbs.acc_user_bill_dtl_j_571_200811@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_572_200811@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_573_200811@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_575_200811@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_576_200811@bca_aiqry a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_570_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_574_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_577_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_578_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select * from aicbs.acc_user_bill_dtl_j_579_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
insert  into temp_gd_200811
select  * from aicbs.acc_user_bill_dtl_j_580_200811@zjcsb a where a.acc_code like '8%1' and 
substr(a.acc_code,2,6) in (select sp_code from temp_gd) and a.bill_month='200811';
commit;
exit
SQLEOF

echo "OK! END"

exit 0
