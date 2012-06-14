#!/bin/sh
 echo "          模块                                  目录                                      文件积压个数 \t\t"; 
 echo "runbillgen 网间语音结算批价 /data2/wj/center/data/daystat/output/wj/voice/alcatel/2  \t\t\c";l /data2/wj/center/data/daystat/output/wj/voice/alcatel/2 |wc -w     
 echo "runbillgen 网间语音结算批价 /data2/wj/center/data/daystat/output/wj/voice/huawei/2   \t\t\c";l /data2/wj/center/data/daystat/output/wj/voice/huawei/2  |wc -w 
 echo "runbillgen 网间语音结算批价 /data2/wj/center/data/daystat/output/wj/voice/nokia/2    \t\t\c";l /data2/wj/center/data/daystat/output/wj/voice/nokia/2   |wc -w 
 echo "runbillgen 网间短信结算批价 /data2/wj/center/data/daystat/output/wj/sms/4            \t\t\c";l /data2/wj/center/data/daystat/output/wj/sms/4           |wc -w 
 echo "runbillgen 省际语音批价     /data3/center/data/stat/statoutput/roam/voice/ipcard/36  \t\t\c";l /data3/center/data/stat/statoutput/roam/voice/ipcard/36 |wc -w 
 echo "runbillgen 省际语音批价     /data3/center/data/stat/statoutput/roam/voice/korea/42   \t\t\c";l /data3/center/data/stat/statoutput/roam/voice/korea/42  |wc -w 
 echo "runbillgen 省际语音批价     /data3/center/data/stat/statoutput/roam/voice/pps/38     \t\t\c";l /data3/center/data/stat/statoutput/roam/voice/pps/38    |wc -w 
 echo "runbillgen 省际语音批价     /data3/center/data/stat/statoutput/roam/voice/rq/40      \t\t\c";l /data3/center/data/stat/statoutput/roam/voice/rq/40     |wc -w 
 echo "runbillgen 省际语音批价     /data3/center/data/stat/statoutput/roam/voice/voice/44   \t\t\c";l /data3/center/data/stat/statoutput/roam/voice/voice/44  |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/              \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/             |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/ch/30         \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/ch/30        |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/crg/64        \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/crg/64       |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/kjava/22      \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/kjava/22     |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/mms/24        \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/mms/24       |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/mp/63         \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/mp/63        |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/sms/28        \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/sms/28       |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/stm/46        \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/stm/46       |wc -w 
 echo "runbillgen 省际SP批价       /data3/center/data/stat/statoutput/roam/sp/wap/26        \t\t\c";l /data3/center/data/stat/statoutput/roam/sp/wap/26       |wc -w 
 echo "runbillgen 省际VC卡充值批价 /data3/center/data/daydataloader/input/roam/refill/vc/32 \t\t\c";l /data3/center/data/daydataloader/input/roam/refill/vc/32|wc -w 
 echo "runbillgen 省际GPRS批价     /data3/center/data/stat/statoutput/roam/gprs/20          \t\t\c";l /data3/center/data/stat/statoutput/roam/gprs/20         |wc -w 
 echo "reclaim_trunk 错单回收      /data2/wj/center/error/settle/wj/voice/alcatel           \t\t\c";l /data2/wj/center/error/settle/wj/voice/alcatel          |wc -w 
 echo "reclaim_trunk 错单回收      /data2/wj/center/error/settle/wj/voice/nokia             \t\t\c";l /data2/wj/center/error/settle/wj/voice/nokia            |wc -w 
 echo "reclaim_trunk 错单回收      /data2/wj/center/error/settle/wj/voice/huawei            \t\t\c";l /data2/wj/center/error/settle/wj/voice/huawei           |wc -w 

