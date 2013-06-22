#!/bin/bash
#
# /etc/rc.d/init.d/tomcat
# init script for tomcat precesses
#
# description:  Start up the Tomcat servlet engine.
if [ -f /etc/init.d/functions ]; then
        . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
        . /etc/rc.d/init.d/functions
else
        echo -e "\atomcat: unable to locate functions lib. Cannot continue."
        exit -1
fi
RETVAL=$?
CATALINA_HOME="/home/mas/eie/opt/apache-tomcat8011"
case "$1" in
start)
        if [ -f $CATALINA_HOME/bin/startup.sh ];
          then
            echo $"Starting Tomcat"
            sh $CATALINA_HOME/bin/startup.sh
        fi
        ;;
stop)
        if [ -f $CATALINA_HOME/bin/shutdown.sh ];
          then
            echo $"Stopping Tomcat"
            sh $CATALINA_HOME/bin/shutdown.sh
		  else
		    ps -ef | grep tomcat | grep $CATALINA_HOME | grep -v grep | awk '{ print $2 }'| xargs kill -9
        fi
        ;;
*)
        echo $"Usage: $0 {start|stop}"
        exit 1
        ;;
esac
exit $RETVAL