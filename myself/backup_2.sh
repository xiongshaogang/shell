#!/bin/sh
##################################################
#Script to autostart Tomcat
#author:zee
#2012/05/3
##################################################

#------------------------------------------------
#		INIT 
#-----------------------------------------------
nowdate=`date +%Y%m%d%H%M%S`
curedate=`echo $nowdate|cut -c -8`
backroot=`pwd`
apache='apache-tomcat8011'
backpath="/home/mas/eie/opt/bak"
HOSTNAME="127.0.0.1"                  
PORT="3306"
USERNAME="root"
PASSWORD="root"


source ~/.bashrc
#-----------------------------------------------

get_now_time()
{
	now=`date +%Y%m%d%H%M%S`
}

check_file(){

	echo "-->check file now at $curedate"
	if [ -e $apache.tar.gz ];then
		echo -e "-->$apache.tar.gz is exist!\t\t\t\t\t\t\t\t[ok]"
	else
		echo "--<pls up $apache.tar.gz"
		exit 1
	fi
	if [ -e $1.zip ] ;then
		echo -e "-->$1.zip is exist!\t\t\t\t\t\t\t\t\t\t[ok]"
	else
		echo "--<pls up $1.zip"
		exit 1
	fi
	if [ -e $2.sql ];then
		echo -e "-->$2.sql is exist!\t\t\t\t\t\t\t\t\t\t[ok]"
	else
		echo "--<pls up $1 database"
		exit 1
	fi
#	if [ -e config.properties ];then
#		echo  -e "-->config.properties is exist! \t\t\t\t\t\t\t\t\t[ok]"
#	else
#		echo "--<pls up config.properties"
#		exit 1
#	fi
}




tartomcat(){

	echo "-->tar zxf apache_tomcat:port file"
	tar zxf $apache.tar.gz 
	echo -e "-->finish tar tomcat.    \t\t\t\t\t\t\t\t\t[ok]"
}

mvprg(){

	 echo "-->move $1.zip to tomcat/webapps/"
	 mv $1.zip $backroot/$apache/webapps/.
	 echo  -e "-->move $1.zip finish. \t\t\t\t\t\t\t\t\t[ok]"
	 
}

mvsql(){

	 echo "-->move $1.sql to tomcat/web/apps/"
	 mv $1.sql $backroot/$apache/webapps/.
	 echo -e "-->move $1.sql finish. \t\t\t\t\t\t\t\t\t[ok]"

}

createdb(){
	echo "-->create database $1"
#create database test DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci IF NOT EXISTS test;    
	create_db_sql="create database  $1 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci "
#	mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"
	mysql -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"
	echo -e "-->create database $1 finish.\t\t\t\t\t\t\t\t\t[ok]"
}

importsql(){
 	echo "-->Execute sql File $1.sql......pls wait!"
#	echo  "mysql -u${USERNAME} -p${PASSWORD} $1<$1.sql"
	mysql -u${USERNAME} -p${PASSWORD} $1<$backroot/$apache/webapps/$1.sql
	echo -e "-->Execute sql Fiel finish. \t\t\t\t\t\t\t\t\t[ok]"
}


unprg(){
	 echo "-->unzip $1.zip"
	 cd $backroot/$apache/webapps/
	 unzip $1.zip>/dev/null 2>&1
	 echo -e "-->unzip $1.zip finish!. \t\t\t\t\t\t\t\t\t[ok]"
	 echo "-->Backup_prg start"
	set_backpath $backpath/$curedate
	mv $1.* $back_path
}

addbashrc(){
	 echo "-->addbashrc file now"
	 echo "alias tom='/home/mas/eie/opt/apache-tomcat8011/bin/run'">> /home/mas/.bashrc
	 source /home/mas/.bashrc
	 echo `tom`
	 echo -e "-->add .bashrc finish.   \t\t\t\t\t\t\t\t\t[ok]"
}




copyconfig(){
	
echo "-->coyp config file start"
cp $backroot/$apache/webapps/$1/WEB-INF/classes/config.properties  .
echo `ls -ltr  config.properties`
echo "-->coyp config file end"

}

rmprg(){

	echo "-->rm $1 file start"
	rm  -rf  $1
	echo "-->rm $1 file end "

}


mvconfig(){

	echo "-->move config file start"
	mv ./config.properties  $backroot/$apache/webapps/$1/WEB-INF/classes/config.properties  
	echo `ls -ltr $backroot/$apache/webapps/$1/WEB-INF/classes/config.properties`
	echo "-->move config file end"

}


set_backpath()
{
	echo "-->set_back_path:$*"
	if [ ! -d $1 ]; then
		echo -e "-->create back_path:$1 \t\t\t\t\t\t\t[ok]"
		mkdir -p $1             # force to create the directory hierarch 
	fi
	back_path=$1
}


bakprg(){
echo "-->Backup_prg start"
set_backpath $backpath/$curedate
#echo "==>tar_path: $2"

local tarfile="$1.tar"
echo "-->tarfile is $tarfile"

# if dest backed file existed, use -u option to update it!
if [ -e $tarfile ]; then
 echo "-->update existed $tarfile ..."
 tar -uf $tarfile $1  # The u function key can be slow.
 mv $tarfile  $back_path
else
 tar -cf $tarfile $1
 mv $tarfile  $back_path
fi

echo `ls -ltr  $back_path/$tarfile`
echo "-->Back_prg finish"
}

baksql(){
echo "-->Backup_sql $1$curedate.sql start"
set_backpath $backpath/$curedate
mysqldump -u${USERNAME} -p${PASSWORD} $1 >$back_path/$1$curedate.sql
echo `ls -ltr  $back_path/$1$curedate.sql`
echo "-->Back_sql finish"
}



test_sh(){
	 get_now_time
	 echo "-->Test shll "                                                              
	 tom

	 tom status
}

run_sh(){
get_now_time
echo -e "-->run shll start.                                                                                                    \t\t\t\t----->${now}<-----"
#check_file $1 $2
#tartomcat
#mvprg $1
#mvsql $2
#createdb $2
#importsql $2
#addbashrc
#unprg $1
test_sh
get_now_time
echo -e "-->run shll finish .                                                                                                 \t\t\t\t----->${now}<-----"
}


run_sh  $1 $2 



