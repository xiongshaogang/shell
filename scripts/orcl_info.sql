/*
功 能: 数据库当前状况报告，生成orcl_info_report.txt文件。
使用方法: sqlplus /nolog @orcl_info.sql 
Created By fanghm
*/

--accept un prompt '用户名：'
--accept pw prompt '密 码：' hide
--accept db prompt '数据库：'
--define 数据库连接串=&un/&pw@&db;
define 数据库连接串=aijs/aijs@zmjs;

--accept 关注的schema prompt '关注的schema：'
--define 关注的schema=AIJS

connect &数据库连接串;
pause 继续吗？
--EXEC DBMS_STATS.gather_schema_stats(upper('&关注的schema'),20);

--set term off 
set echo off feed off head off verify off
set trimspool on
set long 5000
set linesize 200 pagesize 9999
set serveroutput on size 1000000
set numwidth 10

spool orcl_info_report.txt
column rep_name format a80
select 'host='||utl_inaddr.GET_HOST_NAME()||',IP='||utl_inaddr.GET_HOST_ADDRESS()||',DB='||name||chr(13)||'数据库运行报告' rep_name from v$database;
prompt
set head on
select 'Reported by orcl_info.sql On '||
to_char(sysdate,'yyyy-mm-dd HH24:MI:SS')
"报告创建时间：" from dual;

PROMPT
PROMPT *********************************************************
PROMPT ***数据库概况信息： ***
PROMPT *********************************************************
PROMPT
PROMPT 数据库产品版本：
column banner format a75 trunc
select * from v$version;
PROMPT 
prompt 当前实例状态信息：
column instance_name,startup_time,archiver format a20 trunc
column host_name format a20 trunc
column instance_number format 99
select a.instance_name,to_char(a.startup_time,'YYYY-MM-DD HH24:MI:SS') startup_time,a.archiver,a.host_name,a.instance_number 
from v$instance a;

PROMPT 
prompt 当前数据库状态信息：
rem for 8i or after 
select name,to_char(created,'yyyy-mm-dd hh24:mi:ss') created,log_mode ,open_mode from v$database ;
rem for 8 or before
rem ++ select name,to_char(created,'yyyy-mm-dd hh24:mi:ss') created,log_mode from v$database ;

PROMPT 
prompt 连接数信息：
select * from v$license;

PROMPT 
prompt 当前Session信息：
column username format a10 trunc
column osuser format a15 trunc
column machine format a20 
column program format a28
set numwidth 8
SELECT a.SID,a.USERNAME,a.STATUS,a.OSUSER,A.MACHINE,a.PROGRAM,a.LOGON_TIME FROM V$SESSION a 
WHERE a.TYPE='USER' ORDER BY 2;

PROMPT 
prompt 当前DB_job信息：
column LOG_USER format a20 trunc
column SCHEMA_USER format a20 trunc
column INTERVAL format a30 trunc
column what format a50 TRUNC
SELECT A.JOB, A.WHAT, A.LOG_USER, A.SCHEMA_USER, A.LAST_DATE, A.THIS_DATE, A.NEXT_DATE, A.BROKEN, A.INTERVAL, A.FAILURES
FROM DBA_JOBS A;

PROMPT 
PROMPT 占用空间超过10G的实体：
column SEGMENT_NAME format a30 trunc
column partition_name format a30 trunc
SELECT ROUND(SUM(SEG.BYTES / 1024 / 1024), 0) SPACE_M, SEG.OWNER, SEG.SEGMENT_NAME, SEG.partition_name, SEG.SEGMENT_TYPE, SEG.HEADER_FILE
FROM DBA_SEGMENTS SEG
GROUP BY rollup(SEG.OWNER, SEG.SEGMENT_NAME, SEG.partition_name,SEG.SEGMENT_TYPE, SEG.HEADER_FILE )
HAVING SUM(SEG.BYTES) > 1024 * 1024 * 1024 * 10
ORDER BY 1 DESC ;

PROMPT 
PROMPT 请关注以下的SQL语句：
PROMPT 可以使用set autot trace 观看其执行路径
column sql_text format a60
SELECT EXECUTIONS , DISK_READS, BUFFER_GETS,ROUND((BUFFER_GETS-DISK_READS)/BUFFER_GETS,2) Hit_radio,
ROUND(DISK_READS/EXECUTIONS,2) Reads_per_run,SQL_TEXT
FROM V$SQLAREA
WHERE EXECUTIONS>0 AND BUFFER_GETS > 0 AND (BUFFER_GETS-DISK_READS)/BUFFER_GETS < 0.6 
ORDER BY 2 desc;

prompt
prompt 关于数据库内存及命中率信息
prompt SGA空间分配：
set numwidth 10
select * from v$sga;
SELECT pool,name,round(a.bytes/1024/1024,3) VALUE_M FROM v$sgastat a order by 3 DESC;
prompt 
prompt 关于Shared_Pool:
prompt 1.V$LIBRARYCACHE gives the pins/reload ratio for the library cache. The GETHITRATIO 
prompt column should be .95 or higher.
select round(gethitratio*100,2) gethitration from v$librarycache where namespace = 'SQL AREA';
prompt The RELOADS column should be equal to or less than 1% of the PINS column. 
select round(sum(reloads)/sum(pins)*100,2) reloadration from v$librarycache;

prompt 2. The GETMISSES to GETS columns in V$ROWCACHE should have a ratio less than 15% . 
select round(sum(GETMISSES)/sum(GETS)*100,2) getmissration from V$ROWCACHE ;
prompt 
prompt 判断shared_pool是否过大
select pool,name,round(bytes/1024/1024,2) size_M 
from v$sgastat where name = 'free memory';

prompt 
prompt 关于DB_BUFFERS :
prompt 3.The buffer cache hit ratio should be 90% or higher. 
prompt Hit Ratio = 1 – (physical reads/(db block gets + consistent gets)) 
SELECT round(1 - (phy.value / (cur.value + con.value)),4)*100 "CACHEHITRATIO" 
FROM v$sysstat cur, v$sysstat con, v$sysstat phy 
WHERE cur.name = 'db block gets' AND con.name = 'consistent gets' AND phy.name = 'physical reads';
prompt Buffer Hit足够大(>95%)表示命中率较高,否则可以调整数据缓冲区的大小

prompt 
prompt 判断DB_BUFFERS的空闭区（以sysdba身份查看）
prompt select decode(state,0,'Free',1,'Read and Modified',2,'Read and not Modified',3,'Currently Being READ','Other') state, count(*) count from x$bh group by state;
--select decode(state,0,'Free',1,'Read and Modified',2,'Read and not Modified',3,'Currently Being READ','Other') state, count(*) count from x$bh group by state;
prompt 
prompt About Sort_Area_Size:
SELECT a.VALUE "sorts(memory)",b.VALUE "sorts(disk)" FROM v$sysstat a,v$sysstat b 
WHERE a.NAME='sorts (memory)' and b.NAME='sorts (disk)';
prompt In-memory Sort数字大(>95%)表示大部分数据在内存中进行排序,否则调整sort_area_size的值，或pga_aggregate_target的值
prompt 
prompt About PGA_Size:
SELECT NAME,round(VALUE/1024/1024,2) size_M FROM v$pgastat;
prompt 
prompt 内存参数设置参考(9i spfile启动,1Gmem,--2Gmem)：
prompt alter system set sga_max_size=800m scope=spfile; --1600m
prompt alter system set db_cache_size=480m;--1280m
prompt alter system set db_keep_cache_size=64m;--64m
prompt alter system set shared_pool_size=160m;--240m
prompt alter system set pga_aggregate_target=64m;--64m
prompt 必要时可考虑将某应用模式对象完全缓冲
prompt SELECT 'alter table '||OWNER||'.'||table_name||' STORAGE(BUFFER_POOL KEEP);' FROM dba_tables WHERE owner='GRAINTEST'
prompt SELECT 'select /*+FULL(A)*/ count(*) from '||OWNER||'.'||table_name||' A;' FROM dba_tables WHERE owner='GRAINTEST'

PROMPT 
prompt 关注的初始化参数:
column name format a40 trunc
column value format a70 
select name, value from v$parameter where name in ('aq_tm_processes','bitmap_merge_area_size',
'compatible','cpu_count','create_bitmap_area_size','cursor_sharing','db_cache_advice','db_cache_size',
'db_keep_cache_size','db_recycle_cache_size','dispatchers','global_names','hash_area_size',
'hash_join_enabled','java_pool_size','large_pool_size','log_buffer','optimizer_mode',
'pga_aggregate_target','processes','query_rewrite_enabled','sga_max_size','shared_pool_size',
'shared_servers','sort_area_size','timed_statistics','workarea_size_policy');

PROMPT 
PROMPT 数据库中等待事件(前10位)的状况：
column event format a30 
select * from (select * from V$SYSTEM_EVENT order by 4 desc) where rownum<=10;
prompt 
prompt Buffer Busy Wait:访问的块正在读取中,其他他进程正在将数据读到Cache中,访问的块正在修改中,其他进程正在修改Cache中的数据,调整思路：将数据文件放在读取速度更快的设备上
prompt Checkpoint Completed:等待Checkpoint操作结束,调整思路：减小一些log buffer的大小,增加Checkpoint的频率,将log文件放在更快的设备上,如RAID
prompt Control File Parallel Write:等待向所有的控制文件写数据,调整思路：减少control file的个数,将不同control file分布到不同的磁盘驱动器
prompt Control File Sequential Read :从Control File中读取信息,调整思路：将Control File放在比较空闲的磁盘上,将Control File放在速度更快的磁盘上
prompt DB File Parallel Read:一般在并行恢复时发生,调整思路：调整文件在不同磁盘驱动上的分布,选用访问速度更快的磁盘
prompt DB File Parallel Write:DBWn进程将数据写入数据文件,调整思路：调整文件在多个磁盘控制器之间的分布,采用条带化技术，提高写速度。
prompt DB File Scattered Read:读取大量的数据块到Cache中,调整思路：调整大表上的索引,收集更集统计信息
prompt DB File Sequential Read:一般指读取索引的数据,调整思路：调整索引的设计,Rebuild索引，提高索引效率
prompt Direct Path Read:指直接从文件中读取，主要发生在检查Direct Path Writer写是否完成,调整思路：调整文件分布,选用更快的磁盘设备
prompt Direct Path Write:直接向数据文件写数据，发生在Direct Insert中 Insert /*+ append */ … sqlldr中设置direct=true ,调整思路：调整文件分布,选用更快的磁盘设备
prompt Enqueue:Emqueue是Oracle内部的一种锁，用来进行串行操作,调整思路：增大enqueue_resources参数
prompt Free Buffer Wait:寻找可用Cache块，如大量的数据被修改，或没有可用的空闲块,调整思路:增加db_block_buffers或db_cache_size的值
prompt Log Buffer Space:生成日志的速度大于将日志写到磁盘的速度,调整思路:增加log_buffer的值,将log文件放到空闲的磁盘设备上
prompt Log File Parallel Write:等待log写操作结束，如日志组有的成员在快的设备上，有的在慢的设备上,调整思路:将log的成员分布到不同的磁盘上,用更快的磁盘设备
prompt Log File Switch (…):Archiving needed 等待归档完成,调整思路：增加log_archive_processes的数量,Checkpoint not completed 等待切换到下一个日志,调整思路：增加日志组的数据，调整大小, Completion 等待日志切换完成,调整思路：将log放到更快的磁盘设备上
prompt Log File Sync:在用户commit时，等待将日志写入文件的过程 ,调整思路:将日志放到更快的磁盘设备上,将各个成员放到不同的磁盘设备上
prompt SQL*NET more data from dblink:等待dblink远程数据库的数据 ,调整思路:dblink的速度太慢
prompt Write Completed:用户在commit时等待保存修改过的block
prompt 

PROMPT 数据库中常见等待事件的状况：
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
PROMPT 数据表健康状况：
set head off
set numwidth 10
select '数据库中表的总数为：'||count(*) tables_total from dba_tables ;
select '分析过的表的总数为：'||count(*) tables_analyzed from dba_tables where last_analyzed is not null;
select '最后一次分析时间为：'||to_char(max(last_analyzed),'yyyy-mm-dd hh24:mi:ss')||
chr(10)||' 应周期性地执行:9i下 exec dbms_stats.gather_schema_stats(''OWNER_NAME'');'||
chr(10)||' <8i下 exec dbms_utility.analyze_schema(''OWNER_NAME'',''compute'');' last_analyzed from dba_tables;
select '分析过的表中不良表：' from dual;
set head on
column owner format a20
column table_name format a20
select a.owner,a.table_name,a.num_rows,a.chain_cnt,a.tablespace_name from dba_tables a 
where a.num_rows>500 and a.chain_cnt>100;

prompt
prompt 关于数据库文件IO信息
PROMPT 数据库用户及其默认表空间、临时表空间：
column username format a30 trunc
column default_tablespace format a30 trunc
column temporary_tablespace format a30 trunc
select a.username,a.default_tablespace,a.temporary_tablespace 
from dba_users a order by a.default_tablespace;

PROMPT 
PROMPT 数据文件大小(M)及空间利用率：
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
PROMPT 数据库文件的碎片统计：
select TABLESPACE_NAME,
ROUND(SQRT(max(BLOCKS) / sum(BLOCKS)) * (100 / SQRT(SQRT(count(BLOCKS)))), 2) FSFI,
count(BLOCKS),
sum(BLOCKS),
max(BLOCKS)
from SYS.DBA_FREE_SPACE
group by TABLESPACE_NAME
order by 2;

PROMPT 
PROMPT 临时文件：
column name format a50
SELECT FILE#,NAME,ROUND(BYTES/1024/1024,3) SIZE_M FROM V$TEMPFILE;

PROMPT 
PROMPT 控制文件：
select name from v$controlfile;
PROMPT 
PROMPT 联机日志文件：
column member format a50
SELECT A.GROUP#, B.MEMBER, A.STATUS, ROUND(A.BYTES / 1024 / 1024) SIZE_M
FROM V$LOG A, V$LOGFILE B
WHERE A.GROUP# = B.GROUP#;

PROMPT 
PROMPT 数据文件读、写次数(自实例启动以来)：
column name format a60 trunc
select a.file#,b.name,a.phyrds,a.phywrts from v$filestat a,v$datafile b
where a.file#=b.file# order by 3 desc;


PROMPT 
prompt 当前使用的数据库初始化参数:
select rownum,a.* from (select name, value from v$parameter where value is not null order by name) a;
set head off
SELECT '注意' || A.VALUE || '目录下的alert_' || B.VALUE || '.log文件'
FROM V$PARAMETER A, V$PARAMETER B
WHERE A.NAME = 'background_dump_dest' AND B.NAME = 'db_name';
prompt ************************************
prompt END
prompt ************************************

SPOOL OFF

/*
prompt 
prompt 关注的schema
column COMMENTS format a40
set numwidth 8
set head on
SELECT A.TABLE_NAME, B.COMMENTS, A.TABLESPACE_NAME, A.NUM_ROWS, A.AVG_ROW_LEN, A.LAST_ANALYZED
FROM DBA_TABLES A, DBA_TAB_COMMENTS B
WHERE A.OWNER = '&关注的schema' AND A.OWNER = B.OWNER AND A.TABLE_NAME = B.TABLE_NAME
ORDER BY A.NUM_ROWS DESC, A.TABLE_NAME;
prompt 
prompt 视图定义在文件orcl_info_report_VIEW.txt中

SET LONG 999
SET ECHO OFF FEED OFF HEAD OFF
SPOOL TEMP.SQL
SELECT ' select DBMS_METADATA.get_ddl(''VIEW'','''||A.VIEW_NAME||''',''&关注的schema'' ) FROM DUAL;' FROM DBA_VIEWS A WHERE A.OWNER='&关注的schema' ;
SPOOL OFF
SPOOL orcl_info_report_VIEW.txt
prompt 
prompt 视图定义
@TEMP.SQL
SPOOL OFF
*/

exit;
