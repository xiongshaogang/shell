#!/bin/sh
DB_CONNECT_STRING="aijs/aijs@zmjs"

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
exec PRC_SP_PAYED_predo('0');
exit
SQLEOF

exit 0
