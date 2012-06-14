/*
�� ��: ���ݿ⵱ǰ״�����棬����orcl_info_report.txt�ļ���
ʹ�÷���: sqlplus /nolog @orcl_info.sql 
Created By fanghm
*/

--accept un prompt '�û�����'
--accept pw prompt '�� �룺' hide
--accept db prompt '���ݿ⣺'
--define ���ݿ����Ӵ�=&un/&pw@&db;
define ���ݿ����Ӵ�=aijs/aijs@zmjs;

--accept ��ע��schema prompt '��ע��schema��'
--define ��ע��schema=AIJS

connect &���ݿ����Ӵ�;
pause ������
--EXEC DBMS_STATS.gather_schema_stats(upper('&��ע��schema'),20);

--set term off 
set echo off feed off head off verify off
set trimspool on
set long 5000
set linesize 200 pagesize 9999
set serveroutput on size 1000000
set numwidth 10

spool orcl_info_report.txt
column rep_name format a80
select 'host='||utl_inaddr.GET_HOST_NAME()||',IP='||utl_inaddr.GET_HOST_ADDRESS()||',DB='||name||chr(13)||'���ݿ����б���' rep_name from v$database;
prompt
set head on
select 'Reported by orcl_info.sql On '||
to_char(sysdate,'yyyy-mm-dd HH24:MI:SS')
"���洴��ʱ�䣺" from dual;

PROMPT
PROMPT *********************************************************
PROMPT ***���ݿ�ſ���Ϣ�� ***
PROMPT *********************************************************
PROMPT
PROMPT ���ݿ��Ʒ�汾��
column banner format a75 trunc
select * from v$version;
PROMPT 
prompt ��ǰʵ��״̬��Ϣ��
column instance_name,startup_time,archiver format a20 trunc
column host_name format a20 trunc
column instance_number format 99
select a.instance_name,to_char(a.startup_time,'YYYY-MM-DD HH24:MI:SS') startup_time,a.archiver,a.host_name,a.instance_number 
from v$instance a;

PROMPT 
prompt ��ǰ���ݿ�״̬��Ϣ��
rem for 8i or after 
select name,to_char(created,'yyyy-mm-dd hh24:mi:ss') created,log_mode ,open_mode from v$database ;
rem for 8 or before
rem ++ select name,to_char(created,'yyyy-mm-dd hh24:mi:ss') created,log_mode from v$database ;

PROMPT 
prompt ��������Ϣ��
select * from v$license;

PROMPT 
prompt ��ǰSession��Ϣ��
column username format a10 trunc
column osuser format a15 trunc
column machine format a20 
column program format a28
set numwidth 8
SELECT a.SID,a.USERNAME,a.STATUS,a.OSUSER,A.MACHINE,a.PROGRAM,a.LOGON_TIME FROM V$SESSION a 
WHERE a.TYPE='USER' ORDER BY 2;

PROMPT 
prompt ��ǰDB_job��Ϣ��
column LOG_USER format a20 trunc
column SCHEMA_USER format a20 trunc
column INTERVAL format a30 trunc
column what format a50 TRUNC
SELECT A.JOB, A.WHAT, A.LOG_USER, A.SCHEMA_USER, A.LAST_DATE, A.THIS_DATE, A.NEXT_DATE, A.BROKEN, A.INTERVAL, A.FAILURES
FROM DBA_JOBS A;

PROMPT 
PROMPT ռ�ÿռ䳬��10G��ʵ�壺
column SEGMENT_NAME format a30 trunc
column partition_name format a30 trunc
SELECT ROUND(SUM(SEG.BYTES / 1024 / 1024), 0) SPACE_M, SEG.OWNER, SEG.SEGMENT_NAME, SEG.partition_name, SEG.SEGMENT_TYPE, SEG.HEADER_FILE
FROM DBA_SEGMENTS SEG
GROUP BY rollup(SEG.OWNER, SEG.SEGMENT_NAME, SEG.partition_name,SEG.SEGMENT_TYPE, SEG.HEADER_FILE )
HAVING SUM(SEG.BYTES) > 1024 * 1024 * 1024 * 10
ORDER BY 1 DESC ;

PROMPT 
PROMPT ���ע���µ�SQL��䣺
PROMPT ����ʹ��set autot trace �ۿ���ִ��·��
column sql_text format a60
SELECT EXECUTIONS , DISK_READS, BUFFER_GETS,ROUND((BUFFER_GETS-DISK_READS)/BUFFER_GETS,2) Hit_radio,
ROUND(DISK_READS/EXECUTIONS,2) Reads_per_run,SQL_TEXT
FROM V$SQLAREA
WHERE EXECUTIONS>0 AND BUFFER_GETS > 0 AND (BUFFER_GETS-DISK_READS)/BUFFER_GETS < 0.6 
ORDER BY 2 desc;

prompt
prompt �������ݿ��ڴ漰��������Ϣ
prompt SGA�ռ���䣺
set numwidth 10
select * from v$sga;
SELECT pool,name,round(a.bytes/1024/1024,3) VALUE_M FROM v$sgastat a order by 3 DESC;
prompt 
prompt ����Shared_Pool:
prompt 1.V$LIBRARYCACHE gives the pins/reload ratio for the library cache. The GETHITRATIO 
prompt column should be .95 or higher.
select round(gethitratio*100,2) gethitration from v$librarycache where namespace = 'SQL AREA';
prompt The RELOADS column should be equal to or less than 1% of the PINS column. 
select round(sum(reloads)/sum(pins)*100,2) reloadration from v$librarycache;

prompt 2. The GETMISSES to GETS columns in V$ROWCACHE should have a ratio less than 15% . 
select round(sum(GETMISSES)/sum(GETS)*100,2) getmissration from V$ROWCACHE ;
prompt 
prompt �ж�shared_pool�Ƿ����
select pool,name,round(bytes/1024/1024,2) size_M 
from v$sgastat where name = 'free memory';

prompt 
prompt ����DB_BUFFERS :
prompt 3.The buffer cache hit ratio should be 90% or higher. 
prompt Hit Ratio = 1 �C (physical reads/(db block gets + consistent gets)) 
SELECT round(1 - (phy.value / (cur.value + con.value)),4)*100 "CACHEHITRATIO" 
FROM v$sysstat cur, v$sysstat con, v$sysstat phy 
WHERE cur.name = 'db block gets' AND con.name = 'consistent gets' AND phy.name = 'physical reads';
prompt Buffer Hit�㹻��(>95%)��ʾ�����ʽϸ�,������Ե������ݻ������Ĵ�С

prompt 
prompt �ж�DB_BUFFERS�Ŀձ�������sysdba��ݲ鿴��
prompt select decode(state,0,'Free',1,'Read and Modified',2,'Read and not Modified',3,'Currently Being READ','Other') state, count(*) count from x$bh group by state;
--select decode(state,0,'Free',1,'Read and Modified',2,'Read and not Modified',3,'Currently Being READ','Other') state, count(*) count from x$bh group by state;
prompt 
prompt About Sort_Area_Size:
SELECT a.VALUE "sorts(memory)",b.VALUE "sorts(disk)" FROM v$sysstat a,v$sysstat b 
WHERE a.NAME='sorts (memory)' and b.NAME='sorts (disk)';
prompt In-memory Sort���ִ�(>95%)��ʾ�󲿷��������ڴ��н�������,�������sort_area_size��ֵ����pga_aggregate_target��ֵ
prompt 
prompt About PGA_Size:
SELECT NAME,round(VALUE/1024/1024,2) size_M FROM v$pgastat;
prompt 
prompt �ڴ�������òο�(9i spfile����,1Gmem,--2Gmem)��
prompt alter system set sga_max_size=800m scope=spfile; --1600m
prompt alter system set db_cache_size=480m;--1280m
prompt alter system set db_keep_cache_size=64m;--64m
prompt alter system set shared_pool_size=160m;--240m
prompt alter system set pga_aggregate_target=64m;--64m
prompt ��Ҫʱ�ɿ��ǽ�ĳӦ��ģʽ������ȫ����
prompt SELECT 'alter table '||OWNER||'.'||table_name||' STORAGE(BUFFER_POOL KEEP);' FROM dba_tables WHERE owner='GRAINTEST'
prompt SELECT 'select /*+FULL(A)*/ count(*) from '||OWNER||'.'||table_name||' A;' FROM dba_tables WHERE owner='GRAINTEST'

PROMPT 
prompt ��ע�ĳ�ʼ������:
column name format a40 trunc
column value format a70 
select name, value from v$parameter where name in ('aq_tm_processes','bitmap_merge_area_size',
'compatible','cpu_count','create_bitmap_area_size','cursor_sharing','db_cache_advice','db_cache_size',
'db_keep_cache_size','db_recycle_cache_size','dispatchers','global_names','hash_area_size',
'hash_join_enabled','java_pool_size','large_pool_size','log_buffer','optimizer_mode',
'pga_aggregate_target','processes','query_rewrite_enabled','sga_max_size','shared_pool_size',
'shared_servers','sort_area_size','timed_statistics','workarea_size_policy');

PROMPT 
PROMPT ���ݿ��еȴ��¼�(ǰ10λ)��״����
column event format a30 
select * from (select * from V$SYSTEM_EVENT order by 4 desc) where rownum<=10;
prompt 
prompt Buffer Busy Wait:���ʵĿ����ڶ�ȡ��,�������������ڽ����ݶ���Cache��,���ʵĿ������޸���,�������������޸�Cache�е�����,����˼·���������ļ����ڶ�ȡ�ٶȸ�����豸��
prompt Checkpoint Completed:�ȴ�Checkpoint��������,����˼·����СһЩlog buffer�Ĵ�С,����Checkpoint��Ƶ��,��log�ļ����ڸ�����豸��,��RAID
prompt Control File Parallel Write:�ȴ������еĿ����ļ�д����,����˼·������control file�ĸ���,����ͬcontrol file�ֲ�����ͬ�Ĵ���������
prompt Control File Sequential Read :��Control File�ж�ȡ��Ϣ,����˼·����Control File���ڱȽϿ��еĴ�����,��Control File�����ٶȸ���Ĵ�����
prompt DB File Parallel Read:һ���ڲ��лָ�ʱ����,����˼·�������ļ��ڲ�ͬ���������ϵķֲ�,ѡ�÷����ٶȸ���Ĵ���
prompt DB File Parallel Write:DBWn���̽�����д�������ļ�,����˼·�������ļ��ڶ�����̿�����֮��ķֲ�,�������������������д�ٶȡ�
prompt DB File Scattered Read:��ȡ���������ݿ鵽Cache��,����˼·����������ϵ�����,�ռ�����ͳ����Ϣ
prompt DB File Sequential Read:һ��ָ��ȡ����������,����˼·���������������,Rebuild�������������Ч��
prompt Direct Path Read:ֱָ�Ӵ��ļ��ж�ȡ����Ҫ�����ڼ��Direct Path Writerд�Ƿ����,����˼·�������ļ��ֲ�,ѡ�ø���Ĵ����豸
prompt Direct Path Write:ֱ���������ļ�д���ݣ�������Direct Insert�� Insert /*+ append */ �� sqlldr������direct=true ,����˼·�������ļ��ֲ�,ѡ�ø���Ĵ����豸
prompt Enqueue:Emqueue��Oracle�ڲ���һ�������������д��в���,����˼·������enqueue_resources����
prompt Free Buffer Wait:Ѱ�ҿ���Cache�飬����������ݱ��޸ģ���û�п��õĿ��п�,����˼·:����db_block_buffers��db_cache_size��ֵ
prompt Log Buffer Space:������־���ٶȴ��ڽ���־д�����̵��ٶ�,����˼·:����log_buffer��ֵ,��log�ļ��ŵ����еĴ����豸��
prompt Log File Parallel Write:�ȴ�logд��������������־���еĳ�Ա�ڿ���豸�ϣ��е��������豸��,����˼·:��log�ĳ�Ա�ֲ�����ͬ�Ĵ�����,�ø���Ĵ����豸
prompt Log File Switch (��):Archiving needed �ȴ��鵵���,����˼·������log_archive_processes������,Checkpoint not completed �ȴ��л�����һ����־,����˼·��������־������ݣ�������С, Completion �ȴ���־�л����,����˼·����log�ŵ�����Ĵ����豸��
prompt Log File Sync:���û�commitʱ���ȴ�����־д���ļ��Ĺ��� ,����˼·:����־�ŵ�����Ĵ����豸��,��������Ա�ŵ���ͬ�Ĵ����豸��
prompt SQL*NET more data from dblink:�ȴ�dblinkԶ�����ݿ������ ,����˼·:dblink���ٶ�̫��
prompt Write Completed:�û���commitʱ�ȴ������޸Ĺ���block
prompt 

PROMPT ���ݿ��г����ȴ��¼���״����
select * from V$SYSTEM_EVENT
where Event in ('buffer busy waits',
'db file sequential read',
'db file scattered read',
'enqueue',
'free buffer waits',
'latch free',
'log file parallel write',
'log file sync')
ORDER BY 4 DESC;

PROMPT 
PROMPT ���ݱ���״����
set head off
set numwidth 10
select '���ݿ��б������Ϊ��'||count(*) tables_total from dba_tables ;
select '�������ı������Ϊ��'||count(*) tables_analyzed from dba_tables where last_analyzed is not null;
select '���һ�η���ʱ��Ϊ��'||to_char(max(last_analyzed),'yyyy-mm-dd hh24:mi:ss')||
chr(10)||' Ӧ�����Ե�ִ��:9i�� exec dbms_stats.gather_schema_stats(''OWNER_NAME'');'||
chr(10)||' <8i�� exec dbms_utility.analyze_schema(''OWNER_NAME'',''compute'');' last_analyzed from dba_tables;
select '�������ı��в�����' from dual;
set head on
column owner format a20
column table_name format a20
select a.owner,a.table_name,a.num_rows,a.chain_cnt,a.tablespace_name from dba_tables a 
where a.num_rows>500 and a.chain_cnt>100;

prompt
prompt �������ݿ��ļ�IO��Ϣ
PROMPT ���ݿ��û�����Ĭ�ϱ�ռ䡢��ʱ��ռ䣺
column username format a30 trunc
column default_tablespace format a30 trunc
column temporary_tablespace format a30 trunc
select a.username,a.default_tablespace,a.temporary_tablespace 
from dba_users a order by a.default_tablespace;

PROMPT 
PROMPT �����ļ���С(M)���ռ������ʣ�
column file_name format a30 
column tablespace_name format a15 
set numwidth 8
select a.file_id file#,a.file_name,
a.total,(a.total-nvl(f.free,0)) used,nvl(f.free,0) free,
round((a.total-nvl(f.free,0))/a.total*100,1) "used%",
round(nvl(f.free,0)/a.total*100,1) "Free%" ,
a.tablespace_name,a.autoextensible,a.status,a.extent_management
from (select tablespace_name,file_name,file_id, round(bytes/1024/1024) total,autoextensible,dba_data_files.status,extent_management
from dba_data_files join dba_tablespaces using (tablespace_name)) a,
(select file_id, round(sum(bytes)/1024/1024) free from dba_free_space group by file_id) f
WHERE a.file_id = f.file_id(+)
order by a.total desc;

PROMPT 
PROMPT ���ݿ��ļ�����Ƭͳ�ƣ�
select TABLESPACE_NAME,
ROUND(SQRT(max(BLOCKS) / sum(BLOCKS)) * (100 / SQRT(SQRT(count(BLOCKS)))), 2) FSFI,
count(BLOCKS),
sum(BLOCKS),
max(BLOCKS)
from SYS.DBA_FREE_SPACE
group by TABLESPACE_NAME
order by 2;

PROMPT 
PROMPT ��ʱ�ļ���
column name format a50
SELECT FILE#,NAME,ROUND(BYTES/1024/1024,3) SIZE_M FROM V$TEMPFILE;

PROMPT 
PROMPT �����ļ���
select name from v$controlfile;
PROMPT 
PROMPT ������־�ļ���
column member format a50
SELECT A.GROUP#, B.MEMBER, A.STATUS, ROUND(A.BYTES / 1024 / 1024) SIZE_M
FROM V$LOG A, V$LOGFILE B
WHERE A.GROUP# = B.GROUP#;

PROMPT 
PROMPT �����ļ�����д����(��ʵ����������)��
column name format a60 trunc
select a.file#,b.name,a.phyrds,a.phywrts from v$filestat a,v$datafile b
where a.file#=b.file# order by 3 desc;


PROMPT 
prompt ��ǰʹ�õ����ݿ��ʼ������:
select rownum,a.* from (select name, value from v$parameter where value is not null order by name) a;
set head off
SELECT 'ע��' || A.VALUE || 'Ŀ¼�µ�alert_' || B.VALUE || '.log�ļ�'
FROM V$PARAMETER A, V$PARAMETER B
WHERE A.NAME = 'background_dump_dest' AND B.NAME = 'db_name';
prompt ************************************
prompt END
prompt ************************************

SPOOL OFF

/*
prompt 
prompt ��ע��schema
column COMMENTS format a40
set numwidth 8
set head on
SELECT A.TABLE_NAME, B.COMMENTS, A.TABLESPACE_NAME, A.NUM_ROWS, A.AVG_ROW_LEN, A.LAST_ANALYZED
FROM DBA_TABLES A, DBA_TAB_COMMENTS B
WHERE A.OWNER = '&��ע��schema' AND A.OWNER = B.OWNER AND A.TABLE_NAME = B.TABLE_NAME
ORDER BY A.NUM_ROWS DESC, A.TABLE_NAME;
prompt 
prompt ��ͼ�������ļ�orcl_info_report_VIEW.txt��

SET LONG 999
SET ECHO OFF FEED OFF HEAD OFF
SPOOL TEMP.SQL
SELECT ' select DBMS_METADATA.get_ddl(''VIEW'','''||A.VIEW_NAME||''',''&��ע��schema'' ) FROM DUAL;' FROM DBA_VIEWS A WHERE A.OWNER='&��ע��schema' ;
SPOOL OFF
SPOOL orcl_info_report_VIEW.txt
prompt 
prompt ��ͼ����
@TEMP.SQL
SPOOL OFF
*/

exit;
