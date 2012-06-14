LOAD DATA
INFILE '/data1/home/jsusr1/center/scripts/spdz/mobilewin/dyjresult.txt'
APPEND INTO TABLE mobilewin
FIELDS TERMINATED BY ',' TRAILING NULLCOLS
(
SHEET_CNT,
CP_CODE,
CP_NAME
)
