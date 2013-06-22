#!/bin/sh
##########################################
#		init			#
##########################################
backroot="/home/mas/eie/opt/bak"
now=`date +%Y%m%d%H%M%S`
cur_day=`echo $now|cut -c -8`

#---------------------------------------#
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

un(){

	echo "-->unzip $1.prg start"
	unzip $1.zip
	echo "-->unzip $1.prg  end"

}

check(){
	filepath=`pwd`	
	if [ -f $filepath/$1.zip ];then
		echo "-->prg file is exist"
	else
		echo "-->pls input prg $filepath/$1.zip"
		exit 1
	fi
}
#--------------------------------------------------------------------#
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
set_backpath $backroot/$cur_day
#echo "==>tar_path: $2"

local tarfile="$1$now.tar"
echo "-->tarfile is $tarfile"

# if dest backed file existed, use -u option to update it!
if [ -e $tarfile ]; then
	echo "-->update existed $tarfile ..."
	tar -uf $tarfile $1  # The u function key can be slow.
	mv $tarfile  $backroot/$cur_day
else
	tar -cf $tarfile $1
	mv $tarfile  $backroot/$cur_day
fi

echo `ls -ltr  $backroot/$cur_day/$tarfile`
echo "-->Back_prg finish"
}

baksql(){
echo "-->Backup_sql $1$cur_day.sql start"
set_backpath $backroot/$cur_day
mysqldump -uroot -proot $1 >$backroot/$cur_day/$1$cur_day.sql
echo "-->Back_sql finish"
}


run()
{
	case $2 in
		copy)
		copy $1
		;;
		rm)
		rmprg $1
		;;
		unzip)
		un $1
		;;
		mvfig)
		mvfig $1
		;;
		bakprg)
		bakprg $1
		;;
		baksql)
		baksql $3
		;;
		auto)
		bakprg $1
		baksql $3
		copy $1
		rmprg $1
		un $1
		mvfig $1
		;;
		*)
		echo  "pls input prg (copy|rm|unzip|mvfig|bakprg|baksql|auto) dbname"
		;;
	esac
}
check $1
echo "$1 $2 $3" 
run $1 $2  $3
