echo "Edit first to meet your demands!"
exit 0

# wj sms
createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/wjsmssettle.ora -B 20060430 -C 33

# wj voice
createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/wjsettle.ora -B 20060430 -C 33

#Usage: createtable -S server_name [-D database_name] -U username -P password -T templateFileName -B [YYYYMMDD | YYYYMM | YYYY] [-C tableNum] [-I patitionCode] [-N var] [-F tableScheme] [-L] 

#Usage: droptable -S server_name [-D database_name] -U username -P password -T tablePattern | -V serviceId -R drType 
#droptable -S zmjs -U aijs -P aijs -V 3 -R 4 -B 20060101 -C 60

# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamch.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamgprs.ora   -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamgsm.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamipc.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamkjava.ora  -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamkorea.ora  -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roammms.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roampps.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamrq.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamsms.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamvc.ora     -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamvip.ora    -B 20060430 -C 33 &
# createtable -S zmjs -U aijs -P aijs -T /data1/home/jsusr1/center/config/tpl/roamwap.ora    -B 20060430 -C 33 &


