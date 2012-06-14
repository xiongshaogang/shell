#!/bin/bash
# calucate dates for later use
now=`date +%Y%m%d%H%M%S` # now="20060710112233" # get_now_time

#--------------------------------------------------------------------#
get_now_time()
{
now=`date +%Y%m%d%H%M%S`
echo "$now"
}

#--------------------------------------------------------------------#
set_backpath()
{
echo "==>set_back_path $*"

if [ ! -d $1 ]; then
echo "--create backpath: $1"
mkdir -p $1             # force to create the directory hierarch                                                                                                  y
fi


backpath=$1
# echo "<==return $backpath\n"
}

#--------------------------------------------------------------------#
Backup_Webapp()
{
echo "==>Backup_Webapp"

#get_dr_day_list $srcpath "$filepattern"                # cd $srcpath he                                                                                                  re!
set_backpath $backroot
if [ "$need_compress" = "N" ]; then
echo "==>This file is not need_compress,backpath is $backpath"
backup_dr_to_path "${filepattern}" $webapp_file  $backpath
else
echo "--compress..."
compress -f $filepattern        # [0-9]
backup_dr_to_path "${filepattern}.$loop_day" "$filepattern$lo                                                                                                  op_day*.Z" $backpath
fi


echo "<==Backup_Webapp"
}

backup_dr_to_path()
{

echo "==>tar_path: $2"

local tarfile="$1$cur_day.tar"
echo "tarfile is $tarfile"

# if dest backed file existed, use -u option to update it!
if [ -e $tarfile ]; then
echo "--update existed $tarfile ..."
cd $2
tar -uf $tarfile $1  # The u function key can be slow.
mv $tarfile  $3
else
echo  "tar -cf $tarfile $1 "
echo  "mv $tarfile  $3"
cd $2
tar -cf $tarfile $1
mv $tarfile  $3
fi

# rm backuped files
#rm -f $2

echo "<==backup_path"
}

######################################################################
#                         SCRIPT BEGIN                               #
######################################################################
cur_day=`echo $now|cut -c -8`
backroot="/home/mas/eie/opt/bak"
webapp_file="/home/mas/eie/opt/tomcat/webapps/"

#set_backpath $backroot
echo "Webapp backup begin...$now "

filepattern="qqjy"
sql_prefix="jhydqqjy"
need_compress="N"
Backup_Webapp



#--------------------------------------------------------------------#

echo -n "Webapp backup end!" 
now=`date +%Y%m%d%H%M%S`
echo "$now"



echo "==>Mysql backup"
mysqldump -uroot -proot $sql_prefix >/home/mas/eie/opt/bak/$sql_prefix$cur_day.sql
echo "<==Mysql backup"
exit 0

