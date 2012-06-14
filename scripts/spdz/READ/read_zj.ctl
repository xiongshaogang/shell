load data
infile 'cmreadzj.txt'
append into table cmread_zj 
Fields terminated by ','
(
hplmn2,
trademark,
bill_month,
data_type,
cp_id,
cp_data,
reserve1,
reserve2,
reserve3
)
