load data
infile 'smsnews.txt'
append into table smsnews 
Fields terminated by ','
(
bill_month,
bill_id,
fee,
hplmn2
)
