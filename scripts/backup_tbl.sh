#!/bin/csh
nohup sqlplus aijs/aijs@testjs <<!
create table qhp_old_sms_20051012 as select  * from mi_cdr_gsmc_20051012@zmjs_wj_sms;
!
