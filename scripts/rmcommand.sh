#!/bin/csh
if($#argv == 2)then
	set pattern="*$1"
	shift
else
	set pattern="$1"
endif
if($1 =~ $pattern)then
	echo "rm" $1...
#	rm -r $1
	mkdir -p $1
endif
	
