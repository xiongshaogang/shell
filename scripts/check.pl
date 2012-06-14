#!/opt/perl/usr/local/bin/perl -w



	die "用法：$0 配置文件名 输出文件名 执行次数" if( @ARGV < 3 );
	die "不能够打开配置文件：$ARGV[0] 来读取信息！\n" unless( -r $ARGV[0] );
	
	my( $num ) = `ps -ef |grep $0 |grep -v grep |grep $ARGV[0] |wc -l`;
	chop( $num );
	die "相同的监控程序 $0 $ARGV[0] 已经在运行,不能同时运行两个进程！" if(  $num > 1 ); 
	
	$ConfigFile = $ARGV[0];
	$outFile = $ARGV[1];
	$runtimes = $ARGV[2];
	$tempOutFile = "./tempOutFile";
	unlink $tempOutFile;
	do_check ( $ConfigFile );

        rename $tempOutFile, $outFile;
#############################################################
sub do_check {
	my( $configFile ) = @_;

	$logFile = "./moni";
	$logOn = 1;
	$consoleOn = 1;
	$logLevel = 0;

	@logLevels = qw ( <DEBUG> <INFO> <WARNING> <SEVERE> <FATAL> );

	logInitial ( $configFile );
	$uname = `uname`;
	chop( $uname );
	$hostname = `hostname`;
	chop( $hostname );
	diskCheckInitial ( $configFile ) ;
	systemCheckInitial ( $configFile );
	pileupCheckInitial ( $configFile );
	programMoniInitial ( $configFile );
	netCheckInitial ( $configFile );
	databaseCheckInitial ( $configFile );
	fileSeqCheckInitial ( $configFile );
	
	logOutput ( 1, 171000,"监控", "监控进程: $0 被启动。" );
	my( $beginTime ) = 0;
	my( $timeConsume ) = 0;
 
	$beginTime = time ();		
	diskCheck ()         if ($runtimes % 5 ==0 );
	systemCheck ()       if ($runtimes % 1 ==0 );
	pileupCheck ()       if ($runtimes % 5 ==0 );
	programCheck (  )    if ($runtimes % 5 ==0 );
	netCheck ()          if ($runtimes % 5 ==0 );
	databaseCheck ()     if ($runtimes % 5 ==0 );
	fileSeqCheck ()      if ($runtimes % 5 ==0 );
	$timeConsume = time () - $beginTime;
	logOutput ( 1, 171000,"监控", "检测一次消耗时间：$timeConsume 秒。" );

}
#########7.fileSeqCheck#########################################################################
sub fileSeqCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "fileSeqCheck";
	my( $temp );
	my( $fileSeqCheckCount );
	my( $ii );
	my( $jj );
	@fileSeqCheckSet = ();
	
   	$fileSeqCheckCount = getConfig ( $configFile, $session, "fileSeqCheckCount" );
	if( !( $fileSeqCheckCount ) ) {
		logOutput ( 1, 171007, "文件序号", "配置信息：本主机不检测某一文件目录下是否有待处理的文件堆积现象。" );
		return;
	}
	for( $jj = $ii = 0; $ii <= $fileSeqCheckCount; $ii++ ) {
		$temp = getConfig ( $configFile, $session, "fileSeqCheck$ii" );
    	next if( $temp eq "" );
		$fileSeqCheckSet[$jj++] = $temp ;
	}
}
sub fileSeqCheckOne {
	my( @items ) = ();
	my( $temp ) = @_;
	$temp =~ s/;$//;
	@items = split( /;/ ,$temp);
	return if ( @items != 4 )  ;
	open( GET_SEQ, "data_check file $items[0] \"$items[1]\" $items[2] $items[3]|" ) || 
		( logOutput ( 4, 171007, "文件序号", "无法运行操作系统命令 data_check, $! " ) and return );
	while(<GET_SEQ>) {
		chop();
		$temp  = $_;
		logOutput ( 3, 171007, "文件序号", "$temp!" );
	}
	close ( GET_SEQ );
}
sub fileSeqCheck {
	for(  my( $ii ) = 0; $ii < @fileSeqCheckSet; $ii++ ) {
		fileSeqCheckOne ( $fileSeqCheckSet[$ii] );
	}
}
########6.database###################################################################
sub databaseCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "databaseCheck";
	my( $temp );
	my( @Databasespace ) = ();
	my( @warnDatabasePercents ) = ();
	%checkedDatabase = ();

        $dbtype=0;
	$temp = getConfig ( $configFile, $session, "dbtype" );
	if( $temp eq "" ) {
		logOutput ( 2, 171006, "数据库", "配置信息：本主机没有设置数据库类型。" );
		return;
	}
	else {
	  $dbtype=$temp;
	}
	$temp = getConfig ( $configFile, $session, "databasespace" );
	if( $temp eq "" ) {
		logOutput ( 1, 171006, "数据库", "配置信息：本主机不做数据库空间检测。" );
		return;
	}
	else {
		$temp =~ s/;$//;
		@Databasespace = split( /;/, $temp );
	}

	$temp = getConfig ( $configFile, $session, "warnDatabasePercents" );
	$temp =~ s/;$//;
	@warnDatabasePercents = split( /;/, $temp );
	my( $ii );
	for( $ii = 0; $ii < @warnDatabasePercents; $ii++ ) {
		$warnDatabasePercents[$ii] = 90
			if( $warnDatabasePercents[$ii] < 1 || $warnDatabasePercents[$ii] > 99 );
	}
	if( @Databasespace > @warnDatabasePercents ) {
		logOutput ( 2, 171006, "数据库", "配置信息：warnDiskPercents 数量比 fileSystems 少！" );
	}

	for( $ii = int ( @warnDatabasePercents ); $ii < @Databasespace; $ii++ ) {
		$warnDatabasePercents[$ii] = 90;
	}

	for( $ii = 0; $ii < @Databasespace; $ii++ ) {
		$checkedDatabase { $Databasespace[$ii] } = $warnDatabasePercents[$ii];
	}

}
sub dataAndLogMixedCheck {
	my( $databaseName ) = $_[0];
	my( @record ) = @_[1..@_];
	my( $count );

	my( $totalDBSpace ) = 0;
	my( $freeDBSpace ) = 0;
	my( $warnPercent ) = 0;

        $warnPercent=$checkedDatabase { $databaseName };
	for( $count = 0; $count < @record; $count++ ) {
		if( $record[$count] =~ /(\d+\.\d+)\s+MB\s+data\s+and\s+log.*\s+(\d+)/ ) {
			$totalDBSpace += $1;
			$freeDBSpace += $2;
			next;
		}
		if( $record[$count] =~ /(\d+\.\d+)\s+MB\s+data\s+and\s+log.*\s+-(\d+)/ ) {
			$totalDBSpace += $1;
			$freeDBSpace -= $2;
			next;
		}
		last;
	}
	my(  $percent ) = ($totalDBSpace - $freeDBSpace/1024)/$totalDBSpace*100;
	if( $percent > $warnPercent ) { 
		logOutput ( 3, 171006, "数据库", "数据库 $databaseName\'s 空间使用百分比: $percent 已达到报警线！" );
	}
	else {
		logOutput ( 1, 171006, "数据库", "数据库 $databaseName\'s 空间使用百分比: $percent。" );
		logOutput ( 1, 171006, "数据库", "数据库 $databaseName\'s 剩余空间: $freeDBSpace （K）。" );		
	}		

}

sub dataAndLogapartCheck {
	my( $databaseName ) = $_[0];
	my( @record ) = @_[1..@_];
	my( $count );

	my( $totalLogSpace ) = 0;
	my( $usedLogSpace ) = 0;
	my( %devTotal ) = ();
	my( %devFree ) = ();
	my( %segmentTotal ) = ();
	my( %segmentFree ) = ();
	my( $warndatabasePercent ) = 0;

        $warndatabasePercent=$checkedDatabase { $databaseName };

	for( $count = 0; $count < @record; $count++ ) {
		last unless( defined $record[$count] );
		if( $record[$count] =~
				/(\S+)\s+(\d+\.\d+)\s+MB\s+data\s+only.*\s+(\d+)/ ) {
#				/(\S+)\s+(\d+\.\d+)\s+MB\s+data\s+only\s+(\d+)/ ) {
			$devTotal{ $1 } = $2;
			$devFree{ $1 } = $3;
			next;
		}
		elsif( $record[$count] =~ /(\d+\.\d+)\s+MB\s+log\s+only/ ) {
			$totalLogSpace += $1;
			next;
		}
		elsif( $record[$count] =~ /log\s+only\s+free\s+kbytes\s+=\s+(\d+)/ ) {
			$freeLogSpace = $1;
			next;
		}
		elsif( $record[$count] =~ /device\s+segment/ ) {
			$count += 2;
			last;
		}
	}
	for( ; $count < @record; $count++ ) {
		last unless( defined $record[$count] );
		if( $record[$count] =~ /^\s*(\S+)\s+(\S+)\s+$/ ) {
			next if( $2 eq "system" );
#			last if( $2 eq "logsegment" );
			if( $segmentTotal{ $2 } ) {
				$segmentTotal{ $2 } += $devTotal{ $1 };
				$segmentFree{ $2 } += int( $devFree{ $1 }/1024 );
			}
			else{
				$segmentTotal{ $2 } = $devTotal{ $1 };
				$segmentFree{ $2 } = int( $devFree{ $1 }/1024 );
			}
		}
	}

	foreach $key( keys %segmentTotal ) {
		$percent = int(($segmentTotal{$key} - $segmentFree{$key})/$segmentTotal{$key}*100);
		if( $percent >= $warnDatabasePercent ) {
			logOutput ( 3, 171006, "数据库", "数据库$databaseName 的 $key 段空间使用百分比：$percent% 已达到告警线！" );
			logOutput ( 3, 171006, "数据库", "数据库$databaseName 的 $key 段剩余空间为: $segmentFree{$key}（K）。" );
		}
		else {
			logOutput ( 1, 171006, "数据库", "数据库$databaseName 的 $key 段空间使用百分比：$percent%。" );
			logOutput ( 1, 171006, "数据库", "数据库$databaseName 的 $key 段剩余空间为: $segmentFree{$key}（K）" );
		}
	}
	$percent = int(($totalLogSpace - $freeLogSpace/1024)/$totalLogSpace*100);
	if( $percent >= $warnDatabasePercent ) {
		logOutput ( 3, 171006, "数据库", "数据库 $databaseName 的日志段已使用百分比: $percent 已达到告警线！" );
		logOutput ( 3, 171006, "数据库", "数据库$databaseName 的日志段剩余空间为: $freeLogSpace（K）。" );
	}
	else {
		logOutput ( 1, 171006, "数据库", "数据库 $databaseName 的日志段已使用百分比: $percent。" );
		logOutput ( 1, 171006, "数据库", "数据库$databaseName 的日志段剩余空间为: $freeLogSpace（K）。" );
	}		
}

sub databaseSpaceCheck {
	my( $databaseName ) = @_;
	my( @record ) = ();
	my( $count ) = 0;

	open( GET_SYB_DB, "data_check database $databaseName|" ) || 
		( logOutput ( 4, 171006, "数据库", "无法运行操作系统命令 data_check, $! " ) and return );
	while(<GET_SYB_DB>) {
		$record[$count++] = $_;
		last if( /return\s+status/ );
	}
	close ( GET_SYB_DB );
	if( $record[@record-1] !~ /return\s+status\s+=\s+0/ ) {
		logOutput ( 2, 171006,  "数据库", "对数据库sp_helpdb $databaseName异常！" );
		for( $count = 0; $count < @record; $count++ ) {
			logOutput ( 0, 171006, "数据库", "$record[$count]" );
		}
		return;
	}
	for( $count = 7; $count < @record-1; $count++ ) {
		if( $record[$count] =~ /(\d+\.\d+)\s+MB\s+data\s+and\s+log/ ) {
			dataAndLogMixedCheck ( $databaseName, @record[$count...@record-1] );
			last;
		}
		elsif( $record[$count] =~ /(\d+\.\d+)\s+MB\s+data\s+only/ ) {
			dataAndLogapartCheck ( $databaseName, @record[$count...@record-1] );
			last;
		}
	}
}
sub checkDBUsedSpace {

	my( $database );
	foreach $database ( keys ( %checkedDatabase ) ) {
		databaseSpaceCheck ( $database );
	}
}
sub databaseCheckSYB {
	
	checkDBUsedSpace ();
}
sub databaseCheckORA {
	my( @items ) = ();
	my( $databasename ) = "";
	my( $warndatabasePercent ) = 0;
	open( GET_DB, "data_check database|" ) || 
		( logOutput ( 4, 171006, "数据库", "无法运行操作系统命令 data_check, $! " ) and return );
	while(<GET_DB>) {
		@items = split (/\s+/);
		$databasename = $items[0];
		$warndatabasePercent = $checkedDatabase { $databasename };
		next unless ( $warndatabasePercent );
		if( $items[4] >= $warndatabasePercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171006, "数据库", "数据库表空间 \'$databasename\' 已满!" );
			}
			else {
				logOutput ( 3, 171006, "数据库", "数据库表空间 \'$databasename\' 已使用$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171006, "数据库", "文件系统 \'$databasename\' 已使用$items[4]\%。" );
		}
	}
	close ( GET_DB );
}
sub databaseCheck {
        
        return if( $dbtype == 0 );
	return if( int( keys %checkedDatabase ) == 0 );

        if ($dbtype == 2) {
        	databaseCheckSYB();
	}
	else {
        	databaseCheckORA();
	}

	
}
###########################################################################
## 1.net check
#
sub netCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "netCheck";
	my( $temp );
	@ipAddresses = ();

	$temp = getConfig ( $configFile, $session, "ipAddresses" );
	if( $temp eq "" ) {
		logOutput ( 1, 171001,"网络监测", "配置信息：本主机不进行网络阻塞情况监测！" );
		return;
	}
	else {
		$temp =~ s/;$//;
		@ipAddresses = split( /;/, $temp );
	}

	$temp = getConfig ( $configFile, $session, "netTimeOut" );
	if( $temp eq "" ) {
		logOutput ( 1, 171001,"网络监测", "配置信息：设置：netTimeOut = 1，即一秒钟之内网络不通即算网络阻塞。" );
		$netTimeOut = 1;
	}
	else {
		$netTimeOut = $temp;
	}
}

sub netCheck {
	return if( @ipAddresses == 0 );

	foreach $ipAddress ( @ipAddresses ) {
		pingIdAddress ( $ipAddress );
	}
}

sub pingIdAddress {
	my( $theAddress ) = @_;
	my( $cmd );
	if( $uname eq "AIX" ) {
		$cmd = "/usr/sbin/ping -c 1 -w $netTimeOut $theAddress";
	}
	elsif( $uname eq "HP-UX" ){
		$cmd = "/usr/sbin/ping $theAddress  -n 1 ";
	}
	elsif( $uname eq "SunOS" ){
		$cmd = "/usr/sbin/ping $theAddress  56 1 ";
	}
	else {
		$cmd = "/usr/sbin/ping -c 1 -t $netTimeOut $theAddress";
	}
	open( PING_O, "$cmd|" ) ||
		( logOutput ( 4, 171001, "网络监测", "无法运行 ping, $! " ) && return );

	while( <PING_O> ) {
		if( /(\d+)\%\s+packet\s+loss/ ) {
			if( $1 > 0 ) {
				if( $1 == 100 ) {
					logOutput ( 3, 171001, "网络监测", "本主机到 $theAddress 网络阻塞！" );
				}
				else {
					logOutput ( 2, 171001, "网络监测", "本主机到 $theAddress 网络不良,loss=$1！" );
				}
			}
			last;
		}
	}
	close ( PING_O );
}
###########################################################################
#
## 5.programes monitor
#
sub programMoniInitial {
	my( $configFile ) = $_[0];
	my( $session ) = "programMoni";
	my( $temp );
	my( $ii ) = my( $jj );

   	$temp = getConfig ( $configFile, $session, "warnPCPUPercent" );
	if( $temp eq "" ) {
		logOutput ( 1, 171005, "进程监控", "配置信息：设置warnPCPUPercent=5即单个进程CPU使用超过5%时，将告警" );
		$warnPCPUPercent = 5;
	}
	else {
		$warnPCPUPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnPMemoryPercent" );
	if( $temp eq "" ) {
		logOutput ( 1, 171005, "进程监控", "配置信息：设置warnPMemoryPercent=5即单个进程内存使用超过5%时，将告警" );
		$warnPMemoryPercent = 5;
	}
	else {
		$warnPMemoryPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnPMemoryAmount" );
	if( $temp eq "" ) {
		logOutput ( 1, 171005, "进程监控", "配置信息：设置warnPMemoryAmount=5即单个进程使用量超过5M时，将告警" );
		$warnPMemoryAmount = 5;
	}
	else {
		$warnPMemoryAmount = $temp;
		
	}
	$warnPMemoryAmount *= 1024 if( $uname eq "AIX" || $uname eq "HP-UX");


}

sub programCheck {
	my( @items );
	my( $cmd );
	my( $pscmd );
		
	if( $uname eq "HP-UX" ) {
		$pscmd = "UNIX95= ps -o \"pcpu vsz vsz args\" -A|" ;
 	}
	else {
		$pscmd = "ps -o \"pcpu pmem vsz args\" -A|" ;
	}
	open( GET_PS, $pscmd ) || 
		( logOutput ( 4, 171005, "进程监控", "无法运行操作系统命令 $pscmd, $! " ) and return );
	
	<GET_PS>;
	while(<GET_PS>) {
		chop();
		@items = split (/\s+/);
		shift @items if( $items[0] eq "" );
		if( $uname eq "OSF1" || $uname eq "SunOS" ) {
			next if( (int @items < 4 ) || ( $items[3] eq "\[kernel" ) );
		}
		elsif( $uname eq "AIX" ) {
			next if( (int @items < 4 ) || ( $items[3] eq "wait" ) );
		}
		logOutput ( 2, 171005, "进程监控", "进程：".$items[3]."的CUP占用率达到：".$items[0]."\%! " )
			if( $items[0] > $warnPCPUPercent );
		if( $uname ne "HP-UX" )
		{
		logOutput ( 2, 171005, "进程监控", "进程：".$items[3]."的内存占用率达到：".$items[1]."\%！" )
			if( $items[1] > $warnPMemoryPercent );
		}
		if( $uname eq "OSF1" || $uname eq "SunOS" ) {
			if( $items[2] =~ /(\d.*)M/ ) {
				logOutput ( 2, 171005, "进程监控", "进程：".$items[3]."的内存占用量达到：".$items[2]."！" ) if( $1 > $warnPMemoryAmount );
			}
			elsif( $items[2] =~ /(\d.*)G/ ) {
				logOutput ( 2, 171005, "进程监控", "进程：".$items[3]."的内存占用量达到：".$items[2]."！" ) if( 1024 * $1 > $warnPMemoryAmount );
			}
			else {
				next; # omit K level process.
			}
 		}
		elsif( $uname eq "AIX" || $uname eq "HP-UX") {
			logOutput ( 2, 171005, "进程监控", "进程：".$items[3]."的内存占用量达到：".$items[2]."K！" )
			if( $items[2] > $warnPMemoryAmount );
		}
	}
	close( GET_PS );
}

#######4.file####################################################################
sub pileupCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "pileupCheck";
	my( $temp );
	my( $maxDisposedDirNo );
	my( $ii );
	my( $jj );
	@disposedDir = ();
	
   	$maxDisposedDirNo = getConfig ( $configFile, $session, "maxDisposedDirNo" );
	if( !( $maxDisposedDirNo ) ) {
		logOutput ( 1, 171004, "数据积压", "配置信息：本主机不检测某一文件目录下是否有待处理的文件堆积现象。" );
		return;
	}

   	$temp = getConfig ( $configFile, $session, "warnPileupNumber" );
	if( $temp eq "" ) {
		logOutput ( 1, 171004, "数据积压", "配置信息：设置：warnPileupNumber = 10，即当某一目录下的文件数到达10个时将报警。" );
		$warnPileupNumber = 10;
	}
	else {
		$warnPileupNumber = int($temp);
		if( $warnPileupNumber < 3 ) {
			logOutput ( 2, 171004, "数据积压", "配置信息：参数: warnPileupNumber = $warnPileupNumber 太小。" );
			logOutput ( 1, 171004, "数据积压", "配置信息：重设 warnPileupNumber = 3，即当某一目录下的文件数到达3个时将报警。" );
			$warnPileupNumber = 3;
		}
		elsif( $warnPileupNumber > 100 ) {
			logOutput ( 2, 171004, "数据积压", "配置信息：参数: warnPileupNumber = $warnPileupNumber 太大." );
			logOutput ( 1, 171004, "数据积压", "配置信息：重设 warnPileupNumber = 100，即当某一目录下的文件数到达100个时将报警。" );
			$warnPileupNumber = 100;
		}
	}
	
	for( $jj = $ii = 0; $ii <= $maxDisposedDirNo; $ii++ ) {
		$temp = getConfig ( $configFile, $session, "disposedDir$ii" );
    	next if( $temp eq "" );
		$disposedDir[$jj++] = $temp if( directoryExistCheck ( $temp ) );
	}
	if( $jj == 0 ) {
		return;
	}
	else {
	}
}
sub pileupCheck {
	for( my( $num ) = my( $ii ) = 0; $ii < @disposedDir; $ii++ ) {
		$num = onePileupCheck ( $disposedDir[$ii] );
		if( $num >= $warnPileupNumber ) {
			logOutput ( 2, 171004, "数据积压", "有 $num 个文件在 $disposedDir[$ii] 目录下未被处理！" );
		}
		else {
			logOutput ( 0, 171004, "数据积压", "有 $num 个文件在 $disposedDir[$ii] 目录下。" );
		}
	}
}
sub onePileupCheck {
	my( $theDir ) = @_;
	my( $num ) = 0;
	my( $name ) = 0;
	my( $fullName ) = 0;

	opendir( DIR, $theDir );
	my( @fileList ) = readdir( DIR );
	closedir( DIR );
	
	foreach $name ( @fileList ) {
		next if( $name =~ /^\..*/ );
		next if( $name =~ /^_/ );
		$fullName = "$theDir/$name";
		if( -d $fullName ) {
			$num += onePileupCheck ( $fullName );
		}
		else {
			$num++;
		}
	}
	return $num;
}
#
#######################################################################################
#
## 3. System CPU, memory and IO wait Check
#
sub systemCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "systemCheck";
	my( $temp );

   	$temp = getConfig ( $configFile, $session, "warnTCPUPercent" );
	if( $temp eq "" ) {
		logOutput ( 1, 171003, "CPU内存", "配置信息：本主机不做整机CPU、内存和IOwait检测。" );
		return;
	}
	else {
		$warnTCPUPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnTMemoryPercent" );
	if( $temp eq "" ) {
		$warnTMemoryPercent = 90;
	}
	else {
		$warnTMemoryPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnIOWaitPercent" );
	if( $temp eq "" ) {
		$warnIOWaitPercent = 10;
	}
	else {
		$warnIOWaitPercent = $temp;
	}
}

sub systemCheck {
	return unless( defined( $warnTCPUPercent ) );
	
	if( $uname eq "OSF1" ) {
		systemCheckOSF1 ();
 	}
	elsif( $uname eq "AIX" ) {
		systemCheckAIX ();
	}
	elsif( $uname eq "SunOS" ) {
		systemCheckSunOS ();
	}
	elsif( $uname eq "HP-UX" ) {
		systemCheckHPUX ();
	}
}

sub systemCheckSunOS {
}
sub systemCheckHPUX {
	open( VM, "vmstat 1 2|" ) || 
		( logOutput ( 4, 171003, "CPU内存", "无法运行操作系统命令 vmstat 1 2, $! " ) and return );

	my( $ii ) = 0;
	while(<VM>) {
		last if( ++$ii == 4);
	}
	chop;
	close( VM );
	my( @items ) = split (/\s+/);
	my( $total ) = ( $items[4] * 100 )/($items[4] + $items[5] );

	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	$total = 100 - $items[18];
	if( $total > $warnTMemoryPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	open( IOSTAT, "iostat -t 1 2|" ) || 
		( logOutput ( 4, 171003, "系统IO", "无法运行操作系统命令 iostat 1 2, $! " ) and return );

	$ii = 0;
	while(<IOSTAT>) {
		chop();
		@items = split (/\s+/);
		$total = @items;
                $ii++ if( $total == 7 );
		last if( $ii == 4 );
	}
	close( IOSTAT );
	$total = 100 - $items[6];
	if( $total > $warnIOWaitPercent ) {
		logOutput ( 2, 171003, "系统IO", "系统IOwait率达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "系统IO", "系统IOwait率达到 $total\%!" );
	}
}


sub systemCheckAIX {
	open( VM, "vmstat 1 2|" ) || 
		( logOutput ( 4, 171003, "CPU内存", "无法运行操作系统命令 vmstat 1 2, $! " ) and return );

	my( $ii ) = 0;
	while(<VM>) {
		last if( ++$ii == 5);
	}
	close( VM );
	chop;
	my( @items ) = split (/\s+/);
	my( $total ) = ( $items[3] * 100 )/($items[3] + $items[4] );
	
	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	$total = 100 - $items[16];
	if( $total > $warnTMemoryPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	open( IOSTAT, "iostat -t 1 4|" ) || 
		( logOutput ( 4, 171003, "CPU内存", "无法运行操作系统命令 iostat 1 2, $! " ) and return );
	$ii = 0;
	while(<IOSTAT>) {
		last if( ++$ii == 6 );
	}
	close( IOSTAT );
	chop;
	@items = split (/\s+/);
	if( $items[6] > $warnIOWaitPercent ) {
		logOutput ( 2, 171003, "系统IO", "系统IOwait率达到 $items[6]\%!" );
	}
	else {
		logOutput ( 1, 171003, "系统IO", "系统IOwait率达到 $items[6]\%!" );
	}
}

sub systemCheckOSF1 {
	open( VM, "vmstat -w 1 2|" ) || 
		( logOutput ( 4, 171003, "CPU内存", "无法运行操作系统命令 vmstat -w 1 2, $! " ) and return );
	my( $ii ) = 0;
	while(<VM>) {
		last if( ++$ii == 5);
	}
	close( VM );
	chop;
	my( $act );
	my( $free );

	my( @items ) = split (/\s+/);
	if( $items[4] =~ /(\d+)M/ ) {
		$act = 1048576*$1;
	}
	elsif( $items[4] =~ /(\d+)K/ ) {
		$act = 1024*$1;
	}
	elsif( $items[4] =~ /(\d+)/ ) {
		$act = 1024*$1;
	}
	if( $items[5] =~ /(\d+)M/ ) {
		$free = 1048576*$1;
	}
	elsif( $items[5] =~ /(\d+)K/ ) {
		$free = 1024*$1;
	}
	elsif( $items[5] =~ /(\d+)/ ) {
		$free = 1024*$1;
	}
	my( $total ) = ( $act * 100 )/($act + $free );
	
	if( $total > $warnTMemoryPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统内存占用率已经达到 $total\%!" );
	}
	$total = 100 - $items[16];
	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU内存", "系统CPU占用率已经达到 $total\%!" );
	}
	if( $items[17] > $warnIOWaitPercent ) {
		logOutput ( 2, 171003, "系统IO", "系统IOwait率达到 $items[17]\%!" );
	}
	else {
		logOutput ( 1, 171003, "系统IO", "系统IOwait率达到 $items[17]\%!" );
	}
}
########2.disk##########################################################################
sub diskCheckInitial {
	my( $configFile ) = @_;
	my( $session ) = "diskCheck";
	my( $temp );
	my( @fileSystems ) = ();
	my( @warnDiskPercents ) = ();
	%checkedDisk = ();

	$temp = getConfig ( $configFile, $session, "fileSystems" );
	if( $temp eq "" ) {
		logOutput ( 1, 171002, "硬盘空间", "配置信息：本主机不做文件系统检测。" );
		return;
	}
	else {
		$temp =~ s/;$//;
		@fileSystems = split( /;/, $temp );
	}

	$temp = getConfig ( $configFile, $session, "warnDiskPercents" );
	$temp =~ s/;$//;
	@warnDiskPercents = split( /;/, $temp );
	my( $ii );
	for( $ii = 0; $ii < @warnDiskPercents; $ii++ ) {
		$warnDiskPercents[$ii] = 90
			if( $warnDiskPercents[$ii] < 1 || $warnDiskPercents[$ii] > 99 );
	}
	if( @fileSystems > @warnDiskPercents ) {
		logOutput ( 2, 171002, "硬盘空间", "配置信息：warnDiskPercents 数量比 fileSystems 少！" );
	}

	for( $ii = int ( @warnDiskPercents ); $ii < @fileSystems; $ii++ ) {
		$warnDiskPercents[$ii] = 90;
	}

	for( $ii = 0; $ii < @fileSystems; $ii++ ) {
		$checkedDisk { $fileSystems[$ii] } = $warnDiskPercents[$ii];
	}
}
sub diskCheck {
	return if( int( keys %checkedDisk ) == 0 );
	
	if( $uname eq "OSF1" ) {
		diskCheckOSF1 ();
 	}
	elsif( $uname eq "AIX" ) {
		diskCheckAIX ();
	}
	elsif( $uname eq "SunOS" ) {
		diskCheckSunOS ();
	}
	elsif( $uname eq "HP-UX" ) {
		diskCheckHPUX ();
	}
}
sub diskCheckHPUX {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "bdf|" ) || 
		( logOutput ( 4, 171002, "硬盘空间", "无法运行操作系统命令 bdf, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[5];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已满!" );
			}
			else {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%。" );
		}
	}
	close ( GET_DF );
}

sub diskCheckSunOS {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -k|" ) || 
		( logOutput ( 4, 171002, "硬盘空间", "无法运行操作系统命令 df -k, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[5];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已满!" );
			}
			else {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%。" );
		}
	}
	close ( GET_DF );
}

sub diskCheckAIX {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -i|" ) || 
		( logOutput ( 4, 171002, "硬盘空间", "无法运行操作系统命令 df -i, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[6];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[3] =~ s/%//;
		$items[5] =~ s/%//;
		if( $items[3] >= $warnDiskPercent ) {
			if( $items[3] >= 100 ) {
				logOutput ( 4, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已满！" );
			}
			else {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[3]\%！" );
			}
		}
		else {
			logOutput ( 1, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[3]\%。" );
		}
		if( $items[5] >= $warnDiskPercent ) {
			if( $items[5] >= 100 ) {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经用完！" );
			}
			else {
				logOutput ( 2, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经达到：$items[5]\%！" );
			}
		}
		else {
			logOutput ( 1, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经达到$items[5]\%。" );
		}
	}
	close ( GET_DF );
}

sub diskCheckOSF1 {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -i|" ) || 
		( logOutput ( 4, 171002, "硬盘空间", "无法运行操作系统命令 df -i, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[8];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		$items[7] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已满！" );
			}
			else {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%！" );
			}
		}
		else {
			logOutput ( 0, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 已使用$items[4]\%。" );
		}
		if( $items[7] >= $warnDiskPercent ) {
			if( $items[7] >= 100 ) {
				logOutput ( 4, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经用完!" );
			}
			else {
				logOutput ( 3, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经达到：$items[7]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "硬盘空间", "文件系统 \'$fileSystem\' 节点数已经达到$items[7]\%。" );
		}
	}
	close ( GET_DF );
}

sub getConfig {
	my( $configFile, $sessionName, $configName ) = @_;
	my( $sessionFind ) = 0;
	my( $temp ) = "";

	open (INP, "<$configFile" )
		or ( logOutput ( 4, 171002, "监控", "不能够打开配置文件：$configFile 来读取信息！" )
			and exit 1 );

	while (<INP>) {
		if( $sessionFind == 0 ) {
			$sessionFind = 1 if( /^\s*\[\s*$sessionName\s*\]/ );
			next;
		}
		last if( /^\s*\[/ );
		next unless( /^\s*$configName\s*=(.*)/ );
		close (INP);
		$temp = $1;
		$temp =~ s/^\s+//;
		$temp =~ s/\s+$//;
		return $temp;
	}
	close (INP);
	return "";
}
#################################################################################
sub logInitial {
	my( $configFile ) = @_;
	my( $session ) = "log";
	my( $temp );

	$temp = getConfig ( $configFile, $session, "logFile" );
	if( $temp eq "" ) {
		print "配置文件中未配置 [log]=>logFile。\n";
		print " 设置：logFile = $logFile，即日志文件名头为：$logFile。\n";
	}
	else {
		$logFile = $temp;
	}

	$temp = getConfig ( $configFile, $session, "logLevel" );
	if( $temp eq "" ) {
		print "监控配置文件中未配置 [log]=>logLevel。\n";
		print "设置：logLevel = INFO_LEVEL，即设置日志输出详细度为：$logLevels[1]。\n";
		$logLevel = 1;
	}
	else {
		if( $temp eq "DEBUG_LEVEL" ) {
			$logLevel = 0;
		}
		elsif( $temp eq "INFO_LEVEL" ) {
			$logLevel = 1;
		}
		elsif( $temp eq "WARN_LEVEL" ) {
			$logLevel = 2;
		}
		elsif( $temp eq "SEVERE_LEVEL" ) {
			$logLevel = 3;
		}
		elsif( $temp eq "FATAL_LEVEL" ) {
			$logLevel = 4;
		}
	}
	
	$temp = getConfig ( $configFile, $session, "logOn" );
	if( $temp eq "" ) {
		print "配置文件中没有配置[log]=>logOn。\n";
		print "设置：logOn = TRUE，即输出日志文件。\n";
		$logOn = 1;
	}
	else {
		if( $temp =~ /true/i ) {
			$logOn = 1;
		}
		else {
			$logOn = 0;
		}
	}
	
	$temp = getConfig ( $configFile, $session, "consoleOn" );
	if( $temp eq "" ) {
		print "配置文件中没有配置：[log]=>consoleOn。\n";
		print "设置： consoleOn = TRUE，即将日志在屏幕输出。\n";
		$consoleOn = 1;
	}
	else {
		if( $temp =~ /true/i ) {
			$consoleOn = 1;
		}
		else {
			$consoleOn = 0;
		}
	}
}

sub logOutput {
	my( $iLogLevel ) = shift @_;
	my( $iMsgCode ) = shift @_;
	my( $model ) = shift @_;

	return 1 if( $iLogLevel < $logLevel );

	my ($sec,$min,$hour,$mday,$mon,$year) = localtime();
	$mon++;

	my( $YYYYMMDD ) = sprintf( "%02d%02d%02d", $year - 100, $mon, $mday );
	my( $yyyymmdd2) = sprintf ("%d-%02d-%02d", $year + 1900 ,$mon, $mday);
	my( $HHMMSS ) = sprintf( "%02d:%02d:%02d", $hour, $min, $sec );

	if( $consoleOn ) {
		print "$yyyymmdd2 $HHMMSS $logLevels[$iLogLevel] ";
		print @_;
		print "\n";
	}
	
	return 1 if( $logOn == 0 );

	my( $theFile ) = $logFile.".".$YYYYMMDD;

	open (EXP, ">>$theFile" )
		or die "不能打开日志文件：$theFile 写日志！";

	print EXP "$yyyymmdd2 $HHMMSS $logLevels[$iLogLevel] ";
	print EXP @_;
	print EXP "|\n";

	close (EXP);
	
	if( $tempOutFile && $iLogLevel >= 1 ) {
		open (EXP, ">>$tempOutFile" )
			or die "不能打开入库系统信息文件：$tempOutFile 写入库系统信息！";

		print EXP "$hostname|$iLogLevel|$yyyymmdd2 $HHMMSS|$iMsgCode|$model|";
		print EXP @_;
		print EXP "|\n";
        	close (EXP);
	}	
		
	return 1;
}
sub logConfigInfo {
	my( $level, $session, $configName ) = @_;
}
sub directoryExistCheck {
	my( $theDir ) = @_;

	if( !( -e $theDir && -d $theDir ) ) {
		logOutput ( 3, 171004,"监控", "不存在目录名为 $theDir 的目录！" );
		return 0;
	}
	return 1;
}

