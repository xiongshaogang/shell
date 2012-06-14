#采集
rm /data32/home/aijs/center/config/acquire/wj/voice/huawei/ftp_hw.lst
rm /data32/home/aijs/center/config/acquire/wj/voice/nokia/nk10.lst
rm /data32/home/aijs/center/config/acquire/wj/voice/alcatel/al.lst

rm -r /data33/aijs/center/data/acquire/output/wj/voice/*
cd /data33/aijs/center/data/acquire/output/wj/voice
mkdir nokia huawei alcatel


rm -r /data33/aijs/center/temp/acquire/wj/voice/*
cd /data33/aijs/center/temp/acquire/wj/voice
mkdir nokia huawei alcatel

cd /data33/aijs/center/log/acquire/wj/voice
rm -r *
mkdir nokia huawei alcatel

#预处理
cd /data33/aijs/center/dup/format/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/error/format/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/format/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/acquire/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data32/home/aijs/center/log/format/wj/voice
rm -r *
mkdir nokia huawei alcatel

#分析
cd /data33/aijs/center/log/settle/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/back/settle/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/error/settle/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/settle/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

#统计
cd /data33/aijs/center/log/stat/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/stat/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/error/stat/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/stat/statoutput/wj/voice
rm -r *
mkdir nokia huawei alcatel


#日统计
cd /data33/aijs/center/log/daystat/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/back/daystat/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/error/daystat/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/data/daystat/statoutput/wj/voice
rm -r *
mkdir nokia huawei alcatel



#分单
cd /data33/aijs/center/error/dataloader/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/log/dataloader/wj/voice
rm -r *
mkdir  nokia huawei alcatel

cd /data33/aijs/center/data/dataloader/output/wj/voice
rm -r *
mkdir nokia huawei alcatel

#清单加载
cd /data33/aijs/center/error/dataloader/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/log/dataloader/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/back/dataloader/cdr/wj/voice
rm -r *
mkdir  nokia huawei alcatel


#统计加载
cd /data33/aijs/center/error/dataloader/daystat/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/log/dataloader/daystat/wj/voice
rm -r *
mkdir nokia huawei alcatel

cd /data33/aijs/center/back/dataloader/stat/wj/voice
rm -r *
mkdir nokia huawei alcatel