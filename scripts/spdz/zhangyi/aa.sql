sqlplus -S $1/$2@$3 << EOF
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

spool $4.ctl
prompt LOAD DATA
prompt INFILE '$4.dat'
prompt APPEND
prompt INTO TABLE $4
prompt FIELDS TERMINATED BY ','
select decode(rownum,1,'(',',')
      ||COLUMN_NAME from user_tab_columns
where table_name='$4';
prompt )
spool off