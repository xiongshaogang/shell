load data
infile 'EDED.txt'
append into table TEMP_UP_EDED_08
FIELDS TERMINATED BY ','
(
busi_type,
row_num,
bill_id,
sp_code,
ded_type,
use_time,
ded_time,
fee
)
