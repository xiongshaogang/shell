load data
infile 'cring.txt'
append into table all_cring 
Fields terminated by ','
(
bill_month,
hplmn2,
music_total,
music_sp,
music_self,
down_total,
down_sp,
down_self,
all_total,
all_sp,
all_self
)
