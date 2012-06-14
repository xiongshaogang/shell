#!/usr/bin/sh
logname=`date +%Y%m%d%H%M%S`
path = /usr/bin;/usr/contrib/bin
/data32/home/aijs/center/scripts/compress.sh >/data32/home/aijs/center/log/logcompress.$logname 2>&1 &
