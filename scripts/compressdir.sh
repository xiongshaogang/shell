#!/usr/bin/sh
PATH=$PATH:/usr/contrib/bin

cd $1/huawei
ls |grep -v 'gz$'|xargs gzip &

cd $1/alcatel
ls |grep -v 'gz$'|xargs gzip &

exit 0
