################################## 
#	BASS enviroment config file
################################## 

# SHLIB_PATH must has been set before!

################################## 
#	ORACLE��������
################################## 
setenv ORACLE_BASE /u01		                #��ע�ⰴ��ʵ��·����������
setenv ORACLE_HOME $ORACLE_BASE/oracle/app/oracle/product/9.2.0
setenv NLS_LANG "SIMPLIFIED CHINESE_CHINA.ZHS16GBK" # ʹ�õ��ַ�������ע��Ͱ�װOracleʱѡ����ַ�������һ�£�����������⡣
setenv NLS_DATE_FORMAT 'YYYY-MM-DD:HH24:MI:SS'      # ȱʡ���ڸ�ʽ
setenv ORA_NLS32 $ORACLE_HOME/ocommon/nls/admin/data
setenv ORACLE_SID AICBS_MISN					    # ORACLE��sid
setenv dbtype ORACLE9I		   				#ORALCLE�����ݿ�����: ORACLE8I
setenv SHLIB_PATH $ORACLE_HOME/lib32  #:$SHLIB_PATH #ORACLE�����ݶ�̬��淽λ��
set path=( $ORACLE_HOME/bin $path)	   # ORACLE����Ĵ��Ŀ¼

################################## 
#	SYBASE��������
################################## 
unsetenv LANG					#��������ѡ��
setenv SYBASE /home02/syb		#����SYBASE��·�����밴��ʵ��·����������
setenv SYBASE_OCS OCS-12_0
setenv SHLIB_PATH $SYBASE/$SYBASE_OCS/lib:$SHLIB_PATH
set path=($SYBASE/$SYBASE_OCS/bin $path)

################################## 
#	��������ѡ��
################################## 
setenv PROD_PA  /data32/home/yangbin			#�밴��ʵ��·����������
set path=($PROD_PA/center/bin /usr/bin /usr/sbin /sbin /usr/local/bin $path)
setenv SYSINFO_FILE $PROD_PA/center/config/sysinfo
setenv SYS_LOG_PATH $PROD_PA/center/log
setenv SYS_IPC_KEY  200000		#��ο���������ֲ��������

################################## 
#	���ñ���ѡ��
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
