################################## 
#	BASS enviroment config file
################################## 

# SHLIB_PATH must has been set before!

################################## 
#	ORACLE环境变量
################################## 
setenv ORACLE_BASE /u01		                #请注意按照实际路径进行设置
setenv ORACLE_HOME $ORACLE_BASE/oracle/app/oracle/product/9.2.0
setenv NLS_LANG "SIMPLIFIED CHINESE_CHINA.ZHS16GBK" # 使用的字符集，请注意和安装Oracle时选择的字符集保持一致，否则会有问题。
setenv NLS_DATE_FORMAT 'YYYY-MM-DD:HH24:MI:SS'      # 缺省日期格式
setenv ORA_NLS32 $ORACLE_HOME/ocommon/nls/admin/data
setenv ORACLE_SID AICBS_MISN					    # ORACLE的sid
setenv dbtype ORACLE9I		   				#ORALCLE的数据库类型: ORACLE8I
setenv SHLIB_PATH $ORACLE_HOME/lib32  #:$SHLIB_PATH #ORACLE的数据动态库存方位置
set path=( $ORACLE_HOME/bin $path)	   # ORACLE命令的存放目录

################################## 
#	SYBASE环境变量
################################## 
unsetenv LANG					#设置语言选项
setenv SYBASE /home02/syb		#设置SYBASE主路径，请按照实际路径进行设置
setenv SYBASE_OCS OCS-12_0
setenv SHLIB_PATH $SYBASE/$SYBASE_OCS/lib:$SHLIB_PATH
set path=($SYBASE/$SYBASE_OCS/bin $path)

################################## 
#	设置运行选项
################################## 
setenv PROD_PA  /data32/home/yangbin			#请按照实际路径进行设置
set path=($PROD_PA/center/bin /usr/bin /usr/sbin /sbin /usr/local/bin $path)
setenv SYSINFO_FILE $PROD_PA/center/config/sysinfo
setenv SYS_LOG_PATH $PROD_PA/center/log
setenv SYS_IPC_KEY  200000		#请参考任务管理手册进行设置

################################## 
#	设置编译选项
################################## 
setenv USER `whoami`
set prompt=`hostname`-$USER%
setenv HOME /data32/home/yangbin
setenv AICBS $HOME/work/bass

setenv SHLIB_PATH $PROD_PA/center/lib:$SHLIB_PATH
set path=( . $PROD_PA/center/bin $path)
setenv ORA9 1
#setenv SYB 1
#setenv DEBUG 1
setenv HPUX 1
