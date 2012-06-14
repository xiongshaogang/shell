#!/bin/csh

#--------------------------------------------------------------------#
# !!!DO NOT MOVE OR DELETE THIS SCRIPT!!!
# SINCE it's scheduled in crontab to execute once a month
#--------------------------------------------------------------------#

#--------------------------------------------------------------------#
# This script is used to upload file to CMCC @ 10th of every month
#   on condition that monternet check system runs A-OK
# Author: fanghm@asiainfo.com - 2005.10.25
# History:
# 2006/10/9 change upload IP from 132.32.22.11 to 132.32.22.18
#--------------------------------------------------------------------#

setenv M `date +%m`
setenv Y `date +%Y`

if($M == "01") then
    @ M = 12
    @ Y = $Y - 1
else
    @ M = $M - 1
endif

setenv BM 0
if($M < 10) then
    @ BM =  $Y'0'$M
else
    @ BM =  $Y$M
endif
echo $BM

setenv logpath $SYS_LOG_PATH
echo $logpath

setenv upfile1 spdz_sum_001_$BM.571
setenv upfile2 spdz_sub_001_$BM.571

# add by xr for debug
date >> $logpath/spdz/upfile.log
echo "begin to upload $upfile1 and $upfile2 ..." >> $logpath/spdz/upfile.log

if ( -f "$logpath/spdz/$upfile1" ) then
    echo $upfile1 existed >> $logpath/spdz/upfile.log
    #echo $upfile2

#--------------------------------------------------------------------#
echo begin
ftp -i -n 132.32.22.18 > /dev/null << EOF
user spdz571 64714269
cd /spdz/spdz571
lcd $logpath/spdz
bi
prom off
put $upfile1
put $upfile2
bye
EOF
#--------------------------------------------------------------------#    
    echo Upload_OK
    
    # leave footprint
    touch "$logpath/spdz/${upfile1}_has_upload"
endif

exit 0
