#!/bin/sh
# to re-generate this script, run viewdata.sql and spool the result in sqlplus and eddit it

# SQL> @/data4/showwjdata.sql
# SQL> rem sql script to show gateway voice/sms process info.
# SQL> rem author: fanghm@aisinfo.com
# SQL> 
# SQL> set echo off
# 
# 星期二 7月  04                                                                                                                               page    1
echo "==================== Gateway Voice/SMS Data Process Info ===================="
echo
echo "    模块号     模块名             模块代码              路径        文件数量"                               
echo "---------- --------------------  -------------------  -----------  --------"
echo "           /data4/pickup/prov     pickup               inputPath  :\t\c"; l /data4/pickup/prov |wc -w                        
echo "    100451 采集_网间_华为         ftp_hw               localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/huawei        |wc -w                        
echo "           采集_网间_华为         ftp_hw               logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/huawei                |wc -w                        
echo "           采集_网间_华为         ftp_hw               tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/huawei               |wc -w                        
echo
echo "    100452 采集_网间_诺基亚       ftp_nokia            localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/nokia         |wc -w                        
echo "           采集_网间_诺基亚       ftp_nokia            logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/nokia                 |wc -w                        
echo "           采集_网间_诺基亚       ftp_nokia            tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/nokia                |wc -w                        
echo
echo "    100453 采集_网间_阿尔卡特     ftp_alcatel          localPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/alcatel       |wc -w                        
echo "           采集_网间_阿尔卡特     ftp_alcatel          logPath    :\t\c"; l /data2/wj/center/log/acquire/wj/voice/alcatel               |wc -w                        
echo "           采集_网间_阿尔卡特     ftp_alcatel          tempPath   :\t\c"; l /data2/wj/center/temp/acquire/wj/voice/alcatel              |wc -w                        
echo
echo "    110411 预处理_网间_短信       prep_sms             dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/sms                          |wc -w                        
echo "           预处理_网间_短信       prep_sms             errorPath  :\t\c"; l /data2/wj/center/error/format/wj/sms                        |wc -w                        
echo "           预处理_网间_短信       prep_sms             finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/sms                  |wc -w                        
echo "           预处理_网间_短信       prep_sms             inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/sms                 |wc -w                        
echo "           预处理_网间_短信       prep_sms             logPath    :\t\c"; l /data2/wj/center/log/format/wj/sms                          |wc -w                        
echo "           预处理_网间_短信       prep_sms             outputPath :\t\c"; l /data2/wj/center/temp/format/wj/sms                         |wc -w                        
echo
echo "    110451 预处理_网间_华为       prep_hw              dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/huawei                 |wc -w                        
echo "           预处理_网间_华为       prep_hw              errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/huawei               |wc -w                        
echo "           预处理_网间_华为       prep_hw              finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           预处理_网间_华为       prep_hw              inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/huawei        |wc -w                        
echo "           预处理_网间_华为       prep_hw              logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/huawei                 |wc -w                        
echo "           预处理_网间_华为       prep_hw              outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/huawei                |wc -w                        
echo
echo "    110452 预处理_网间_诺基亚     prep_nokia           dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/nokia                  |wc -w                        
echo "           预处理_网间_诺基亚     prep_nokia           errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/nokia                |wc -w                        
echo "           预处理_网间_诺基亚     prep_nokia           finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/nokia          |wc -w                        
echo "           预处理_网间_诺基亚     prep_nokia           inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/nokia         |wc -w                        
echo "           预处理_网间_诺基亚     prep_nokia           logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/nokia                  |wc -w                        
echo "           预处理_网间_诺基亚     prep_nokia           outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/nokia                 |wc -w                        
echo
echo "    110453 预处理_网间_阿尔卡特   prep_alcatel         dupPath    :\t\c"; l /data2/wj/center/dup/format/wj/voice/alcatel                |wc -w                        
echo "           预处理_网间_阿尔卡特   prep_alcatel         errorPath  :\t\c"; l /data2/wj/center/error/format/wj/voice/alcatel              |wc -w                        
echo "           预处理_网间_阿尔卡特   prep_alcatel         finalPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           预处理_网间_阿尔卡特   prep_alcatel         inputPath  :\t\c"; l /data2/wj/center/data/acquire/output/wj/voice/alcatel       |wc -w                        
echo "           预处理_网间_阿尔卡特   prep_alcatel         logPath    :\t\c"; l /data2/wj/center/log/format/wj/voice/alcatel                |wc -w                        
echo "           预处理_网间_阿尔卡特   prep_alcatel         outputPath :\t\c"; l /data2/wj/center/temp/format/wj/voice/alcatel               |wc -w                        
echo
echo "    120411 分析_网间_短信         settle_sms           backupPath :\t\c"; l /data2/wj/center/back/settle/wj/sms                         |wc -w                        
echo "           分析_网间_短信         settle_sms           errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/sms                        |wc -w                        
echo "           分析_网间_短信         settle_sms           inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/sms                  |wc -w                        
echo "           分析_网间_短信         settle_sms           logPath    :\t\c"; l /data2/wj/center/log/settle/wj/sms                          |wc -w                        
echo "           分析_网间_短信         settle_sms           outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/sms                  |wc -w                        
echo
echo "    120451 分析_网间_华为         settle_hw            backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/huawei                |wc -w                        
echo "           分析_网间_华为         settle_hw            errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/huawei               |wc -w                        
echo "           分析_网间_华为         settle_hw            inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           分析_网间_华为         settle_hw            logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/huawei                 |wc -w                        
echo "           分析_网间_华为         settle_hw            outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo
echo "    120452 分析_网间_诺基亚       settle_nokia         backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/nokia                 |wc -w                        
echo "           分析_网间_诺基亚       settle_nokia         errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/nokia                |wc -w                        
echo "           分析_网间_诺基亚       settle_nokia         inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/nokia          |wc -w                        
echo "           分析_网间_诺基亚       settle_nokia         logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/nokia                  |wc -w                        
echo "           分析_网间_诺基亚       settle_nokia         outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/nokia          |wc -w                        
echo
echo "    120453 分析_网间_阿尔卡特     settle_alcatel       backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/alcatel               |wc -w                        
echo "           分析_网间_阿尔卡特     settle_alcatel       errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/alcatel              |wc -w                        
echo "           分析_网间_阿尔卡特     settle_alcatel       inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           分析_网间_阿尔卡特     settle_alcatel       logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/alcatel                |wc -w                        
echo "           分析_网间_阿尔卡特     settle_alcatel       outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo
echo "    120454 分析_网间_阿尔卡特2    settle_alcatel2      backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/alcatel               |wc -w                        
echo "           分析_网间_阿尔卡特2    settle_alcatel2      errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/alcatel              |wc -w                        
echo "           分析_网间_阿尔卡特2    settle_alcatel2      inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/alcatel        |wc -w                        
echo "           分析_网间_阿尔卡特2    settle_alcatel2      logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/alcatel                |wc -w                        
echo "           分析_网间_阿尔卡特2    settle_alcatel2      outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo
echo "    120455 分析_网间_华为2        settle_hw2           backupPath :\t\c"; l /data2/wj/center/back/settle/wj/voice/huawei                |wc -w                        
echo "           分析_网间_华为2        settle_hw2           errorPath  :\t\c"; l /data2/wj/center/error/settle/wj/voice/huawei               |wc -w                        
echo "           分析_网间_华为2        settle_hw2           inputPath  :\t\c"; l /data2/wj/center/data/format/output/wj/voice/huawei         |wc -w                        
echo "           分析_网间_华为2        settle_hw2           logPath    :\t\c"; l /data2/wj/center/log/settle/wj/voice/huawei                 |wc -w                        
echo "           分析_网间_华为2        settle_hw2           outputPath :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo
echo "    130411 汇总_网间_短信         stat_sms             backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/sms                    |wc -w                        
echo "           汇总_网间_短信         stat_sms             errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/sms                          |wc -w                        
echo "           汇总_网间_短信         stat_sms             inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/sms                  |wc -w                        
echo "           汇总_网间_短信         stat_sms             logPath    :\t\c"; l /data2/wj/center/log/stat/wj/sms                            |wc -w                        
echo "           汇总_网间_短信         stat_sms             outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/sms                |wc -w                        
echo "           汇总_网间_短信         stat_sms             skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/sms                      |wc -w                        
echo
echo "    130451 汇总_网间_华为         hw_stat              backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/huawei           |wc -w                        
echo "           汇总_网间_华为         hw_stat              errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/huawei                 |wc -w                        
echo "           汇总_网间_华为         hw_stat              inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/huawei         |wc -w                        
echo "           汇总_网间_华为         hw_stat              logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/huawei                   |wc -w                        
echo "           汇总_网间_华为         hw_stat              outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/huawei       |wc -w                        
echo "           汇总_网间_华为         hw_stat              skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/huawei             |wc -w                        
echo
echo "    130453 汇总_网间_诺基亚       nokia_stat           backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/nokia            |wc -w                        
echo "           汇总_网间_诺基亚       nokia_stat           errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/nokia                  |wc -w                        
echo "           汇总_网间_诺基亚       nokia_stat           inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/nokia          |wc -w                        
echo "           汇总_网间_诺基亚       nokia_stat           logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/nokia                    |wc -w                        
echo "           汇总_网间_诺基亚       nokia_stat           outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/nokia        |wc -w                        
echo "           汇总_网间_诺基亚       nokia_stat           skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/nokia              |wc -w                        
echo
echo "    130455 汇总_网间_阿尔卡特     alcatel_stat         backupPath :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/alcatel          |wc -w                        
echo "           汇总_网间_阿尔卡特     alcatel_stat         errorPath  :\t\c"; l /data2/wj/center/error/stat/wj/voice/alcatel                |wc -w                        
echo "           汇总_网间_阿尔卡特     alcatel_stat         inputPath  :\t\c"; l /data2/wj/center/data/settle/output/wj/voice/alcatel        |wc -w                        
echo "           汇总_网间_阿尔卡特     alcatel_stat         logPath    :\t\c"; l /data2/wj/center/log/stat/wj/voice/alcatel                  |wc -w                        
echo "           汇总_网间_阿尔卡特     alcatel_stat         outputPath :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/alcatel      |wc -w                        
echo "           汇总_网间_阿尔卡特     alcatel_stat         skipPath   :\t\c"; l /data2/wj/center/data/stat/skip/wj/voice/alcatel            |wc -w                        
echo
echo "    140412 日汇总_网间_短信       sms_day_stat         backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/sms            |wc -w                        
echo "           日汇总_网间_短信       sms_day_stat         errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/sms                       |wc -w                        
echo "           日汇总_网间_短信       sms_day_stat         inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/sms/3              |wc -w                        
echo "           日汇总_网间_短信       sms_day_stat         logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/sms                         |wc -w                        
echo "           日汇总_网间_短信       sms_day_stat         outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/sms                 |wc -w                        
echo "           日汇总_网间_短信       sms_day_stat         skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/sms                   |wc -w                        
echo
echo "    140452 日汇总_网间_华为       hw_day_stat          backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/huawei   |wc -w                        
echo "           日汇总_网间_华为       hw_day_stat          errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/huawei              |wc -w                        
echo "           日汇总_网间_华为       hw_day_stat          inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/huawei/1     |wc -w                        
echo "           日汇总_网间_华为       hw_day_stat          logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/huawei                |wc -w                        
echo "           日汇总_网间_华为       hw_day_stat          outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/huawei        |wc -w                        
echo "           日汇总_网间_华为       hw_day_stat          skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/huawei          |wc -w                        
echo
echo "    140454 日汇总_网间_诺基亚     nokia_day_stat       backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/nokia    |wc -w                        
echo "           日汇总_网间_诺基亚     nokia_day_stat       errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/nokia               |wc -w                        
echo "           日汇总_网间_诺基亚     nokia_day_stat       inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/nokia/1      |wc -w                        
echo "           日汇总_网间_诺基亚     nokia_day_stat       logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/nokia                 |wc -w                        
echo "           日汇总_网间_诺基亚     nokia_day_stat       outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/nokia         |wc -w                        
echo "           日汇总_网间_诺基亚     nokia_day_stat       skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/nokia           |wc -w                        
echo
echo "    140456 日汇总_网间_阿尔卡特   alcatel_day_stat     backupPath :\t\c"; l /data2/wj/center/data/back/daystat/output/wj/voice/alcatel  |wc -w                        
echo "           日汇总_网间_阿尔卡特   alcatel_day_stat     errorPath  :\t\c"; l /data2/wj/center/error/daystat/wj/voice/alcatel             |wc -w                        
echo "           日汇总_网间_阿尔卡特   alcatel_day_stat     inputPath  :\t\c"; l /data2/wj/center/data/stat/statoutput/wj/voice/alcatel/1    |wc -w                        
echo "           日汇总_网间_阿尔卡特   alcatel_day_stat     logPath    :\t\c"; l /data2/wj/center/log/daystat/wj/voice/alcatel               |wc -w                        
echo "           日汇总_网间_阿尔卡特   alcatel_day_stat     outputPath :\t\c"; l /data2/wj/center/data/daystat/output/wj/voice/alcatel       |wc -w                        
echo "           日汇总_网间_阿尔卡特   alcatel_day_stat     skipPath   :\t\c"; l /data2/wj/center/data/daystat/skip/wj/voice/alcatel         |wc -w                        
echo
echo "    150411 加载清单_网间_短信     ldrmain_sms_data     backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/sms                 |wc -w                        
echo "           加载清单_网间_短信     ldrmain_sms_data     errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/sms                    |wc -w                        
echo "           加载清单_网间_短信     ldrmain_sms_data     inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/sms                    |wc -w                        
echo "           加载清单_网间_短信     ldrmain_sms_data     logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/sms                      |wc -w                        
echo "           加载清单_网间_短信     ldrmain_sms_data     outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/sms              |wc -w                        
echo "           加载清单_网间_短信     ldrmain_sms_data     tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/sms                     |wc -w                        
echo
echo "    150451 加载清单_网间_华为     ldr_huawei           backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/huawei        |wc -w                        
echo "           加载清单_网间_华为     ldr_huawei           errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/huawei           |wc -w                        
echo "           加载清单_网间_华为     ldr_huawei           inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/huawei           |wc -w                        
echo "           加载清单_网间_华为     ldr_huawei           logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/huawei             |wc -w                        
echo "           加载清单_网间_华为     ldr_huawei           outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/huawei     |wc -w                        
echo "           加载清单_网间_华为     ldr_huawei           tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/huawei            |wc -w                        
echo
echo "    150453 加载清单_网间_诺基亚   ldr_nokia            backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/nokia         |wc -w                        
echo "           加载清单_网间_诺基亚   ldr_nokia            errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/nokia            |wc -w                        
echo "           加载清单_网间_诺基亚   ldr_nokia            inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/nokia            |wc -w                        
echo "           加载清单_网间_诺基亚   ldr_nokia            logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/nokia              |wc -w                        
echo "           加载清单_网间_诺基亚   ldr_nokia            outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/nokia      |wc -w                        
echo "           加载清单_网间_诺基亚   ldr_nokia            tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/nokia             |wc -w                        
echo
echo "    150455 加载清单_网间_阿尔卡特 ldr_alcatel          backupPath :\t\c"; l /data2/wj/center/back/dataloader/cdr/wj/voice/alcatel       |wc -w                        
echo "           加载清单_网间_阿尔卡特 ldr_alcatel          errorPath  :\t\c"; l /data2/wj/center/error/dataloader/wj/voice/alcatel          |wc -w                        
echo "           加载清单_网间_阿尔卡特 ldr_alcatel          inputPath  :\t\c"; l /data2/wj/center/back/stat/output/wj/voice/alcatel          |wc -w                        
echo "           加载清单_网间_阿尔卡特 ldr_alcatel          logPath    :\t\c"; l /data2/wj/center/log/dataloader/wj/voice/alcatel            |wc -w                        
echo "           加载清单_网间_阿尔卡特 ldr_alcatel          outputPath :\t\c"; l /data2/wj/center/data/dataloader/output/wj/voice/alcatel    |wc -w                        
echo "           加载清单_网间_阿尔卡特 ldr_alcatel          tempPath   :\t\c"; l /data2/wj/center/temp/dataloader/wj/voice/alcatel           |wc -w                        
echo
echo "    160412 加载帐单_网间_短信     ldrmain_sms_day_stat backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/sms                |wc -w                        
echo "           加载帐单_网间_短信     ldrmain_sms_day_stat errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/sms                 |wc -w                        
echo "           加载帐单_网间_短信     ldrmain_sms_day_stat inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/sms/4          |wc -w                        
echo "           加载帐单_网间_短信     ldrmain_sms_day_stat logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/sms                   |wc -w                        
echo "           加载帐单_网间_短信     ldrmain_sms_day_stat outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/sms           |wc -w                        
echo "           加载帐单_网间_短信     ldrmain_sms_day_stat tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/sms                  |wc -w                        
echo
echo "    160452 加载帐单_网间_华为     ldr_stat_huawei      backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/huawei       |wc -w                        
echo "           加载帐单_网间_华为     ldr_stat_huawei      errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/huawei        |wc -w                        
echo "           加载帐单_网间_华为     ldr_stat_huawei      inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/huawei/2 |wc -w                        
echo "           加载帐单_网间_华为     ldr_stat_huawei      logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/huawei          |wc -w                        
echo "           加载帐单_网间_华为     ldr_stat_huawei      outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/huawei  |wc -w                        
echo "           加载帐单_网间_华为     ldr_stat_huawei      tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/huawei         |wc -w                        
echo
echo "    160454 加载帐单_网间_诺基亚   ldr_stat_nokia       backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/nokia        |wc -w                        
echo "           加载帐单_网间_诺基亚   ldr_stat_nokia       errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/nokia         |wc -w                        
echo "           加载帐单_网间_诺基亚   ldr_stat_nokia       inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/nokia/2  |wc -w                        
echo "           加载帐单_网间_诺基亚   ldr_stat_nokia       logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/nokia           |wc -w                        
echo "           加载帐单_网间_诺基亚   ldr_stat_nokia       outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/nokia   |wc -w                        
echo "           加载帐单_网间_诺基亚   ldr_stat_nokia       tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/nokia          |wc -w                        
echo
echo "    160456 加载帐单_网间_阿尔卡特 ldr_stat_alcatel     backupPath :\t\c"; l /data2/wj/center/back/dataloader/stat/wj/voice/alcatel      |wc -w                        
echo "           加载帐单_网间_阿尔卡特 ldr_stat_alcatel     errorPath  :\t\c"; l /data2/wj/center/error/daydataloader/wj/voice/alcatel       |wc -w                        
echo "           加载帐单_网间_阿尔卡特 ldr_stat_alcatel     inputPath  :\t\c"; l /data2/wj/center/data/daydataloader/input/wj/voice/alcatel/2|wc -w                        
echo "           加载帐单_网间_阿尔卡特 ldr_stat_alcatel     logPath    :\t\c"; l /data2/wj/center/log/daydataloader/wj/voice/alcatel         |wc -w                        
echo "           加载帐单_网间_阿尔卡特 ldr_stat_alcatel     outputPath :\t\c"; l /data2/wj/center/data/daydataloader/output/wj/voice/alcatel |wc -w                        
echo "           加载帐单_网间_阿尔卡特 ldr_stat_alcatel     tempPath   :\t\c"; l /data2/wj/center/temp/daydataloader/wj/voice/alcatel        |wc -w                        
