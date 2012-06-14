rem sql script to show gateway voice/sms process info.
rem author: fanghm@aisinfo.com

set echo off
set feedback off
set linesize 150
set pagesize 200

ttitle '==================== Gateway Voice/SMS Data Process Info ===================='
rem btitle '---------------------------------------------------------'
col MODULE_NAME	for a22;
col MODULE_CODE	for a20;
col PARAM_CODE	for a10;
col PARAM_VALUE heading 'FILE_NUMBER' for a60; -- justify center
--break on module_id skip 1;

spool v1.sh
--select b.module_id, b.module_name, /*b.program_name,*/ b.module_code, a.param_code, a.param_value 
select 'echo "' || b.module_id || ' ' || b.module_name || '\t' || b.module_code --|| a.param_code 
	|| '\t\c"; l ' || a.param_value || '|wc -w' "MODULE_INFO FILE_NUMBER"
from sys_module_param_detail a, sys_module b       
where a.param_code = 'inputPath'
-- a.param_code like '%Path' and a.param_code not in ('remotePath','configurePath') 
-- in ('inputPath', 'outputPath')                             
-- and substr(to_char(a.module_id),4,2) IN ('41', '45')
and a.module_id=b.module_id  AND b.module_id not in ('100411', '180002')
--and module_name not like '%µ•' 
and module_name not like 'º”‘ÿ¥Ìµ•%' --and module_name not like '%2' 
order by a.module_id, a.param_code;

spool off

set echo on

