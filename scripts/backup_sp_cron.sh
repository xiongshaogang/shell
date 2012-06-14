#!/bin/sh

month=`date +%Y%m`
mkdir -p /data1/backup/sp/$month
mv -f /data1/home/jsusr1/center/zwjf_scripts/tmp/*.Z /data1/backup/sp/$month/

exit 0
