#!/bin/sh


echo "INSERT INTO gps_temp VALUES ">insert.sql

for var1 in {1..1000000}
do
echo "('$var1', '$var1', '2012-03-07 10:05:51', '2000-09-02 15:00:00', '1', '114.379295', '30.51865', '0', '0', '00000000000000000000000000001011', '????', '0', '2', '0', null, null, null, null, null, '0', null, null, '1', '257'),">>insert.sql
done

