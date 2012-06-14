#!/opt/perl/usr/local/bin/perl -w



	die "�÷���$0 �����ļ��� ����ļ��� ִ�д���" if( @ARGV < 3 );
	die "���ܹ��������ļ���$ARGV[0] ����ȡ��Ϣ��\n" unless( -r $ARGV[0] );
	
	my( $num ) = `ps -ef |grep $0 |grep -v grep |grep $ARGV[0] |wc -l`;
	chop( $num );
	die "��ͬ�ļ�س��� $0 $ARGV[0] �Ѿ�������,����ͬʱ�����������̣�" if(  $num > 1 ); 
	
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
	
	logOutput ( 1, 171000,"���", "��ؽ���: $0 ��������" );
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
	logOutput ( 1, 171000,"���", "���һ������ʱ�䣺$timeConsume �롣" );

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
		logOutput ( 1, 171007, "�ļ����", "������Ϣ�������������ĳһ�ļ�Ŀ¼���Ƿ��д�������ļ��ѻ�����" );
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
		( logOutput ( 4, 171007, "�ļ����", "�޷����в���ϵͳ���� data_check, $! " ) and return );
	while(<GET_SEQ>) {
		chop();
		$temp  = $_;
		logOutput ( 3, 171007, "�ļ����", "$temp!" );
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
		logOutput ( 2, 171006, "���ݿ�", "������Ϣ��������û���������ݿ����͡�" );
		return;
	}
	else {
	  $dbtype=$temp;
	}
	$temp = getConfig ( $configFile, $session, "databasespace" );
	if( $temp eq "" ) {
		logOutput ( 1, 171006, "���ݿ�", "������Ϣ���������������ݿ�ռ��⡣" );
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
		logOutput ( 2, 171006, "���ݿ�", "������Ϣ��warnDiskPercents ������ fileSystems �٣�" );
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
		logOutput ( 3, 171006, "���ݿ�", "���ݿ� $databaseName\'s �ռ�ʹ�ðٷֱ�: $percent �Ѵﵽ�����ߣ�" );
	}
	else {
		logOutput ( 1, 171006, "���ݿ�", "���ݿ� $databaseName\'s �ռ�ʹ�ðٷֱ�: $percent��" );
		logOutput ( 1, 171006, "���ݿ�", "���ݿ� $databaseName\'s ʣ��ռ�: $freeDBSpace ��K����" );		
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
			logOutput ( 3, 171006, "���ݿ�", "���ݿ�$databaseName �� $key �οռ�ʹ�ðٷֱȣ�$percent% �Ѵﵽ�澯�ߣ�" );
			logOutput ( 3, 171006, "���ݿ�", "���ݿ�$databaseName �� $key ��ʣ��ռ�Ϊ: $segmentFree{$key}��K����" );
		}
		else {
			logOutput ( 1, 171006, "���ݿ�", "���ݿ�$databaseName �� $key �οռ�ʹ�ðٷֱȣ�$percent%��" );
			logOutput ( 1, 171006, "���ݿ�", "���ݿ�$databaseName �� $key ��ʣ��ռ�Ϊ: $segmentFree{$key}��K��" );
		}
	}
	$percent = int(($totalLogSpace - $freeLogSpace/1024)/$totalLogSpace*100);
	if( $percent >= $warnDatabasePercent ) {
		logOutput ( 3, 171006, "���ݿ�", "���ݿ� $databaseName ����־����ʹ�ðٷֱ�: $percent �Ѵﵽ�澯�ߣ�" );
		logOutput ( 3, 171006, "���ݿ�", "���ݿ�$databaseName ����־��ʣ��ռ�Ϊ: $freeLogSpace��K����" );
	}
	else {
		logOutput ( 1, 171006, "���ݿ�", "���ݿ� $databaseName ����־����ʹ�ðٷֱ�: $percent��" );
		logOutput ( 1, 171006, "���ݿ�", "���ݿ�$databaseName ����־��ʣ��ռ�Ϊ: $freeLogSpace��K����" );
	}		
}

sub databaseSpaceCheck {
	my( $databaseName ) = @_;
	my( @record ) = ();
	my( $count ) = 0;

	open( GET_SYB_DB, "data_check database $databaseName|" ) || 
		( logOutput ( 4, 171006, "���ݿ�", "�޷����в���ϵͳ���� data_check, $! " ) and return );
	while(<GET_SYB_DB>) {
		$record[$count++] = $_;
		last if( /return\s+status/ );
	}
	close ( GET_SYB_DB );
	if( $record[@record-1] !~ /return\s+status\s+=\s+0/ ) {
		logOutput ( 2, 171006,  "���ݿ�", "�����ݿ�sp_helpdb $databaseName�쳣��" );
		for( $count = 0; $count < @record; $count++ ) {
			logOutput ( 0, 171006, "���ݿ�", "$record[$count]" );
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
		( logOutput ( 4, 171006, "���ݿ�", "�޷����в���ϵͳ���� data_check, $! " ) and return );
	while(<GET_DB>) {
		@items = split (/\s+/);
		$databasename = $items[0];
		$warndatabasePercent = $checkedDatabase { $databasename };
		next unless ( $warndatabasePercent );
		if( $items[4] >= $warndatabasePercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171006, "���ݿ�", "���ݿ��ռ� \'$databasename\' ����!" );
			}
			else {
				logOutput ( 3, 171006, "���ݿ�", "���ݿ��ռ� \'$databasename\' ��ʹ��$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171006, "���ݿ�", "�ļ�ϵͳ \'$databasename\' ��ʹ��$items[4]\%��" );
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
		logOutput ( 1, 171001,"������", "������Ϣ���������������������������⣡" );
		return;
	}
	else {
		$temp =~ s/;$//;
		@ipAddresses = split( /;/, $temp );
	}

	$temp = getConfig ( $configFile, $session, "netTimeOut" );
	if( $temp eq "" ) {
		logOutput ( 1, 171001,"������", "������Ϣ�����ã�netTimeOut = 1����һ����֮�����粻ͨ��������������" );
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
		( logOutput ( 4, 171001, "������", "�޷����� ping, $! " ) && return );

	while( <PING_O> ) {
		if( /(\d+)\%\s+packet\s+loss/ ) {
			if( $1 > 0 ) {
				if( $1 == 100 ) {
					logOutput ( 3, 171001, "������", "�������� $theAddress ����������" );
				}
				else {
					logOutput ( 2, 171001, "������", "�������� $theAddress ���粻��,loss=$1��" );
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
		logOutput ( 1, 171005, "���̼��", "������Ϣ������warnPCPUPercent=5����������CPUʹ�ó���5%ʱ�����澯" );
		$warnPCPUPercent = 5;
	}
	else {
		$warnPCPUPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnPMemoryPercent" );
	if( $temp eq "" ) {
		logOutput ( 1, 171005, "���̼��", "������Ϣ������warnPMemoryPercent=5�����������ڴ�ʹ�ó���5%ʱ�����澯" );
		$warnPMemoryPercent = 5;
	}
	else {
		$warnPMemoryPercent = $temp;
	}

   	$temp = getConfig ( $configFile, $session, "warnPMemoryAmount" );
	if( $temp eq "" ) {
		logOutput ( 1, 171005, "���̼��", "������Ϣ������warnPMemoryAmount=5����������ʹ��������5Mʱ�����澯" );
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
		( logOutput ( 4, 171005, "���̼��", "�޷����в���ϵͳ���� $pscmd, $! " ) and return );
	
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
		logOutput ( 2, 171005, "���̼��", "���̣�".$items[3]."��CUPռ���ʴﵽ��".$items[0]."\%! " )
			if( $items[0] > $warnPCPUPercent );
		if( $uname ne "HP-UX" )
		{
		logOutput ( 2, 171005, "���̼��", "���̣�".$items[3]."���ڴ�ռ���ʴﵽ��".$items[1]."\%��" )
			if( $items[1] > $warnPMemoryPercent );
		}
		if( $uname eq "OSF1" || $uname eq "SunOS" ) {
			if( $items[2] =~ /(\d.*)M/ ) {
				logOutput ( 2, 171005, "���̼��", "���̣�".$items[3]."���ڴ�ռ�����ﵽ��".$items[2]."��" ) if( $1 > $warnPMemoryAmount );
			}
			elsif( $items[2] =~ /(\d.*)G/ ) {
				logOutput ( 2, 171005, "���̼��", "���̣�".$items[3]."���ڴ�ռ�����ﵽ��".$items[2]."��" ) if( 1024 * $1 > $warnPMemoryAmount );
			}
			else {
				next; # omit K level process.
			}
 		}
		elsif( $uname eq "AIX" || $uname eq "HP-UX") {
			logOutput ( 2, 171005, "���̼��", "���̣�".$items[3]."���ڴ�ռ�����ﵽ��".$items[2]."K��" )
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
		logOutput ( 1, 171004, "���ݻ�ѹ", "������Ϣ�������������ĳһ�ļ�Ŀ¼���Ƿ��д�������ļ��ѻ�����" );
		return;
	}

   	$temp = getConfig ( $configFile, $session, "warnPileupNumber" );
	if( $temp eq "" ) {
		logOutput ( 1, 171004, "���ݻ�ѹ", "������Ϣ�����ã�warnPileupNumber = 10������ĳһĿ¼�µ��ļ�������10��ʱ��������" );
		$warnPileupNumber = 10;
	}
	else {
		$warnPileupNumber = int($temp);
		if( $warnPileupNumber < 3 ) {
			logOutput ( 2, 171004, "���ݻ�ѹ", "������Ϣ������: warnPileupNumber = $warnPileupNumber ̫С��" );
			logOutput ( 1, 171004, "���ݻ�ѹ", "������Ϣ������ warnPileupNumber = 3������ĳһĿ¼�µ��ļ�������3��ʱ��������" );
			$warnPileupNumber = 3;
		}
		elsif( $warnPileupNumber > 100 ) {
			logOutput ( 2, 171004, "���ݻ�ѹ", "������Ϣ������: warnPileupNumber = $warnPileupNumber ̫��." );
			logOutput ( 1, 171004, "���ݻ�ѹ", "������Ϣ������ warnPileupNumber = 100������ĳһĿ¼�µ��ļ�������100��ʱ��������" );
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
			logOutput ( 2, 171004, "���ݻ�ѹ", "�� $num ���ļ��� $disposedDir[$ii] Ŀ¼��δ������" );
		}
		else {
			logOutput ( 0, 171004, "���ݻ�ѹ", "�� $num ���ļ��� $disposedDir[$ii] Ŀ¼�¡�" );
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
		logOutput ( 1, 171003, "CPU�ڴ�", "������Ϣ����������������CPU���ڴ��IOwait��⡣" );
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
		( logOutput ( 4, 171003, "CPU�ڴ�", "�޷����в���ϵͳ���� vmstat 1 2, $! " ) and return );

	my( $ii ) = 0;
	while(<VM>) {
		last if( ++$ii == 4);
	}
	chop;
	close( VM );
	my( @items ) = split (/\s+/);
	my( $total ) = ( $items[4] * 100 )/($items[4] + $items[5] );

	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	$total = 100 - $items[18];
	if( $total > $warnTMemoryPercent ) {
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	open( IOSTAT, "iostat -t 1 2|" ) || 
		( logOutput ( 4, 171003, "ϵͳIO", "�޷����в���ϵͳ���� iostat 1 2, $! " ) and return );

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
		logOutput ( 2, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $total\%!" );
	}
}


sub systemCheckAIX {
	open( VM, "vmstat 1 2|" ) || 
		( logOutput ( 4, 171003, "CPU�ڴ�", "�޷����в���ϵͳ���� vmstat 1 2, $! " ) and return );

	my( $ii ) = 0;
	while(<VM>) {
		last if( ++$ii == 5);
	}
	close( VM );
	chop;
	my( @items ) = split (/\s+/);
	my( $total ) = ( $items[3] * 100 )/($items[3] + $items[4] );
	
	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	$total = 100 - $items[16];
	if( $total > $warnTMemoryPercent ) {
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	open( IOSTAT, "iostat -t 1 4|" ) || 
		( logOutput ( 4, 171003, "CPU�ڴ�", "�޷����в���ϵͳ���� iostat 1 2, $! " ) and return );
	$ii = 0;
	while(<IOSTAT>) {
		last if( ++$ii == 6 );
	}
	close( IOSTAT );
	chop;
	@items = split (/\s+/);
	if( $items[6] > $warnIOWaitPercent ) {
		logOutput ( 2, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $items[6]\%!" );
	}
	else {
		logOutput ( 1, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $items[6]\%!" );
	}
}

sub systemCheckOSF1 {
	open( VM, "vmstat -w 1 2|" ) || 
		( logOutput ( 4, 171003, "CPU�ڴ�", "�޷����в���ϵͳ���� vmstat -w 1 2, $! " ) and return );
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
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳ�ڴ�ռ�����Ѿ��ﵽ $total\%!" );
	}
	$total = 100 - $items[16];
	if( $total > $warnTCPUPercent ) {
		logOutput ( 2, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	else {
		logOutput ( 1, 171003, "CPU�ڴ�", "ϵͳCPUռ�����Ѿ��ﵽ $total\%!" );
	}
	if( $items[17] > $warnIOWaitPercent ) {
		logOutput ( 2, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $items[17]\%!" );
	}
	else {
		logOutput ( 1, 171003, "ϵͳIO", "ϵͳIOwait�ʴﵽ $items[17]\%!" );
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
		logOutput ( 1, 171002, "Ӳ�̿ռ�", "������Ϣ�������������ļ�ϵͳ��⡣" );
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
		logOutput ( 2, 171002, "Ӳ�̿ռ�", "������Ϣ��warnDiskPercents ������ fileSystems �٣�" );
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
		( logOutput ( 4, 171002, "Ӳ�̿ռ�", "�޷����в���ϵͳ���� bdf, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[5];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ����!" );
			}
			else {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%��" );
		}
	}
	close ( GET_DF );
}

sub diskCheckSunOS {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -k|" ) || 
		( logOutput ( 4, 171002, "Ӳ�̿ռ�", "�޷����в���ϵͳ���� df -k, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[5];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ����!" );
			}
			else {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%��" );
		}
	}
	close ( GET_DF );
}

sub diskCheckAIX {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -i|" ) || 
		( logOutput ( 4, 171002, "Ӳ�̿ռ�", "�޷����в���ϵͳ���� df -i, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[6];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[3] =~ s/%//;
		$items[5] =~ s/%//;
		if( $items[3] >= $warnDiskPercent ) {
			if( $items[3] >= 100 ) {
				logOutput ( 4, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ������" );
			}
			else {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[3]\%��" );
			}
		}
		else {
			logOutput ( 1, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[3]\%��" );
		}
		if( $items[5] >= $warnDiskPercent ) {
			if( $items[5] >= 100 ) {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ����꣡" );
			}
			else {
				logOutput ( 2, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ��ﵽ��$items[5]\%��" );
			}
		}
		else {
			logOutput ( 1, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ��ﵽ$items[5]\%��" );
		}
	}
	close ( GET_DF );
}

sub diskCheckOSF1 {
	my( @items ) = ();
	my( $fileSystem ) = "";
	my( $warnDiskPercent ) = 0;

	open( GET_DF, "df -i|" ) || 
		( logOutput ( 4, 171002, "Ӳ�̿ռ�", "�޷����в���ϵͳ���� df -i, $! " ) and return );
	while(<GET_DF>) {
		@items = split (/\s+/);
		$fileSystem = $items[8];
		$warnDiskPercent = $checkedDisk { $fileSystem };
		next unless ( $warnDiskPercent );
		$items[4] =~ s/%//;
		$items[7] =~ s/%//;
		if( $items[4] >= $warnDiskPercent ) {
			if( $items[4] >= 100 ) {
				logOutput ( 4, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ������" );
			}
			else {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%��" );
			}
		}
		else {
			logOutput ( 0, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' ��ʹ��$items[4]\%��" );
		}
		if( $items[7] >= $warnDiskPercent ) {
			if( $items[7] >= 100 ) {
				logOutput ( 4, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ�����!" );
			}
			else {
				logOutput ( 3, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ��ﵽ��$items[7]\%!" );
			}
		}
		else {
			logOutput ( 1, 171002, "Ӳ�̿ռ�", "�ļ�ϵͳ \'$fileSystem\' �ڵ����Ѿ��ﵽ$items[7]\%��" );
		}
	}
	close ( GET_DF );
}

sub getConfig {
	my( $configFile, $sessionName, $configName ) = @_;
	my( $sessionFind ) = 0;
	my( $temp ) = "";

	open (INP, "<$configFile" )
		or ( logOutput ( 4, 171002, "���", "���ܹ��������ļ���$configFile ����ȡ��Ϣ��" )
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
		print "�����ļ���δ���� [log]=>logFile��\n";
		print " ���ã�logFile = $logFile������־�ļ���ͷΪ��$logFile��\n";
	}
	else {
		$logFile = $temp;
	}

	$temp = getConfig ( $configFile, $session, "logLevel" );
	if( $temp eq "" ) {
		print "��������ļ���δ���� [log]=>logLevel��\n";
		print "���ã�logLevel = INFO_LEVEL����������־�����ϸ��Ϊ��$logLevels[1]��\n";
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
		print "�����ļ���û������[log]=>logOn��\n";
		print "���ã�logOn = TRUE���������־�ļ���\n";
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
		print "�����ļ���û�����ã�[log]=>consoleOn��\n";
		print "���ã� consoleOn = TRUE��������־����Ļ�����\n";
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
		or die "���ܴ���־�ļ���$theFile д��־��";

	print EXP "$yyyymmdd2 $HHMMSS $logLevels[$iLogLevel] ";
	print EXP @_;
	print EXP "|\n";

	close (EXP);
	
	if( $tempOutFile && $iLogLevel >= 1 ) {
		open (EXP, ">>$tempOutFile" )
			or die "���ܴ����ϵͳ��Ϣ�ļ���$tempOutFile д���ϵͳ��Ϣ��";

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
		logOutput ( 3, 171004,"���", "������Ŀ¼��Ϊ $theDir ��Ŀ¼��" );
		return 0;
	}
	return 1;
}

