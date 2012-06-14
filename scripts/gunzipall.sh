#!/bin/csh
set base=`basename $1 .Z`
set dirname=`dirname $1`
gunzip  $1
mv $dirname/$base $2/$base
exit 0
