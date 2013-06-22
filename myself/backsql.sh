#!/bin/sh
nowdate=`date +%Y%m%d%H%M%S`
curedate=`echo $nowdate|cut -c -8`
backpath="/home/mas/eie/opt/bak/sql"
USERNAME="root"
PASSWORD="root"
Dbname="base"
baksql(){
set_backpath $backpath
mysqldump -u${USERNAME} -p${PASSWORD} $Dbname >$Dbname.sql
tar -zcf $Dbname$curedate.tar.gz $Dbname.sql
chown mas.masgrp $Dbname$curedate.tar.gz
mv $Dbname$curedate.tar.gz $back_path
rm -rf $Dbname.sql
}

set_backpath()
{
        if [ ! -d $1 ]; then
                mkdir -p $1             # force to create the directory hierarch
        fi
        back_path=$1
}

baksql
##su - mas -c  'baksql'
