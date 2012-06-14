sqlplus -S aijs/aijs@zmjs << EOF
set pagesize 2000
set linesize 20
set feedback off
set heading off
set echo off
set newpage 0
set tab on
set trim on
set term off
set recsep off
set flush off

spool EDED.ctl
prompt LOAD DATA
prompt INFILE '$1'
prompt APPEND INTO TABLE ded_mid_error
prompt (
prompt err_code position(1:4),
prompt rev_head position(14:15),
prompt serv_type position(16:25) "Trim(:serv_type)",
prompt fee_type position(26:27),
prompt bill_id position(48:62) "Trim(:bill_id)",
prompt sp_code position(63:82) "Trim(:sp_code)",
prompt operator_code position(83:102) "Trim(:operator_code)",
prompt bill_type position(103:104),
prompt use_time position(105:118),
prompt ded_time position(119:132),
prompt rev_fee position(133:138),
prompt done_code position(28:47) "Trim(:done_code)"
prompt )

