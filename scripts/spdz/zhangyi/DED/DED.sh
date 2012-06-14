#!/bin/csh
rm /data1/home/jsusr1/center/scripts/spdz/zhangyi/DED.ctl
ded.sql DED20080606000.571
sqlldr aijs/aijs@zmjs control=DED.ctl
