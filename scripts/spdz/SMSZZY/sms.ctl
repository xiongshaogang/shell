LOAD DATA
INFILE '/data1/home/jsusr1/center/scripts/spdz/SMSZZY/forwardresult_20100528200609_00010.TXT'
APPEND INTO TABLE sms_forwardresult
FIELDS TERMINATED BY ',' TRAILING NULLCOLS
(
SEND_NUM,
RECEIVE_NUM,
SEND_TYPE,
SEND_DATE,
CP_CODE,
CP_NAME "Trim(:CP_NAME)"
)
