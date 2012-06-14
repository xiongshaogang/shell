#!/bin/csh
set wj="wj"

if($#argv != 2 && $#argv != 1)then
	echo "Usage:command path [roam|wj|sp]"
	exit 1
endif	

if($#argv == 2)then
		set work=$2;
else
		set work="no"
endif				

set datapath=$1/center/data
set logpath=$1/center/log
set temppath=$1/center/temp
set backpath=$1/center/back
set errorpath=$1/center/error
set duppath=$1/center/dup
set configpath=$1/center/config
set command='mkdir -p '

set dirlist=`echo  $datapath `
set dir1list=`echo $logpath $temppath $duppath $errorpath `
set dir2list=`echo $backpath`
set list=`echo "acquire format settle dataloader daydataloader stat daystat"`
set list2=`echo "settle daystat dataloader/cdr dataloader/stat"`
set dir3list=`echo $configpath/acquire $datapath/stat/statoutput $datapath/stat/skip $datapath/daydataloader/input`
if($#argv == 1 || $work == "wj")then
		foreach j($dirlist)
			foreach i($list)
				$command $j/$i/output/wj/voice/nokia
				$command $j/$i/output/wj/voice/alcatel
				$command $j/$i/output/wj/voice/huawei
				$command $j/$i/output/wj/sms
			end		
		end	
		foreach j($dir3list)
			$command $j/wj/voice/nokia		
			$command $j/wj/voice/alcatel
			$command $j/wj/voice/huawei
			$command $j/wj/sms	
		end
		foreach j($dir1list)
			foreach i($list)
				$command $j/$i/wj/voice/nokia
				$command $j/$i/wj/voice/alcatel
				$command $j/$i/wj/voice/huawei
				$command $j/$i/wj/sms
			end		
		end	
		foreach j($dir2list)
			foreach i($list2)
				$command $j/$i/wj/voice/nokia
				$command $j/$i/wj/voice/alcatel
				$command $j/$i/wj/voice/huawei
				$command $j/$i/wj/sms
			end		
		end			
endif

if($#argv == 1 || $work == "sp")then
		foreach j($dirlist)
			foreach i($list)
					$command $j/$i/output/sp/billing/gsm
					$command $j/$i/output/sp/billing/ismg
					$command $j/$i/output/sp/billing/mms
					$command $j/$i/output/sp/billing/wap
					$command $j/$i/output/sp/bill
			end		
		end		
		foreach j($dir3list)
			$command $j/sp/billing/gsm
			$command $j/sp/billing/ismg
			$command $j/sp/billing/mms
			$command $j/sp/billing/wap
			$command $j/sp/bill	
		end		

		foreach j($dir1list)
			foreach i($list)
					$command $j/$i/sp/billing/gsm
					$command $j/$i/sp/billing/ismg
					$command $j/$i/sp/billing/mms
					$command $j/$i/sp/billing/wap
					$command $j/$i/sp/bill
			end		
		end		
		foreach j($dir2list)
			foreach i($list2)
					$command $j/$i/sp/billing/gsm
					$command $j/$i/sp/billing/ismg
					$command $j/$i/sp/billing/mms
					$command $j/$i/sp/billing/wap
					$command $j/$i/sp/bill
			end		
		end						
endif

if($#argv == 1 || $work == "roam")then
		foreach j($dirlist)
			foreach i($list)
					$command $j/$i/output/roam/sp/kjava
					$command $j/$i/output/roam/sp/mms
					$command $j/$i/output/roam/sp/wap
					$command $j/$i/output/roam/sp/sms
					$command $j/$i/output/roam/sp/ch
					$command $j/$i/output/roam/refill/vc
					$command $j/$i/output/roam/refill/vip
					$command $j/$i/output/roam/voice/ipcard						
					$command $j/$i/output/roam/voice/pps	
					$command $j/$i/output/roam/voice/rq	
					$command $j/$i/output/roam/voice/korea
					$command $j/$i/output/roam/voice/voice
					$command $j/$i/output/roam/gprs
			end		
		end	
		foreach j($dir3list)		
			$command $j/roam/sp/kjava
			$command $j/roam/sp/mms
			$command $j/roam/sp/wap
			$command $j/roam/sp/sms
			$command $j/roam/sp/ch
			$command $j/roam/refill/vc
			$command $j/roam/refill/vip
			$command $j/roam/voice/ipcard						
			$command $j/roam/voice/pps	
			$command $j/roam/voice/rq	
			$command $j/roam/voice/korea
			$command $j/roam/voice/voice
			$command $j/roam/gprs	
		end	
		foreach j($dir1list)
			foreach i($list)
					$command $j/$i/roam/sp/kjava
					$command $j/$i/roam/sp/mms
					$command $j/$i/roam/sp/wap
					$command $j/$i/roam/sp/sms
					$command $j/$i/roam/sp/ch
					$command $j/$i/roam/refill/vc
					$command $j/$i/roam/refill/vip
					$command $j/$i/roam/voice/ipcard						
					$command $j/$i/roam/voice/pps	
					$command $j/$i/roam/voice/rq	
					$command $j/$i/roam/voice/korea
					$command $j/$i/roam/voice/voice
					$command $j/$i/roam/gprs
			end		
		end			
		foreach j($dir2list)
			foreach i($list2)
					$command $j/$i/roam/sp/kjava
					$command $j/$i/roam/sp/mms
					$command $j/$i/roam/sp/wap
					$command $j/$i/roam/sp/sms
					$command $j/$i/roam/sp/ch
					$command $j/$i/roam/refill/vc
					$command $j/$i/roam/refill/vip
					$command $j/$i/roam/voice/ipcard						
					$command $j/$i/roam/voice/pps	
					$command $j/$i/roam/voice/rq	
					$command $j/$i/roam/voice/korea
					$command $j/$i/roam/voice/voice
					$command $j/$i/roam/gprs
			end		
		end				
endif


		
