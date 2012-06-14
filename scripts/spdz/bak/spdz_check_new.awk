# 第一行for subfile
# 第二行for sumfile

BEGIN {
FS=" "
	fee_desc[0]  = "信息费总额                "
	fee_desc[1]  = "错单（含重单）费用        "
	fee_desc[2]  = "校验之后稽核之前信息费总额"
	fee_desc[3]  = "停机/单停费用             "
	fee_desc[4]  = "销号/预销号费用           "
	fee_desc[5]  = "订购关系异常费用          "
	fee_desc[6]  = "沉默用户费用              "
	fee_desc[7]  = "单条过高费用              "
	fee_desc[8]  = "退费费用                  "
	fee_desc[9]  = "违约罚款费用              "
	fee_desc[10] = "双倍返还费用              "
	fee_desc[11] = "其它费用                  "
	fee_desc[12] = "应结算信息费              "

}

/^50/ { 
	fee[0]  += $5
	fee[1]  += $6
	fee[2]  += $7
	fee[3]  += $8
	fee[4]  += $9
	fee[5]  += $10
	fee[6]  += $11
	fee[7]  += $12
	fee[8]  += $13
	fee[9]  += $14
	fee[10] += $15
	fee[11] += $16
	fee[12] += $17
}

END {
	#fee_check=fee[2]
	
	#subfile tail
	for(i=0; i<13; i+=1) {
		printf("#%02d - %14.f	(%s)\r\n", i, fee[i], fee_desc[i]);
		#printf("%014.0f", fee[i]);
		
		#if(i>2){
		#	fee_check -= fee[i]
		#	printf("\t\t%014.0f\r\n", fee_check );
		#}
	}
	
	#printf("fee_check = 014.2f\r\n", fee_check/100 )
	
	# sumfile tail:应结算信息费合计[14]|不均衡通信费合计[14]|实际结算金额合计|保留字段1[30]
	#printf("%014.0f%014.0f%014.0f%30s\r\n", fee[12], 0, fee[12], " ")
}	
