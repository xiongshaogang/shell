#!/bin/sh
##################################################
#
#
#
#
##################################################

#------------------------------------------------
#		INIT 
#-----------------------------------------------
curedate=`date +%Y%m%d%H%M%S`
backroot=`pwd`
apache='apache-tomcat8011'
backpath="/home/mas/eie/opt/bak"


get_now_time()
{
	now=`date +%Y%m%d%H%M%S`
}

check_file(){

	echo "-->check file now at $curedate"| tee ./autostart.log
	if [ -e $apache.tar.gz ];then
		echo "-->$apache.tar.gz is exist!"| tee -a ./autostart.log
	else
		echo "--<pls up $apache.tar.gz"| tee -a ./autostart.log
		exit 1
	fi
	if [ -e $1.zip ] ;then
		echo "-->$1.zip is exist!"| tee -a ./autostart.log
	else
		echo "--<pls up $1.zip"| tee -a ./autostart.log
		exit 1
	fi
	if [ -e $2.sql ];then
		echo "-->$2.sql is exist!"| tee -a ./autostart.log
	else
		echo "--<pls up $1 database"| tee -a ./autostart.log
		exit 1
	fi
	if [ -e config.properties ];then
		echo "-->config.properties  is exist!"| tee -a ./autostart.log
	else
		echo "--<pls up config.properties"| tee -a ./autostart.log
		exit 1
	fi
}




tartomcat(){

	echo "-->tar zxf apache_tomcat:port file"| tee -a ./autostart.log
	tar zxf $apache.tar.gz 
	echo -e "-->finish tar tomcat.    \t\t\t\t\t\t\t\t\t\t\t\t[ok]"| tee -a ./autostart.log
}

mvprg(){

	 echo "-->move $1.zip to tomcat/webapps/"| tee -a ./autostart.log
	 mv $1.zip $backroot/$apache/webapps/.
	 echo  -e "-->move $1.zip finish. \t\t\t\t\t\t\t\t\t\t\t\t[ok]"| tee -a ./autostart.log
}

mvsql(){

	 echo "-->move $1.sql to tomcat/web/apps/"| tee -a ./autostart.log
	 mv $1.sql $backroot/$apache/webapps/.
	 echo -e "-->move $1.sql finish. \t\t\t\t\t\t\t\t\t\t\t\t[ok]"| tee -a ./autostart.log

}

createdb(){
	echo "-->"| tee -a ./autostart.log

}

importsql(){
 	echo "-->"| tee -a ./autostart.log

}

unprg(){
	 echo "-->unzip $1.zip"| tee -a ./autostart.log
	 cd $backroot/$apache/webapps/
	 unzip $1.zip>/dev/null 2>autostart.log
	 echo -e "-->unzip $1.zip finish!. \t\t\t\t\t\t\t\t\t\t\t\t[ok]"| tee -a ./autostart.log

}

addbashrc(){
	 echo "-->addbashrc file now"| tee -a ./autostart.log
	 echo "alias tom='/home/mas/eie/opt/apache-tomcat8011/bin/run'">> /home/mas/.bashrc
	 source /home/mas/.bashrc
	 echo `tom`| tee -a ./autostart.log
	 echo -e "-->add .bashrc finish. \t\t\t\t\t\t\t\t\t\t\t\t[ok]"| tee -a ./autostart.log
}

bakprg(){
	 echo "-->check file  new"| tee -a ./autostart.log

}

baksql(){
	 echo "-->check file  new"| tee -a ./autostart.log

}

copy(){
	
echo "-->coyp config file start"
cp /home/mas/eie/opt/apache-tomcat8011/webapps/$1/WEB-INF/classes/config.properties  .
echo `ls -ltr  config.properties`
echo "-->coyp config file end"

}

rmprg(){

	echo "-->rm $1 file start"
	rm  -rf  $1
	echo "-->rm $1 file end "

}


mvfig(){

	echo "-->move config file start"
	mv ./config.properties  /home/mas/eie/opt/apache-tomcat8011/webapps/$1/WEB-INF/classes/config.properties  
	echo `ls -ltr /home/mas/eie/opt/apache-tomcat8011/webapps/$1/WEB-INF/classes/config.properties`
	echo "-->move config file end"

}

set_bak_path(){
	 echo "-->check file  new"| tee -a ./autostart.log

}

set_backpath()
{
	echo "-->set_back_path:$*"

	if [ ! -d $1 ]; then
		echo "-->create backpath: $1"
		mkdir -p $1             # force to create the directory hierarch 
	fi
	backpath=$1
}


bakprg(){
echo "-->Backup_prg start"
set_backpath $backpath/$cur_day
#echo "==>tar_path: $2"

local tarfile="$1$now.tar"
echo "-->tarfile is $tarfile"

# if dest backed file existed, use -u option to update it!
if [ -e $tarfile ]; then
	echo "-->update existed $tarfile ..."
	tar -uf $tarfile $1  # The u function key can be slow.
	mv $tarfile  $backpath/$cur_day
else
	tar -cf $tarfile $1
	mv $tarfile  $backpath/$cur_day
fi

echo `ls -ltr  $backpath/$cur_day/$tarfile`
echo "-->Back_prg finish"
}

baksql(){
echo "-->Backup_sql $1$cur_day.sql start"
set_backpath $backpath/$cur_day
mysqldump -uroot -proot $1 >$backpath/$cur_day/$1$cur_day.sql
echo "-->Back_sql finish"
}


test_sh(){
	 get_now_time
	 echo "-->Test shll now:${now}"| tee -a ./autostart.log
	

}

run_sh(){
get_now_time
echo "-->run shll start. now:${now}"| tee -a ./autostart.log
#check_file $1 $2
tartomcat
mvprg $1
mvsql $2
unprg $1
#addbashrc
test_sh
get_now_time
echo "-->run shll finish . now:${now}"| tee -a ./autostart.log
}


run_sh  $1 $2 
