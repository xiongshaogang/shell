load data
infile 'cmreadws.txt'
append into table cmread_ws 
Fields terminated by ','
(
prov_code,    
trademark,
bill_month,
data_type,
cp_id,
cp_data,
reserve1,
reserve2,
reserve3
)
