set line 250;
set pagesize 5000; 

spool &1;

SELECT '20','04',sp_ecode,0,&2,sum(bfee) FROM 
(select sp_ecode,round(rev_fee*b.sp_rate/100,0) bfee from 
FEE_REV_INFO@bca_aicbs a,bps_add_ivr_sp b
where to_char(a.op_date,'yyyymm')='&2'
and a.REV_FEE_MODULE=1
and a.sp_ecode =b.sp_code
union all
select sp_ecode,round(rev_fee*b.sp_rate/100,0) bfee from 
FEE_REV_INFO@bcb_aicbs a,bps_add_ivr_sp b
where to_char(a.op_date,'yyyymm')='&2'
and a.REV_FEE_MODULE=1
and a.sp_ecode =b.sp_code)
group by sp_ecode;
spool off;
exit;
/

