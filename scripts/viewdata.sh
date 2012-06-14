#!/bin/sh
# to re-generate this script, run viewdata.sql and spool the result in sqlplus and eddit it

# SQL> @/data4/showwjdata.sql
# SQL> rem sql script to show gateway voice/sms process info.
# SQL> rem author: fanghm@aisinfo.com
# SQL> 
# SQL> set echo off
# 
# ���ڶ� 7��  04                                                                                                                               page    1
echo "==================== Gateway Voice/SMS Data Process Info ===================="
echo
echo "    ģ���     ģ����             ģ�����              ·��        �ļ�����"                               
echo "---------- --------------------  -------------------  -----------  --------"
echo "           /data4/pickup/prov     pickup               inputPath  :\t\c"; l /data4/pickup/prov |wc -w                        
echo "    100451 �ɼ�_����_��Ϊ         ftp_hw               localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/huawei        |wc -w                        
echo "           �ɼ�_����_��Ϊ         ftp_hw               logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/huawei                |wc -w                        
echo "           �ɼ�_����_��Ϊ         ftp_hw               tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/huawei               |wc -w                        
echo
echo "    100452 �ɼ�_����_ŵ����       ftp_nokia            localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/nokia         |wc -w                        
echo "           �ɼ�_����_ŵ����       ftp_nokia            logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/nokia                 |wc -w                        
echo "           �ɼ�_����_ŵ����       ftp_nokia            tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/nokia                |wc -w                        
echo
echo "    100453 �ɼ�_����_��������     ftp_alcatel          localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/alcatel       |wc -w                        
echo "           �ɼ�_����_��������     ftp_alcatel          logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/alcatel               |wc -w                        
echo "           �ɼ�_����_��������     ftp_alcatel          tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/alcatel              |wc -w                        
echo
echo "    110411 Ԥ����_����_����       prep_sms             dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/sms                          |wc -w                        
echo "           Ԥ����_����_����       prep_sms             errorPath  :\t\c"; l /data2/wj/center/error/format/wj/sms                        |wc -w                        
echo "           Ԥ����_����_����       prep_sms             finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/sms                  |wc -w                        
echo "           Ԥ����_����_����       prep_sms             inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/sms                 |wc -w                        
echo "           Ԥ����_����_����       prep_sms             logPath    :\t\c"; l /data2/wj/center/log/format/wj/sms                          |wc -w                        
echo "           Ԥ����_����_����       prep_sms             outputPath :\t\c"; l /data2/wj/center/temp/format/wj/sms                         |wc -w                        
echo
echo "    110451 Ԥ����_����_��Ϊ       prep_hw              dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/huawei                 |wc -w                        
echo "           Ԥ����_����_��Ϊ       prep_hw              errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/huawei               |wc -w                        
echo "           Ԥ����_����_��Ϊ       prep_hw              finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           Ԥ����_����_��Ϊ       prep_hw              inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/huawei        |wc -w                        
echo "           Ԥ����_����_��Ϊ       prep_hw              logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/huawei                 |wc -w                        
echo "           Ԥ����_����_��Ϊ       prep_hw              outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/huawei                |wc -w                        
echo
echo "    110452 Ԥ����_����_ŵ����     prep_nokia           dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/nokia                  |wc -w                        
echo "           Ԥ����_����_ŵ����     prep_nokia           errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/nokia                |wc -w                        
echo "           Ԥ����_����_ŵ����     prep_nokia           finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/nokia          |wc -w                        
echo "           Ԥ����_����_ŵ����     prep_nokia           inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/nokia         |wc -w                        
echo "           Ԥ����_����_ŵ����     prep_nokia           logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/nokia                  |wc -w                        
echo "           Ԥ����_����_ŵ����     prep_nokia           outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/nokia                 |wc -w                        
echo
echo "    110453 Ԥ����_����_��������   prep_alcatel         dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/alcatel                |wc -w                        
echo "           Ԥ����_����_��������   prep_alcatel         errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/alcatel              |wc -w                        
echo "           Ԥ����_����_��������   prep_alcatel         finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           Ԥ����_����_��������   prep_alcatel         inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/alcatel       |wc -w                        
echo "           Ԥ����_����_��������   prep_alcatel         logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/alcatel                |wc -w                        
echo "           Ԥ����_����_��������   prep_alcatel         outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/alcatel               |wc -w                        
echo
echo "    120411 ����_����_����         settle_sms           backupPath :\t\c"; l /data2/wj/center/back/settle/wj/sms                         |wc -w                        
echo "           ����_����_����         settle_sms           errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/sms                        |wc -w                        
echo "           ����_����_����         settle_sms           inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/sms                  |wc -w                        
echo "           ����_����_����         settle_sms           logPath    :\t\c"; l /data2/wj/center/log/settle/wj/sms                          |wc -w                        
echo "           ����_����_����         settle_sms           outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/sms                  |wc -w                        
echo
echo "    120451 ����_����_��Ϊ         settle_hw            backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/huawei                |wc -w                        
echo "           ����_����_��Ϊ         settle_hw            errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/huawei               |wc -w                        
echo "           ����_����_��Ϊ         settle_hw            inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           ����_����_��Ϊ         settle_hw            logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/huawei                 |wc -w                        
echo "           ����_����_��Ϊ         settle_hw            outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo
echo "    120452 ����_����_ŵ����       settle_nokia         backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/nokia                 |wc -w                        
echo "           ����_����_ŵ����       settle_nokia         errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/nokia                |wc -w                        
echo "           ����_����_ŵ����       settle_nokia         inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/nokia          |wc -w                        
echo "           ����_����_ŵ����       settle_nokia         logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/nokia                  |wc -w                        
echo "           ����_����_ŵ����       settle_nokia         outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/nokia          |wc -w                        
echo
echo "    120453 ����_����_��������     settle_alcatel       backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/alcatel               |wc -w                        
echo "           ����_����_��������     settle_alcatel       errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/alcatel              |wc -w                        
echo "           ����_����_��������     settle_alcatel       inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           ����_����_��������     settle_alcatel       logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/alcatel                |wc -w                        
echo "           ����_����_��������     settle_alcatel       outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo
echo "    120454 ����_����_��������2    settle_alcatel2      backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/alcatel               |wc -w                        
echo "           ����_����_��������2    settle_alcatel2      errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/alcatel              |wc -w                        
echo "           ����_����_��������2    settle_alcatel2      inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           ����_����_��������2    settle_alcatel2      logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/alcatel                |wc -w                        
echo "           ����_����_��������2    settle_alcatel2      outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo
echo "    120455 ����_����_��Ϊ2        settle_hw2           backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/huawei                |wc -w                        
echo "           ����_����_��Ϊ2        settle_hw2           errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/huawei               |wc -w                        
echo "           ����_����_��Ϊ2        settle_hw2           inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           ����_����_��Ϊ2        settle_hw2           logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/huawei                 |wc -w                        
echo "           ����_����_��Ϊ2        settle_hw2           outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo
echo "    130411 ����_����_����         stat_sms             backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/sms                    |wc -w                        
echo "           ����_����_����         stat_sms             errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/sms                          |wc -w                        
echo "           ����_����_����         stat_sms             inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/sms                  |wc -w                        
echo "           ����_����_����         stat_sms             logPath    :\t\c"; l /data2/wj/center/log/stat/wj/sms                            |wc -w                        
echo "           ����_����_����         stat_sms             outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/sms                |wc -w                        
echo "           ����_����_����         stat_sms             skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/sms                      |wc -w                        
echo
echo "    130451 ����_����_��Ϊ         hw_stat              backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/huawei           |wc -w                        
echo "           ����_����_��Ϊ         hw_stat              errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/huawei                 |wc -w                        
echo "           ����_����_��Ϊ         hw_stat              inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo "           ����_����_��Ϊ         hw_stat              logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/huawei                   |wc -w                        
echo "           ����_����_��Ϊ         hw_stat              outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/huawei       |wc -w                        
echo "           ����_����_��Ϊ         hw_stat              skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/huawei             |wc -w                        
echo
echo "    130453 ����_����_ŵ����       nokia_stat           backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/nokia            |wc -w                        
echo "           ����_����_ŵ����       nokia_stat           errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/nokia                  |wc -w                        
echo "           ����_����_ŵ����       nokia_stat           inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/nokia          |wc -w                        
echo "           ����_����_ŵ����       nokia_stat           logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/nokia                    |wc -w                        
echo "           ����_����_ŵ����       nokia_stat           outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/nokia        |wc -w                        
echo "           ����_����_ŵ����       nokia_stat           skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/nokia              |wc -w                        
echo
echo "    130455 ����_����_��������     alcatel_stat         backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/alcatel          |wc -w                        
echo "           ����_����_��������     alcatel_stat         errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/alcatel                |wc -w                        
echo "           ����_����_��������     alcatel_stat         inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo "           ����_����_��������     alcatel_stat         logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/alcatel                  |wc -w                        
echo "           ����_����_��������     alcatel_stat         outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/alcatel      |wc -w                        
echo "           ����_����_��������     alcatel_stat         skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/alcatel            |wc -w                        
echo
echo "    140412 �ջ���_����_����       sms_day_stat         backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/sms            |wc -w                        
echo "           �ջ���_����_����       sms_day_stat         errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/sms                       |wc -w                        
echo "           �ջ���_����_����       sms_day_stat         inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/sms/3              |wc -w                        
echo "           �ջ���_����_����       sms_day_stat         logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/sms                         |wc -w                        
echo "           �ջ���_����_����       sms_day_stat         outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/sms                 |wc -w                        
echo "           �ջ���_����_����       sms_day_stat         skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/sms                   |wc -w                        
echo
echo "    140452 �ջ���_����_��Ϊ       hw_day_stat          backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/huawei   |wc -w                        
echo "           �ջ���_����_��Ϊ       hw_day_stat          errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/huawei              |wc -w                        
echo "           �ջ���_����_��Ϊ       hw_day_stat          inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/huawei/1     |wc -w                        
echo "           �ջ���_����_��Ϊ       hw_day_stat          logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/huawei                |wc -w                        
echo "           �ջ���_����_��Ϊ       hw_day_stat          outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/huawei        |wc -w                        
echo "           �ջ���_����_��Ϊ       hw_day_stat          skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/huawei          |wc -w                        
echo
echo "    140454 �ջ���_����_ŵ����     nokia_day_stat       backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/nokia    |wc -w                        
echo "           �ջ���_����_ŵ����     nokia_day_stat       errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/nokia               |wc -w                        
echo "           �ջ���_����_ŵ����     nokia_day_stat       inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/nokia/1      |wc -w                        
echo "           �ջ���_����_ŵ����     nokia_day_stat       logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/nokia                 |wc -w                        
echo "           �ջ���_����_ŵ����     nokia_day_stat       outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/nokia         |wc -w                        
echo "           �ջ���_����_ŵ����     nokia_day_stat       skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/nokia           |wc -w                        
echo
echo "    140456 �ջ���_����_��������   alcatel_day_stat     backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/alcatel  |wc -w                        
echo "           �ջ���_����_��������   alcatel_day_stat     errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/alcatel             |wc -w                        
echo "           �ջ���_����_��������   alcatel_day_stat     inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/alcatel/1    |wc -w                        
echo "           �ջ���_����_��������   alcatel_day_stat     logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/alcatel               |wc -w                        
echo "           �ջ���_����_��������   alcatel_day_stat     outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/alcatel       |wc -w                        
echo "           �ջ���_����_��������   alcatel_day_stat     skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/alcatel         |wc -w                        
echo
echo "    150411 �����嵥_����_����     ldrmain_sms_data     backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/sms                 |wc -w                        
echo "           �����嵥_����_����     ldrmain_sms_data     errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/sms                    |wc -w                        
echo "           �����嵥_����_����     ldrmain_sms_data     inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/sms                    |wc -w                        
echo "           �����嵥_����_����     ldrmain_sms_data     logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/sms                      |wc -w                        
echo "           �����嵥_����_����     ldrmain_sms_data     outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/sms              |wc -w                        
echo "           �����嵥_����_����     ldrmain_sms_data     tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/sms                     |wc -w                        
echo
echo "    150451 �����嵥_����_��Ϊ     ldr_huawei           backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/huawei        |wc -w                        
echo "           �����嵥_����_��Ϊ     ldr_huawei           errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/huawei           |wc -w                        
echo "           �����嵥_����_��Ϊ     ldr_huawei           inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/huawei           |wc -w                        
echo "           �����嵥_����_��Ϊ     ldr_huawei           logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/huawei             |wc -w                        
echo "           �����嵥_����_��Ϊ     ldr_huawei           outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/huawei     |wc -w                        
echo "           �����嵥_����_��Ϊ     ldr_huawei           tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/huawei            |wc -w                        
echo
echo "    150453 �����嵥_����_ŵ����   ldr_nokia            backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/nokia         |wc -w                        
echo "           �����嵥_����_ŵ����   ldr_nokia            errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/nokia            |wc -w                        
echo "           �����嵥_����_ŵ����   ldr_nokia            inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/nokia            |wc -w                        
echo "           �����嵥_����_ŵ����   ldr_nokia            logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/nokia              |wc -w                        
echo "           �����嵥_����_ŵ����   ldr_nokia            outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/nokia      |wc -w                        
echo "           �����嵥_����_ŵ����   ldr_nokia            tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/nokia             |wc -w                        
echo
echo "    150455 �����嵥_����_�������� ldr_alcatel          backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/alcatel       |wc -w                        
echo "           �����嵥_����_�������� ldr_alcatel          errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/alcatel          |wc -w                        
echo "           �����嵥_����_�������� ldr_alcatel          inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/alcatel          |wc -w                        
echo "           �����嵥_����_�������� ldr_alcatel          logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/alcatel            |wc -w                        
echo "           �����嵥_����_�������� ldr_alcatel          outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/alcatel    |wc -w                        
echo "           �����嵥_����_�������� ldr_alcatel          tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/alcatel           |wc -w                        
echo
echo "    160412 �����ʵ�_����_����     ldrmain_sms_day_stat backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/sms                |wc -w                        
echo "           �����ʵ�_����_����     ldrmain_sms_day_stat errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/sms                 |wc -w                        
echo "           �����ʵ�_����_����     ldrmain_sms_day_stat inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/sms/4          |wc -w                        
echo "           �����ʵ�_����_����     ldrmain_sms_day_stat logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/sms                   |wc -w                        
echo "           �����ʵ�_����_����     ldrmain_sms_day_stat outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/sms           |wc -w                        
echo "           �����ʵ�_����_����     ldrmain_sms_day_stat tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/sms                  |wc -w                        
echo
echo "    160452 �����ʵ�_����_��Ϊ     ldr_stat_huawei      backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/huawei       |wc -w                        
echo "           �����ʵ�_����_��Ϊ     ldr_stat_huawei      errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/huawei        |wc -w                        
echo "           �����ʵ�_����_��Ϊ     ldr_stat_huawei      inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/huawei/2 |wc -w                        
echo "           �����ʵ�_����_��Ϊ     ldr_stat_huawei      logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/huawei          |wc -w                        
echo "           �����ʵ�_����_��Ϊ     ldr_stat_huawei      outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/huawei  |wc -w                        
echo "           �����ʵ�_����_��Ϊ     ldr_stat_huawei      tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/huawei         |wc -w                        
echo
echo "    160454 �����ʵ�_����_ŵ����   ldr_stat_nokia       backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/nokia        |wc -w                        
echo "           �����ʵ�_����_ŵ����   ldr_stat_nokia       errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/nokia         |wc -w                        
echo "           �����ʵ�_����_ŵ����   ldr_stat_nokia       inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/nokia/2  |wc -w                        
echo "           �����ʵ�_����_ŵ����   ldr_stat_nokia       logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/nokia           |wc -w                        
echo "           �����ʵ�_����_ŵ����   ldr_stat_nokia       outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/nokia   |wc -w                        
echo "           �����ʵ�_����_ŵ����   ldr_stat_nokia       tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/nokia          |wc -w                        
echo
echo "    160456 �����ʵ�_����_�������� ldr_stat_alcatel     backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/alcatel      |wc -w                        
echo "           �����ʵ�_����_�������� ldr_stat_alcatel     errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/alcatel       |wc -w                        
echo "           �����ʵ�_����_�������� ldr_stat_alcatel     inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/alcatel/2|wc -w                        
echo "           �����ʵ�_����_�������� ldr_stat_alcatel     logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/alcatel         |wc -w                        
echo "           �����ʵ�_����_�������� ldr_stat_alcatel     outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/alcatel |wc -w                        
echo "           �����ʵ�_����_�������� ldr_stat_alcatel     tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/alcatel        |wc -w                        
