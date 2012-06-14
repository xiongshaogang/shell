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

spool test.ctl
prompt LOAD DATA
prompt INFILE '$1'
prompt APPEND INTO TABLE eb_error_temp
prompt (
prompt err_code position(1:4),
prompt call_cdr position(11:127)
prompt )
