#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs"


sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
create table temp_crg_200809_cs as
select * from aicbs.acc_user_bill_dtl_571@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_572@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_573@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_575@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_576@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_570@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_574@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_577@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_578@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_579@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_580@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_571_200809@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_572_200809@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_573_200809@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_575_200809@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_576_200809@zjcsa where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_570_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_574_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_577_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_578_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_579_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
insert into temp_crg_200809_cs
select * from aicbs.acc_user_bill_dtl_j_580_200809@zjcsb where acc_code like '8%1' and 
substr(acc_code,2,6) in (select sp_code from temp_crg) and bill_month='200809';
commit;
exit
SQLEOF

echo "OK! END"

exit 0
