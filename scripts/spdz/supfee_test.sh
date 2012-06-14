#!/bin/sh
################################################################################
# Script to generate 内容计费核减数据上报文件
# author: zhangyi@asiainfo.com
# 2007-08
#			
# NOTE: DB_CONNECT_STRING用于设置数据库连接串
# 上传至：10.70.11.83 /opt/mcb/pcs/backfee/data/outgoing/
################################################################################
# set -x
# set 200607	# for debug
DB_CONNECT_STRING="aijs/aijs@zmjs" 


logpath=`echo $SYS_LOG_PATH`
now=`date +%Y%m%d%H%M%S`
curdate=`date +%Y%m%d`
curday=`date +%d`
curmonth=`date +%Y%m`

zeros=`printf "%s" "0"`
CURRENT_YEAR=`date +%Y`
LAST_YEAR=`expr $CURRENT_YEAR - 1`
curmonth=`date +%m`
if [ $curmonth -gt 1 ]
 then
   LAST_MONTH=`expr $curmonth - 1`
   if [ $LAST_MONTH -lt 10 ]
   then
	MONTH="$CURRENT_YEAR$zeros$LAST_MONTH"
   else
	MONTH="$CURRENT_YEAR$LAST_MONTH"
   fi
   else
	LAST_MONTH=12
	MONTH="$LAST_YEAR$LAST_MONTH"
fi
echo "$MONTH"
if [ $curmonth -gt 1 ]
 then
    LAST_MONTH=`expr $curmonth - 2`
    if [ $LAST_MONTH -lt 10 ]
    then
        PRE_MONTH="$CURRENT_YEAR$zeros$LAST_MONTH"
    else
        PRE_MONTH="$CURRENT_YEAR$LAST_MONTH"
    fi
    else
        LAST_MONTH=12
        PRE_MONTH="$LAST_YEAR$LAST_MONTH"
fi
logfile=$logpath/spdz/supfee_${now}.log

# 退费上报文件
supfee_file=/data1/home/jsusr1/center/uploadfile/SUP/SUP${MONTH}000.571
#supfee_file=/data1/home/jsusr1/center/scripts/spdz/SUP${MONTH}000.571
curfile=SUP${MONTH}000.571

# clear
echo - This will take a few minutes, pls wait ...

#cat $logfile

if [ -f "$supfee_file" ]; then
	echo "- Same file existed, add file seq and re-try."
	mv -f $supfee_file $supfee_file.bak.$now
	#exit -1
fi

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF

delete from sup_fee where bill_month=$MONTH;
delete from sup_log where bill_month=$MONTH;
commit;

insert into sup_log select $MONTH,42001860,'571',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_571_$MONTH@ZWBCA_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'572',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_572_$MONTH@ZWBCA_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'573',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_573_$MONTH@ZWBCA_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'575',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_575_$MONTH@ZWBCA_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'576',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_576_$MONTH@ZWBCA_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'570',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_570_$MONTH@ZWBCB_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'574',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_574_$MONTH@ZWBCB_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'579',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_579_$MONTH@ZWBCB_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'577',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_577_$MONTH@ZWBCC_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'578',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_578_$MONTH@ZWBCC_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'580',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_580_$MONTH@ZWBCC_AICBS where acc_code=42001860;
insert into sup_log select $MONTH,42001860,'571',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_571@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'572',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_572@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'573',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_573@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'575',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_575@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'576',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_576@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'570',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_570@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'574',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_574@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'579',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_579@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'577',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_577@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'578',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_578@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42001860;
insert into sup_log select $MONTH,42001860,'580',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_580@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42001860;
commit;

insert into sup_log select $MONTH,42000030,'571',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_571_$MONTH@ZWBCA_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'572',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_572_$MONTH@ZWBCA_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'573',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_573_$MONTH@ZWBCA_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'575',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_575_$MONTH@ZWBCA_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'576',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_576_$MONTH@ZWBCA_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'570',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_570_$MONTH@ZWBCB_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'574',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_574_$MONTH@ZWBCB_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'579',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_579_$MONTH@ZWBCB_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'577',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_577_$MONTH@ZWBCC_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'578',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_578_$MONTH@ZWBCC_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'580',nvl(sum(total_fee),0),nvl(count(*),0),'payed' from aicbs.acc_user_bill_dtl_580_$MONTH@ZWBCC_AICBS where acc_code=42000030;
insert into sup_log select $MONTH,42000030,'571',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_571@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'572',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_572@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'573',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_573@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'575',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_575@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'576',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_576@ZWBCA_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'570',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_570@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'574',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_574@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'579',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_579@ZWBCB_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'577',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_577@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'578',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_578@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42000030;
insert into sup_log select $MONTH,42000030,'580',nvl(sum(total_fee),0),nvl(count(*),0),'unpay' from aicbs.acc_user_bill_dtl_unpay_580@ZWBCC_AICBS where bill_month=$MONTH and acc_code=42000030;
commit;

insert into sup_log select $MONTH,88012481,'571',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_571_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'572',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_572_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'573',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_573_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'575',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_574_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'576',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_575_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'570',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_576_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'574',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_577_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'579',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_578_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'577',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_579_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'578',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_570_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'580',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_580_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'571',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_571_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'572',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_572_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'573',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_573_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'575',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_574_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'576',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_575_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'570',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_576_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'574',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_577_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'579',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_578_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'577',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_579_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'578',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_570_$PRE_MONTH where acc_code=88012481;
insert into sup_log select $MONTH,88012481,'580',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_580_$PRE_MONTH where acc_code=88012481;
commit;

insert into sup_log select $MONTH,89001461,'571',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_571_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'572',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_572_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'573',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_573_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'575',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_574_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'576',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_575_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'570',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_576_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'574',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_577_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'579',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_578_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'577',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_579_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'578',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_570_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'580',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_580_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'571',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_571_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'572',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_572_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'573',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_573_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'575',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_574_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'576',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_575_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'570',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_576_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'574',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_577_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'579',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_578_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'577',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_579_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'578',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_570_$PRE_MONTH where acc_code=89001461;
insert into sup_log select $MONTH,89001461,'580',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_580_$PRE_MONTH where acc_code=89001461;
commit;

insert into sup_log select $MONTH,89018001,'571',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_571_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'572',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_572_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'573',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_573_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'575',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_574_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'576',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_575_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'570',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_576_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'574',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_577_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'579',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_578_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'577',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_579_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'578',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_570_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'580',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_580_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'571',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_571_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'572',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_572_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'573',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_573_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'575',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_574_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'576',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_575_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'570',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_576_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'574',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_577_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'579',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_578_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'577',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_579_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'578',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_570_$PRE_MONTH where acc_code=89018001;
insert into sup_log select $MONTH,89018001,'580',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_580_$PRE_MONTH where acc_code=89018001;
commit;

insert into sup_log select $MONTH,89015851,'571',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_571_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'572',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_572_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'573',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_573_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'575',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_574_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'576',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_575_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'570',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_576_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'574',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_577_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'579',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_578_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'577',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_579_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'578',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_570_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'580',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_580_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'571',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_571_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'572',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_572_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'573',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_573_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'575',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_574_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'576',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_575_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'570',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_576_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'574',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_577_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'579',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_578_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'577',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_579_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'578',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_570_$PRE_MONTH where acc_code=89015851;
insert into sup_log select $MONTH,89015851,'580',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_580_$PRE_MONTH where acc_code=89015851;

commit;
insert into sup_log select $MONTH,1910461,'571',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_571_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'572',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_572_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'573',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_573_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'575',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_574_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'576',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_575_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'570',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_576_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'574',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_577_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'579',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_578_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'577',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_579_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'578',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_570_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'580',nvl(sum(fee_payed),0),0,'payed' from settle_bill_split_580_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'571',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_571_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'572',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_572_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'573',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_573_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'575',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_574_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'576',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_575_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'570',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_576_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'574',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_577_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'579',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_578_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'577',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_579_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'578',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_570_$PRE_MONTH where acc_code=1910461;
insert into sup_log select $MONTH,1910461,'580',nvl(sum(fee_payed),0),0,'unpay' from settle_bill_u_split_580_$PRE_MONTH where acc_code=1910461;
commit;

insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,nvl(sum(total_unit),0),'                    ','                    ' from sup_log where bill_month=$MONTH and acc_code=42001860 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,nvl(sum(total_unit),0),'                    ','                    ' from sup_log where bill_month=$MONTH and acc_code=42000030 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,0,'801248              ','170101              ' from sup_log where bill_month=$MONTH and acc_code=88012481 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,0,'900146              ','13000056            ' from sup_log where bill_month=$MONTH and acc_code=89001461 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,0,'901800              ','HBXXCX              ' from sup_log where bill_month=$MONTH and acc_code=89018001 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,0,'901585              ','UMZXDX              ' from sup_log where bill_month=$MONTH and acc_code=89015851 group by bill_month,acc_code;
insert into sup_fee select bill_month,acc_code,nvl(sum(fee),0),0,0,'901508              ','FXWZ                ' from sup_log where bill_month=$MONTH and acc_code=1910461 group by bill_month,acc_code;
commit;

exec PRC_ZY_GPRS($MONTH,2);
insert into sup_fee select $MONTH,42000010,0,0,nvl(count(distinct user_number),0),'                    ','                    ' from pushmail_user_$MONTH;
commit;
exit
SQLEOF

# 文件头记录
blanks=`printf "%129s" " "`
head="1046000571          46000000  000                    $MONTH        01$blanks\r\n"
echo "$head\c" > $supfee_file

sqlplus $DB_CONNECT_STRING > /dev/null 2>&1 << SQLEOF
set line 250;
set pagesize 5000; 

spool $logfile;

select '20',decode(acc_code,42001860,'117',42000030,'118',42000010,'108',89015851,'126',88012481,'127',89018001,'128',89001461,'129',1910461,'130'),total_fee,'571',total_count,sp_code,operator_code from sup_fee where bill_month=$MONTH;

spool off;
exit
SQLEOF

awk ' /^20/ { printf("%2s%3s%-20s%-20s%010d%010d%3s%010d%010d%110s\r\n", $1,$2,$6,$7,$3,"0",$4,"0",$5," ") }' $logfile >> $supfee_file
linefmt=`cat $logfile | awk '/^20/ {print}' | awk '{ n+=$3; s+= $5 } END { printf("%2s%10s%10s%3s%015d%015d%015d%015d%113s", "90","46000000  ","46000571  ","000",n,"0","0",s, " ") }'`


# supfee_file tail
#tail="9046000000  46000571  $1$linefmt"
echo "$linefmt\r" >> $supfee_file

echo - Temp files:
echo "\t$logfile"

echo - Result files:
echo "\t$supfee_file"

echo "ftp $supfee_file"
#--------------------------------------------------------------------#
echo begin

#ftp -i -n 10.254.48.12  << EOF
#user mcb3tran mcB3!571 
#lcd /data1/home/jsusr1/center/uploadfile/SUP
#cd /opt/mcb/pcs/cbbs/sup_fee/data/outgoing/ 
#bin
#prom off
#put $curfile 
#bye
#EOF
#--------------------------------------------------------------------#  

echo "A-OK!"

exit 0
