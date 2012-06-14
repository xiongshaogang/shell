#!/bin/sh
tmp=run
CATALINA_HOME=`echo  $0 |sed  "s/\(.*\)$tmp/\1/g"`
#echo $CATALINA_HOME
count="ps -fu `whoami` |grep bootstrap.jar   |  grep $CATALINA_HOME | grep -v grep | wc -l"
t=`eval $count`
#echo $t

tomcat_help(){

echo "================================================"
echo "=tom status          ��ʾtomcat״̬            ="
echo "=tom start           ����tomcat                ="
echo "=tom stop            ֹͣtomcat                ="
echo "=tom logs            �鿴tomcat��־            ="
echo "=tom restart         ����tomcat                ="
echo "================================================"

}

check_tomcat()
{
  echo "--------------------------"
  echo "-->  check tomcat info  <--"
  echo "--------------------------"
  ps -fu `whoami` | grep  bootstrap.jar  | grep $CATALINA_HOME | grep -v grep 
  if [ $t -ne 0 ] ;then
	echo "-->Tomcat exist $t"
  echo "--------------------------"
  else
	echo "-->Tomcat  is not exist $t"
  echo "--------------------------"
  fi
}


start_tomcat()
{
  
  if [ $t -ne 0 ];then                  # if ps -fu `whoami` |  grep -E java  >/dev/null 2>$1 ; then
  echo "--------------------------"
	  echo "-->Tomcat exist $t"
  echo "--------------------------"
  else
  echo "--------------------------"
  echo "-->Start tomcat pls wait"
  echo "--------------------------"
  sh $CATALINA_HOME/startup.sh
  fi

}

kill_tomcat()
{

  if [ $t -ne 0 ] ;then
  echo "--------------------------"
	echo "-->Tomcat exist $t Stop tomcat now"
  echo "--------------------------"
  ps -fu `whoami`  |grep   bootstrap.jar  |  grep $CATALINA_HOME | grep -v grep | awk '{ print $2 }'| xargs kill -9  #2 >/dev/null
  sleep 3                            
else
  echo "--------------------------"
	echo "-->Tomcat  is stop $t"
  echo "--------------------------"
  fi

}

tail_logs()
{

  echo "--------------------------"
  echo "-->tail tomcat:$CATALINA_HOME../logs/catalina.out"
  echo "--------------------------"
  tail -f $CATALINA_HOME/../logs/catalina.out

}	

run_tomcat()
{

case $1 in
status)
check_tomcat
;;
start) 
start_tomcat
;;
stop) 
kill_tomcat
;;
logs) 
tail_logs
;;
restart) 
echo "restart tomcat now"
kill_tomcat
echo "pls wait 6s"
sleep 6
sh $CATALINA_HOME/startup.sh | tee $CATALINA_HOME/autostart.log
check_tomcat
echo "tomcat is running..."
;;
*)
tomcat_help
;;
esac

}

run_tomcat $1
