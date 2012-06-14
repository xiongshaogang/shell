load data
infile '/data1/home/jsusr1/center/scripts/spdz/MCBBJ_01_SP_OPER_20090115.txt'
DISCARDFILE '/data1/home/jsusr1/center/scripts/spdz/MCBBJ.dsc'
DISCARDMAX 1000
append into table bps_mcbbj1_oper_tmp
FIELDS TERMINATED BY ';'
OPTIONALLY ENCLOSED BY "
TRAILING NULLCOLS
(
serv_type,
sp_code,
content_code,
operator_code,
operator_name,
member_type,
bill_flag,
fee,
valid_date,
expire_date,
in_prop,
OUT_PROP
)
