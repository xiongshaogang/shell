#!/bin/csh
cd $1
foreach i(`ls `)
	split -l 10000  -a 2 $i $i.
	rm $i
end
exit 0
