# ��һ��for subfile
# �ڶ���for sumfile

BEGIN {
FS=" "
	fee_desc[0]  = "��Ϣ���ܶ�                "
	fee_desc[1]  = "�������ص�������        "
	fee_desc[2]  = "У��֮�����֮ǰ��Ϣ���ܶ�"
	fee_desc[3]  = "ͣ��/��ͣ����             "
	fee_desc[4]  = "����/Ԥ���ŷ���           "
	fee_desc[5]  = "������ϵ�쳣����          "
	fee_desc[6]  = "��Ĭ�û�����              "
	fee_desc[7]  = "�������߷���              "
	fee_desc[8]  = "�˷ѷ���                  "
	fee_desc[9]  = "ΥԼ�������              "
	fee_desc[10] = "˫����������              "
	fee_desc[11] = "��������                  "
	fee_desc[12] = "Ӧ������Ϣ��              "

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
	
	# sumfile tail:Ӧ������Ϣ�Ѻϼ�[14]|������ͨ�ŷѺϼ�[14]|ʵ�ʽ�����ϼ�|�����ֶ�1[30]
	#printf("%014.0f%014.0f%014.0f%30s\r\n", fee[12], 0, fee[12], " ")
}	
