#!/bin/bash
####################################
## System information listen tool v0.2 ######
##                   powered by mcsrainbow ######
####################################
while true
do
 
###Copy the top's content to top.info###
top -b1 -n1 >top.info
sleep 2
 
###Check the flow###
typeset in in_old dif_in
typeset out out_old dif_out
 
FLOW(){
in_flow1=$(cat /proc/net/dev | grep eth0 | sed -e "s/(.*):(.*)/[1]/g" | awk ' { print $2 }')
echo in_flow1:$in_flow1
in_flow2=$(cat /proc/net/dev | grep eth1 | sed -e "s/(.*):(.*)/[1]/g" | awk ' { print $2 }')
if [ -z $in_flow2 ]; then
echo "inflow2 is  0"
in_flow2="0"
else
	echo in_flow2:$in_flow2
fi
echo in_flow2:$in_flow2
in_flow_byte=$(expr $in_flow1 + $in_flow2)
echo  in_flow_byte:$in_flow_byte
in_flow=$(expr $in_flow_byte / 1024)
echo  in_flow:$in_flow
out_flow1=$(cat /proc/net/dev | grep eth0 | sed -e "s/(.*):(.*)/[1]/g" | awk ' { print $10 }')
echo  out_flow1:$out_flow1
out_flow2=$(cat /proc/net/dev | grep eth1 | sed -e "s/(.*):(.*)/[1]/g" | awk ' { print $10}')
if [ -z $out_flow2 ]; then
echo "out_flow2 is  o"
out_flow2="0"
else
	echo out_flow2:$out_flow2
fi
echo out_flow1:$out_flow2
out_flow_byte=$(expr $out_flow1 + $out_flow2)
echo out_flow_byte:$out_flow_byte
out_flow=$(expr $out_flow_byte / 1024)
echo out_flow:$out_flow
}
 
FLOW
in_old=$in_flow
echo in_flow:$in_flow
out_old=$out_flow
 echo out_flow:$out_flow
 echo "sleep 1s "
sleep 10
 
FLOW
in=$in_flow
out=$out_flow
dif_in=$(expr $in - $in_old )
dif_out=$(expr $out - $out_old )
 
###Clear the Screen###
clear
 
###Define the safe number###
servername=Server   #The server's name which you running the scrīpts
maxload=5                  #Warning if the load average bigger than this number
maxcpu=50                 #Warning if the cpu bigger than is percent
minmem=120             #Warning if the memory less than this number (MB)
minswap=120            #Warning if the swap less than this number (MB)
maxusers=3               #Warning if the user online more than 3
maxzombie=2            #Warning if the zombie process more than 2
 
###Check the CPU###
cpuinfo=`grep "Cpu(s)" top.info|awk '{print $2}'`
cpuinfonumber=` echo $cpuinfo |awk -F "%" '{print $1}'|awk -F "." '{print $1}'`
if [ ${maxcpu} -lt ${cpuinfonumber} ]
        then
        echo "!!!!WARNING:The CPU used too much!!!!"
fi
 
###Check the Mem###
meminfo=`grep "Mem:" top.info|awk '{print $4 "/" $2}'`
usedmem_kb=`grep "Mem:" top.info|awk '{print $4}'|awk -F "k" '{print $1}'`
usedmem_mb=$(expr $usedmem_kb / 1024)
totalmem_kb=`grep "Mem:" top.info|awk '{print $2}'|awk -F "k" '{print $1}'`
totalmem_mb=$(expr $totalmem_kb / 1024)
freemem_mb=$(expr $totalmem_mb - $usedmem_mb)
if [ ${freemem_mb} -lt ${minmem} ]
        then
        echo "!!!!WARNING:The Memory used too much!!!!"
fi
totalmem_kb_percent=$(expr $totalmem_kb / 100)
percentmem=$(expr $usedmem_kb / $totalmem_kb_percent)
 
###Check the Swap###
swapinfo=`grep "Swap:" top.info |awk '{print $4 "/" $2}'`
usedswap_kb=`grep "Swap:" top.info |awk '{print $4}'|awk -F "k" '{print $1}'`
usedswap_mb=$(expr $usedswap_kb / 1024)
totalswap_kb=`grep "Swap:" top.info |awk '{print $2}'|awk -F "k" '{print $1}'`
totalswap_mb=$(expr $totalswap_kb / 1024)
freeswap_mb=$(expr $totalswap_mb - $usedswap_mb)
if [ ${freeswap_mb} -lt ${minswap} ]
        then
        echo "!!!!WARNING:The Swap used too much!!!!"
fi
totalswap_kb_percent=$(expr $totalswap_kb / 100)
percentswap=$(expr $usedswap_kb / $totalswap_kb_percent)
 
###Check the users online###
useronl=`grep "load average:" top.info |sed 's/user.*//'|awk '{print $(NF)}'`
if [ ${maxusers} -lt ${useronl} ]
        then
        echo "!!!!WARNING:The User online is more than 3!!!!"
fi
 
###Check the load average###
loadavg=`grep "load average:" top.info |sed 's/.*load average: //'|awk -F "," '{print $(NF-2)}'`
loadavgnumber=`grep "load average:" top.info |sed 's/.*load average: //'|awk -F "," '{print $(NF-2)}'|awk -F "." '{print $1}'`
if [ ${maxload} -lt ${loadavgnumber} ]
        then
        echo "!!!!WARNING:The Load Average is more than 5!!!!"
fi
 
###Check the zombie###
zombie=`grep "Tasks:" top.info |awk '{print $(NF-1)}'`
if [ ${maxzombie} -lt ${zombie} ]
        then
        echo "!!!!WARNING:The Zombie Process is more than 2!!!!"
fi
 
###Check the most process###
processtitle=`grep "TIME+" top.info`
processinfo=`sed -n 8p top.info`
 
###Show me the number just have counted###
echo "Server     CPU   LOAD ZOMBIE   USER   IN     OUT             MEM             SWAP    "
echo "${servername} ${cpuinfo} ${loadavg}    ${zombie}        ${useronl}   ${dif_in}KB/s ${dif_out}KB/s   ${meminfo} ${percentmem}%   ${swapinfo} ${percentswap}% "
echo "--------------------------------------------------------------------"
echo "${processtitle}"
echo "${processinfo}"
 
done
