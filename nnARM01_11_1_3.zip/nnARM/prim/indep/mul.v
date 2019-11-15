module	mul(out_MulResult,
		in_a,
		in_b,
		in_LongMulSig
);

input	[31:0]	in_a,in_b;
input	in_LongMulSig;

output	[65:0]	out_MulResult;

wire	[33:0]	amanadj;
wire	[32:0]	bmanadj;

wire	[33:0]	parttmp1_1,
		parttmp1_2,
		parttmp1_3,
		parttmp1_4,
		parttmp1_5,
		parttmp1_6,
		parttmp1_7,
		parttmp1_8,
		parttmp2_1,
		parttmp2_2,
		parttmp2_3,
		parttmp2_4,
		parttmp2_5,
		parttmp2_6,
		parttmp2_7,
		parttmp2_8,
		parttmp2_9;
		
wire	[31:0]	rest;

wire	[65:0]	resultman1_0,
		resultman1_2,
		resultman1_3,
		resultman1_4,
		resultman1_5,
		resultman1_6,
		resultman1_7,
		resultman1_8,
		resultman1_2_1,
		resultman1_3_1,
		resultman1_4_1,
		resultman1_5_1,
		resultman1_6_1,
		resultman1_7_1,
		resultman1_8_1,
		resultman2_1,
		resultman2_2,
		resultman2_3,
		resultman2_4,
		resultman2_5,
		resultman2_6,
		resultman2_7,
		resultman2_8,
		resultman2_9,
		resultman2_2_1,
		resultman2_3_1,
		resultman2_4_1,
		resultman2_5_1,
		resultman2_6_1,
		resultman2_7_1,
		resultman2_8_1,
		resultman2_9_1,
		resultmanend;

assign	amanadj={in_LongMulSig & in_a[31],in_LongMulSig & in_a[31],in_a};
assign	bmanadj={in_LongMulSig & in_b[31],in_b};

assign	rest[2]=1'b0;
assign	rest[4]=1'b0;
assign	rest[6]=1'b0;
assign	rest[8]=1'b0;
assign	rest[10]=1'b0;
assign	rest[12]=1'b0;
assign	rest[14]=1'b0;
assign	rest[16]=1'b0;
assign	rest[18]=1'b0;
assign	rest[20]=1'b0;
assign	rest[22]=1'b0;
assign	rest[24]=1'b0;
assign	rest[26]=1'b0;
assign	rest[28]=1'b0;
assign	rest[30]=1'b0;

//the first adder link
//first add result
assign	parttmp1_1=(bmanadj[0]==1'b0)?34'b0000_0000_0000_0000_0000_0000_0000_0000_00:~amanadj;
assign	rest[0]=bmanadj[0];
assign	resultman1_0={parttmp1_1[33],parttmp1_1,31'b000_0000_0000_0000_0000_0000_0000_0000};

mul_dec	inst_mul_dec1_2(parttmp1_2,
		rest[1],
		bmanadj[2:0],
		amanadj
);

//ssycnt==1 ,shift 2 bits
//assign	{parttmp1_2,rest[1]}=decode(bmanadj[2:0],amanadj);
assign	resultman1_2[65:32]=resultman1_0[65:32]+parttmp1_2;
assign	resultman1_2[31:0]=resultman1_0[31:0];
assign	resultman1_2_1={resultman1_2[65],resultman1_2[65],resultman1_2[65:2]};

mul_dec	inst_mul_dec1_3(parttmp1_3,
		rest[3],
		bmanadj[4:2],
		amanadj
);

//ssycnt==3 ,shift 2 bits
//assign	{parttmp1_3,rest[3]}=decode(bmanadj[4:2],amanadj);
assign	resultman1_3[65:32]=resultman1_2_1[65:32]+parttmp1_3;
assign	resultman1_3[31:0]=resultman1_2_1[31:0];
assign	resultman1_3_1={resultman1_3[65],resultman1_3[65],resultman1_3[65:2]};

mul_dec	inst_mul_dec1_4(parttmp1_4,
		rest[5],
		bmanadj[6:4],
		amanadj
);

//ssycnt==5 ,shift 2 bits
//assign	{parttmp1_4,rest[5]}=decode(bmanadj[6:4],amanadj);
assign	resultman1_4[65:32]=resultman1_3_1[65:32]+parttmp1_4;
assign	resultman1_4[31:0]=resultman1_3_1[31:0];
assign	resultman1_4_1={resultman1_4[65],resultman1_4[65],resultman1_4[65:2]};

mul_dec	inst_mul_dec1_5(parttmp1_5,
		rest[7],
		bmanadj[8:6],
		amanadj
);

//ssycnt==7 ,shift 2 bits
//assign	{parttmp1_5,rest[7]}=decode(bmanadj[8:6],amanadj);
assign	resultman1_5[65:32]=resultman1_4_1[65:32]+parttmp1_5;
assign	resultman1_5[31:0]=resultman1_4_1[31:0];
assign	resultman1_5_1={resultman1_5[65],resultman1_5[65],resultman1_5[65:2]};

mul_dec	inst_mul_dec1_6(parttmp1_6,
		rest[9],
		bmanadj[10:8],
		amanadj
);

//ssycnt==9 ,shift 2 bits
//assign	{parttmp1_6,rest[9]}=decode(bmanadj[10:8],amanadj);
assign	resultman1_6[65:32]=resultman1_5_1[65:32]+parttmp1_6;
assign	resultman1_6[31:0]=resultman1_5_1[31:0];
assign	resultman1_6_1={resultman1_6[65],resultman1_6[65],resultman1_6[65:2]};

mul_dec	inst_mul_dec1_7(parttmp1_7,
		rest[11],
		bmanadj[12:10],
		amanadj
);

//ssycnt==11 ,shift 2 bits
//assign	{parttmp1_7,rest[11]}=decode(bmanadj[12:10],amanadj);
assign	resultman1_7[65:32]=resultman1_6_1[65:32]+parttmp1_7;
assign	resultman1_7[31:0]=resultman1_6_1[31:0];
assign	resultman1_7_1={resultman1_7[65],resultman1_7[65],resultman1_7[65:2]};

mul_dec	inst_mul_dec1_8(parttmp1_8,
		rest[13],
		bmanadj[14:12],
		amanadj
);

//ssycnt==13 ,shift 2 bits
//assign	{parttmp1_8,rest[13]}=decode(bmanadj[14:12],amanadj);
assign	resultman1_8[65:32]=resultman1_7_1[65:32]+parttmp1_8;
assign	resultman1_8[31:0]=resultman1_7_1[31:0];
assign	resultman1_8_1={resultman1_8[65],resultman1_8[65],resultman1_8[65:2]};




//the second adder link
mul_dec	inst_mul_dec2_1(parttmp2_1,
		rest[15],
		bmanadj[16:14],
		amanadj
);
//ssycnt==15 ,shift 2 bits
//assign	{parttmp2_1,rest[15]}=decode(bmanadj[16:14],amanadj);
assign	resultman2_1={parttmp2_1[33],parttmp2_1[33],parttmp2_1,30'b00_0000_0000_0000_0000_0000_0000_0000};

//ssycnt==17 ,shift 2 bits
mul_dec	inst_mul_dec2_2(parttmp2_2,
		rest[17],
		bmanadj[18:16],
		amanadj
);
//assign	{parttmp2_2,rest[17]}=decode(bmanadj[18:16],amanadj);
assign	resultman2_2[65:32]=resultman2_1[65:32]+parttmp2_2;
assign	resultman2_2[31:0]=resultman2_1[31:0];
assign	resultman2_2_1={resultman2_2[65],resultman2_2[65],resultman2_2[65:2]};

//ssycnt==19 ,shift 2 bits
mul_dec	inst_mul_dec2_3(parttmp2_3,
		rest[19],
		bmanadj[20:18],
		amanadj
);
//assign	{parttmp2_3,rest[19]}=decode(bmanadj[20:18],amanadj);
assign	resultman2_3[65:32]=resultman2_2_1[65:32]+parttmp2_3;
assign	resultman2_3[31:0]=resultman2_2_1[31:0];
assign	resultman2_3_1={resultman2_3[65],resultman2_3[65],resultman2_3[65:2]};

//ssycnt==21 ,shift 2 bits
mul_dec	inst_mul_dec2_4(parttmp2_4,
		rest[21],
		bmanadj[22:20],
		amanadj
);
//assign	{parttmp2_4,rest[21]}=decode(bmanadj[22:20],amanadj);
assign	resultman2_4[65:32]=resultman2_3_1[65:32]+parttmp2_4;
assign	resultman2_4[31:0]=resultman2_3_1[31:0];
assign	resultman2_4_1={resultman2_4[65],resultman2_4[65],resultman2_4[65:2]};

//ssycnt==23 ,just shift 2 bit
mul_dec	inst_mul_dec2_5(parttmp2_5,
		rest[23],
		bmanadj[24:22],
		amanadj
);
//assign	{parttmp2_5,rest[23]}=decode(bmanadj[24:22],amanadj);
assign	resultman2_5[65:32]=resultman2_4_1[65:32]+parttmp2_5;
assign	resultman2_5[31:0]=resultman2_4_1[31:0];
assign	resultman2_5_1={resultman2_5[65],resultman2_5[65],resultman2_5[65:2]};

//ssycnt==25 ,just shift 2 bit
mul_dec	inst_mul_dec2_6(parttmp2_6,
		rest[25],
		bmanadj[26:24],
		amanadj
);
//assign	{parttmp2_6,rest[25]}=decode(bmanadj[26:24],amanadj);
assign	resultman2_6[65:32]=resultman2_5_1[65:32]+parttmp2_6;
assign	resultman2_6[31:0]=resultman2_5_1[31:0];
assign	resultman2_6_1={resultman2_6[65],resultman2_6[65],resultman2_6[65:2]};

//ssycnt==27 ,just shift 2 bit
//assign	{parttmp2_7,rest[27]}=decode(bmanadj[28:26],amanadj);
mul_dec	inst_mul_dec2_7(parttmp2_7,
		rest[27],
		bmanadj[28:26],
		amanadj
);
assign	resultman2_7[65:32]=resultman2_6_1[65:32]+parttmp2_7;
assign	resultman2_7[31:0]=resultman2_6_1[31:0];
assign	resultman2_7_1={resultman2_7[65],resultman2_7[65],resultman2_7[65:2]};

//ssycnt==29 ,just shift 2 bit
//assign	{parttmp2_8,rest[29]}=decode(bmanadj[30:28],amanadj);
mul_dec	inst_mul_dec2_8(parttmp2_8,
		rest[29],
		bmanadj[30:28],
		amanadj
);
assign	resultman2_8[65:32]=resultman2_7_1[65:32]+parttmp2_8;
assign	resultman2_8[31:0]=resultman2_7_1[31:0];
assign	resultman2_8_1={resultman2_8[65],resultman2_8[65],resultman2_8[65:2]};

//ssycnt==31 ,just shift 1 bit
//assign	{parttmp2_9,rest[31]}=decode(bmanadj[32:30],amanadj);
mul_dec	inst_mul_dec2_9(parttmp2_9,
		rest[31],
		bmanadj[32:30],
		amanadj
);
assign	resultman2_9[65:32]=resultman2_8_1[65:32]+parttmp2_9;
assign	resultman2_9[31:0]=resultman2_8_1[31:0];
assign	resultman2_9_1={resultman2_9[65],resultman2_9[65:1]};


//sum the two adder link together
//add the two resultman1 and resultman2
assign	resultmanend=resultman2_9_1+{{17{resultman1_8_1[65]}},resultman1_8_1[65:17]};
//add the rest vector
assign	out_MulResult=resultmanend+{34'b0000_0000_0000_0000_0000_0000_0000_0000_00,rest};



endmodule