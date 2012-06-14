#!/usr/bin/sh
PATH=$PATH:/usr/contrib/bin
cd /data33/aijs/center/back/settle/wj/voice/huawei 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/settle/wj/voice/nokia
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/settle/wj/voice/alcatel 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/settle/wj/sms 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/dataloader/cdr/wj/voice/huawei
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/dataloader/cdr/wj/voice/nokia
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/dataloader/cdr/wj/voice/alcatel
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/stat/output/wj/voice/huawei 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/stat/output/wj/voice/nokia 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/stat/output/wj/voice/alcatel 
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/back/dataloader/cdr/wj/sms
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/error/format/wj/voice/huawei
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/error/format/wj/voice/nokia
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/error/format/wj/voice/alcatel
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/data/dataloader/output/wj/voice/huawei
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/data/dataloader/output/wj/voice/alcatel
ls |grep -v 'gz$'|xargs gzip &
cd /data33/aijs/center/data/dataloader/output/wj/voice/nokia
ls |grep -v 'gz$'|xargs gzip &
cd  /data34/aijs/center/back/settle/sp/billing/ismg 
ls |grep -v 'gz$'|xargs gzip &
cd /data34/aijs/center/data/dataloader/output/sp/billing/ismg
ls |grep -v 'gz$'|xargs gzip &
cd /data34/aijs/center/back/dataloader/cdr/sp/billing/ismg
ls |grep -v 'gz$'|xargs gzip &
cd /data34/aijs/center/back/settle/sp/billing/mms
ls |grep -v 'gz$'|xargs gzip &
