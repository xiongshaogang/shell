#!/bin/sh
#cript to autostart Tomcat
#author:zee
#2013/05/10
##################################################

#------------------------------------------------
#               INIT
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

##################################################
#             Function
##################################################
get_now_time()
{
        now=`date +%Y%m%d%H%M%S`
}

set_backpath()
{
        echo "-->set_back_path:$*"
        if [ ! -d $1 ]; then
                echo -e "-->create back_path:$1 \t\t\t[ok]"
                mkdir -p $1             # force to create the directory hierarch
        fi
        back_path=$1
}

check_file()
{
        echo "-->check file now at $curedate"
        if [ -e $apache.tar.gz ];then
                echo -e "-->$apache.tar.gz is exist!\t\t\t\t\t[ok]"
        else
                echo "<--pls upload $apache.tar.gz"
                exit 1
        fi
        if [ -e $1.zip ] ;then
                echo -e "-->$1.zip is exist!\t\t\t\t\t\t\t[ok]"
        else
                echo "<--pls upload $1.zip"
                exit 1
        fi
        if [ -e $2.sql ];then
                echo -e "-->$2.sql is exist!\t\t\t\t\t\t\t[ok]"
        else
                echo "<--pls upload $1 database"
                exit 1
        fi
}

tartomcat()
{
        echo "-->tar zxf apache_tomcat:port file"
        tar zxf $apache.tar.gz
        echo -e "-->finish tar tomcat.    \t\t\t\t\t\t[ok]"
}

mvprg()
{
        echo "-->move $1.zip to tomcat/webapps/"
        mv $1.zip $backroot/$apache/webapps/.
        echo  -e "-->move $1.zip finish. \t\t\t\t\t\t[ok]"
}

mvsql()
{
        echo "-->move $1.sql to tomcat/webapps/"
        mv $1.sql $backroot/$apache/webapps/.
        echo -e "-->move $1.sql finish. \t\t\t\t\t\t[ok]"
}

createdb(){
        echo "-->create database $1"
        create_db_sql="create database  $1 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci "
        mysql -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"
        echo -e "-->create database $1 finish.\t\t\t\t\t\t[ok]"
}

importsql(){
        echo "-->Execute sql File $1.sql......pls wait!"
        mysql -u${USERNAME} -p${PASSWORD} $1<$backroot/$apache/webapps/$1.sql
        echo -e "-->Execute sql Fiel finish. \t\t\t\t\t\t[ok]"
}

unprg(){
        echo "-->unzip $1.zip"
        cd $backroot/$apache/webapps/
        unzip $1.zip >/dev/null
        echo -e "-->unzip $1.zip finish!. \t\t\t\t\t\t[ok]"
        echo "-->Backup_prg start"
        set_backpath $backpath/$curedate
        mv $1.zip $back_path
        mv $2.sql $back_path
}

addbashrc(){
        echo "-->add .bashrc start"
        echo "alias tom='/home/mas/eie/opt/apache-tomcat8011/bin/run'">> /home/mas/.bashrc
        echo -e "-->add .bashrc finish.   \t\t\t\t\t\t[ok]"
}

run_sh(){
        get_now_time
        echo -e "-->run shell start.     \t\t\t\t----->${now}<-----"
        check_file $1 $2
        tartomcat
        mvprg $1
        mvsql $2
        createdb $2
        importsql $2
        addbashrc
        sed -i "s/prgname/$1/g" /home/mas/eie/opt/apache-tomcat8011/conf/server.xml
        unprg $1 $2
        get_now_time
        echo -e "-->run shell finish .    \t\t\t\t----->${now}<-----"
}

test_sh(){
        /home/mas/eie/opt/apache-tomcat8011/bin/run
        echo "Usage: tom  {start|stop|restart|logs|status}"
}

#####################################
#              Main
#####################################

if [ $# != 2 ] ; then
        echo "Usage: zee  {prgname}   {dbname}"
        exit 1
else
run_sh  $1 $2
source ~/.bashrc
test_sh
fi
