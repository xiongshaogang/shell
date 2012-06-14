load data
infile '/data1/home/jsusr1/center/scripts/spdz/SP_rate_info_12586_GSM_20100521.txt'
append into table ivr_sp_info 
FIELDS TERMINATED BY X'09'
TRAILING NULLCOLS
(
row_id,
sp_name,
operator_code,
fee_code,
operator_region,
valid_date,
expire_date,
term_valid_date,
term_expire_date,
operator_name,
bill_type,
bill_sec,
fee,
resv1,
resv2,
resv3,
resv4,
resv5,
resv6,
sp_allot,
self_allot,
sp_code,
plt_region
)
