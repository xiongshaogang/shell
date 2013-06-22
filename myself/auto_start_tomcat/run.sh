#!/bin/sh
###########################################
#Script to autostart Tomcat
#author:zee
#2012/04/12
#Usage:
# tom start/stop/status/restart
#NOTE:CATALINA_HOME  get path
###########################################
CATALINA_HOME=`echo  $0 |sed  "s/\(.*\)run/\1/g"`   #echo $CATALINA_HOME  #t=`eval $count`



tomcat_help()
{
  echo "================================================"
  echo "=status.Check tomcat run                       ="
  echo "=start.Start tomcat                            ="
  echo "=stop.Quit tomcat                              ="
  echo "=logs.Tail tomcat logs                         ="
  echo "=restart.restart tomcat                        ="
  echo "================================================"
}

count_tomcat()
{
  ps -fu `whoami` |grep bootstrap.jar   |  grep $CATALINA_HOME | grep -v grep | wc -l
}

check_tomcat()
{
  t=`count_tomcat`
    echo "--------------------------"
  ps -fu `whoami` | grep  bootstrap.jar  | grep $CATALINA_HOME | grep -v grep
  if [ $t -ne 0 ] ;then
    echo "-->Tomcat exist $t        "
    echo "--------------------------"
  else
    echo "-->Tomcat  not exist $t   "
    echo "--------------------------"
  fi
}


start_tomcat()
{
  t=`count_tomcat`
  if [ $t -ne 0 ];then                  # if ps -fu `whoami` |  grep -E java  >/dev/null 2>$1 ; then
    echo "--------------------------"
    echo "-->Tomcat exist $t        "
    echo "--------------------------"
  else
    echo "--------------------------"
    echo "-->Start tomcat pls wait  "
    echo "--------------------------"
  sh $CATALINA_HOME/startup.sh
  fi

}

kill_tomcat()
{
  t=`count_tomcat`
  if [ $t -ne 0 ] ;then
    echo "--------------------------"
    echo "-->Tomcat exist $t        "
    echo "-->Stop tomcat"
    echo "--------------------------"
    ps -fu `whoami`  |grep   bootstrap.jar  |  grep $CATALINA_HOME | grep -v grep | awk '{ print $2 }'| xargs kill -9  #2 >/dev/null
    sleep 3
  else
    echo "--------------------------"
    echo "-->Tomcat is Stop .$t     "
    echo "--------------------------"
  fi
  rm -rf $CATALINA_HOME/../work/*
}

tail_logs()
{
  echo "--------------------------"
  echo "-->Tomcat/logs/catalina.out"
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
echo "pls wait 3s"
sleep 3
start_tomcat
check_tomcat
echo "Tomcat is running..."
;;
*)
tomcat_help
;;
esac
}

run_tomcat $1
