LOAD DATA
INFILE '/data/aijs/wjsms/center/scripts/spdz/SOFTWARE/software.txt'
APPEND INTO TABLE plt_software
FIELDS TERMINATED BY ',' TRAILING NULLCOLS
(
hplmn2,
trademark,
bill_month,
data_source,
charge_code,
charge_value,
reserverd1,
reserverd2,
reserverd3
)
