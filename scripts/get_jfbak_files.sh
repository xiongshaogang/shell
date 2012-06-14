#!/bin/sh
set -x

#--------------------------------------------------------------------#
# 从计费获取省际备份话单
#--------------------------------------------------------------------#

# /data05/bak_month/200605/N_VC_200605*

cd /data4/pickup/200606

#--------------------------------------------------------------------#
# sql to find out where are the bak files at billing db:
# select * from all_file_rule where rule_exp like '_K%'
# select * from all_proc_def where deal_rule_id =140

# upfile is in /data05/bak_month/(history) or /data05/uploader/*/send.bak(realtime) of 10.70.33.14/17

#--------------------------------------------------------------------#
# voice dr is in /data03/bak_month of 10.70.33.14
# include: [D|I|K][0-9]_date.tar

#--------------------------------------------------------------------#
# N_CUSMS
# CH CM FLH G20 IG20 IPI IPO K MM N_VC OS PDA STM VCARD_DOWN W YM
for type in IG20 IPI IPO K MM N_VC OS PDA STM VCARD_DOWN W YM
do
#--------------------------------------------------------------------#
ftp -i -n 10.70.33.15 << !
user billing2 billing
cd /data11/bak_month/200606
mget ${type}_*
bye
!
#--------------------------------------------------------------------#

done

echo "extract from tar files..."
for file in $(ls *.tar)
do
	tar -xvf $file
done

echo "remove unused files..."
rm *2006062[89]*
rm *20060630*
rm *200605*

echo "remove tar files..."	
rm -f *.tar &

echo "uncompress files..."
uncompress *.Z &

exit 0

	
