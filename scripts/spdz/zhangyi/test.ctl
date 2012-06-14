load data
infile 'DED.txt'
append into table ded_file
when rev_head='20'
(
rev_head position(1:2),
serv_type position(3:12) "Trim(:serv_type)",
fee_type position(13:14),
bill_id position(35:49) "Trim(:bill_id)",
sp_code position(50:69) "Trim(:sp_code)",
operator_code position(70:89) "Trim(:operator_code)",
bill_type position(90:91),
use_time position(92:105),
ded_time position(106:119),
rev_fee position(120:125) "Trim(:rev_fee)",
done_code position(15:34) "Trim(:done_code)"
)
