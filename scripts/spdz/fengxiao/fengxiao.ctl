load data
infile 'DOIMFPRODUCT.txt'
append into table FENXIAO_PROD
Fields terminated by ','
(
user_code,
count_date,
user_hortation,
user_punishment,
remuneration_back
)
