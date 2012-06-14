#!/bin/sh

tomcat_help(){
echo "================================================"
echo "please input Num                               ="
echo "=Simple employee salary managerment sysetem    ="
echo "=1.Check tomcat run 		             		 ="
echo "=2.Start tomcat                      	         ="
echo "=3.Quit tomcat                                 ="
echo "=4.Tail tomcat logs                            ="
echo "================================================"
}

check_tomcat()
{

  ps -ef | grep tomcat | grep 8012
  
}

start_tomcat()
{
	sh startup.sh
}

kill_tomcat()
{
	ps -ef | grep tomcat | grep 8012 | grep -v grep | awk '{ print $2 }'| xargs kill -9
}

tail_logs()
{
	tail -f ../logs/catalina.out
}	

run_tomcat()
{
case $1 in
1)
echo "check tomcat info......"
check_tomcat
;;
2) echo "Start tomcat please waiting..."
start_tomcat
;;
3) echo "tomcat port:8011 service is stop"
kill_tomcat
;;
4) echo "tail tomcat logs "
tail_logs
;;
*)
tomcat_help
;;
esac
}

run_tomcat $1
