#!/bin/sh
###################################
#1.通过固定FTP地址，FTP方式访问电子照片(已经解决)；
#-------------------zypper in vsftpd 
#-------------------修改vsftpd配置文件 
#-------------------放开listen=YES注释 ，注释listen_ipv6=YES
#2.访问时不允许匿名访问
#-------------------修改vsftpd配置文件 
#-------------------Uncomment this to enable any form of FTP write command.
#-------------------19 write_enable=NO  （修改为YES）
#3.访问时需要输入用户名及密码,以组织编号为账号，预设账号及密码；
#-------------------修改vsftpd配置文件 
#-------------------Allow anonymous FTP? (Beware - allowed by default if you comment this out).
#-------------------76 anonymous_enable=YES （修改为NO）
#4.420800账号可以访问FTP下所有目录及文件，其他账号只能访问固定的目录，也就是登录后根据用户账号，只显示对应的目录及目录下所有文件，如420801账号登录后只能访问420801文件夹及文件夹下所有文件，420802账号登录后只能访问420802文件夹及文件夹下所有文件。
#-------------------使用yast工具添加用户 
#-------------------选择Security and Users
#-------------------选择User and Group Management 
#-------------------添加用户并保存
#5.FTP访问路径下文件夹目录名称不允许修改或是新增目录或是删除目录，电子照片文件不允许删除，但是需要能够对其进行修改文件名，如20130614160345172.jpg文件修改为20130614160345172_已处理.jpg
#-------------------修改vsftpd配置文件  
#-------------------放开 62行注释  
#-------------------chroot_local_user=YES  
#-------------------给ftp添加牢笼，禁止用户向上层文件访问。
#6.FTP分配足够的空间，电子照片会越来越多。
#
#
###################################
set -x
###################################
#config parameter
#荆门市交警支队:      u420800    jmjj_jjzd
#荆门市市辖区:        u420801    jmjj_sxq
#荆门市东宝大队:      u420802    jmjj_db
#荆门市掇刀大队:      u420804    jmjj_dd
#荆门京山大队:        u420821    jmjj_js
#荆门市沙洋大队:      u420822    jmjj_sy
#荆门市钟祥大队:      u420881    jmjj_zx
###################################
DIR=/home/apache-tomcat8080/webapps/jmjwt/picture
nowdate=`date +%Y%m%d%H%M%S`
curedate=`echo $nowdate|cut -c -8`
#使用用户目录
use1=/home/u420800
use2=/home/u420801
use3=/home/u420802
use4=/home/u420804
use5=/home/u420821
use6=/home/u420822
use7=/home/u420881

#创建以当天日期为文件名目录
if [ ! -d $use2/$curedate ]; then
	mkdir -p $use2/$curedate          
	mkdir -p $use3/$curedate           
	mkdir -p $use4/$curedate           
	mkdir -p $use5/$curedate           
	mkdir -p $use6/$curedate           
	mkdir -p $use7/$curedate           
fi

###################################
#				Main
###################################
#将项目10分钟内生成图片复制到自定路径下
#例如：echo 1|find /home/apache-tomcat8080/webapps/jmjwt/picture/420801/ -mmin -15 -type f -exec cp {}  /home/u420801  \;
echo 1|find $DIR/420800/ -mmin -10 -type f -exec cp {}   $use1 \;
echo 2|find $DIR/420801/ -mmin -10 -type f -exec cp {}   $use2/$curedate \;
echo 3|find $DIR/420802/ -mmin -10 -type f -exec cp {}   $use3/$curedate \;
echo 4|find $DIR/420804/ -mmin -10 -type f -exec cp {}   $use4/$curedate \;
echo 5|find $DIR/420821/ -mmin -10 -type f -exec cp {}   $use5/$curedate \;
echo 6|find $DIR/420822/ -mmin -10 -type f -exec cp {}   $use6/$curedate \;
echo 7|find $DIR/420881/ -mmin -10 -type f -exec cp {}   $use7/$curedate \;
echo 8|find $DIR/JYSG_Picture/ -mmin -10 -type f -exec cp {}   $use1/JYSG_Picture/ \;

#清空420800下面同步过来的数据（第4条需求）
rm -rf $use1/420*
#在420800用户目录下创建其他用户同步数据文件夹
mkdir -p $use1/420801
mkdir -p $use1/420802
mkdir -p $use1/420804
mkdir -p $use1/420821
mkdir -p $use1/420822
mkdir -p $use1/420881

#同步其他用户下面数据到420800用户文件夹内，源文件为2013MMDD 目标路径为用户名
echo 9|awk -v cmd="cp -i -R $use2/2* $use1/420801" 'BEGIN {print "n"|cmd;}' 2 >/dev/null
echo 9|awk -v cmd="cp -i -R $use3/2* $use1/420802" 'BEGIN {print "n"|cmd;}' 2 >/dev/null
echo 9|awk -v cmd="cp -i -R $use4/2* $use1/420804" 'BEGIN {print "n"|cmd;}' 2 >/dev/null
echo 9|awk -v cmd="cp -i -R $use5/2* $use1/420821" 'BEGIN {print "n"|cmd;}' 2 >/dev/null
echo 9|awk -v cmd="cp -i -R $use6/2* $use1/420822" 'BEGIN {print "n"|cmd;}' 2 >/dev/null
echo 9|awk -v cmd="cp -i -R $use7/2* $use1/420881" 'BEGIN {print "n"|cmd;}' 2 >/dev/null

#给相应的用户文件夹修改拥有者 前面都是用root操作的需要修改下
chown u420800.users -R $use1
chown u420801.users -R $use2
chown u420802.users -R $use3
chown u420804.users -R $use4
chown u420821.users -R $use5
chown u420822.users -R $use6
chown u420881.users -R $use7

#给相应的用户文件夹修改权限
#chmod 755 -R $use1
#chmod 755 -R $use2
#chmod 755 -R $use3
#chmod 755 -R $use4
#chmod 755 -R $use5
#chmod 755 -R $use6
#chmod 755 -R $use7
#if [ -d $path ]
#then
#       if [ ! -d $FTP ]; then
#               mkdir -p $FTP            # force to create the directory hierarch
#               scp -r $FTP root@192.168.1.5:/srv/ftp/
#       fi
#echo 1|awk -v cmd="cp -i $path/* $FTP" 'BEGIN {print "n"|cmd;}'  2 >/dev/null
#scp /srv/ftp/* root@192.168.1.5:/srv/ftp
#find $FTP -mmin -10 -type f -exec scp -r {}  root@192.168.1.5:$FTP \;
#else
#echo '1111111'
#exit 1
#fi
#find  $FTP  -mtime +30 -name "*" -exec rm -rf {} \;
#


########################
# 测试数据
########################
#新建文件夹
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420800 
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420801 
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420802 
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420804 
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420821
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420822
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/420881
# mkdir -p /home/apache-tomcat8080/webapps/jmjwt/picture/JYSG_Picture
#新建文件
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420800/pic123.jpg
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420801/pic223.jpg 
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420802/pic323.jpg 
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420804/pic423.jpg 
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420821/pic523.jpg
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420822/pic623.jpg
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/420881/pic723.jpg
# touch  /home/apache-tomcat8080/webapps/jmjwt/picture/JYSG_Picture/pic823.jpg
#删除用户下面文件
# rm -rf /home/u420800/2*
# rm -rf /home/u420801/2*
# rm -rf /home/u420802/2*
# rm -rf /home/u420804/2*
# rm -rf /home/u420821/2*
# rm -rf /home/u420822/2*
# rm -rf /home/u420881/2*
