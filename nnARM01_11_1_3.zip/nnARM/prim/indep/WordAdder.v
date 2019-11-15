module WordAdder(out_Result,
		out_Carry,
		out_Zero,
		out_Neg,
		out_Overflow,
		in_LeftOperand,
		in_RightOperand,
		in_LowCarry);

output [`WordWidth-1:0] out_Result;
output out_Carry,out_Zero,out_Neg,out_Overflow;

reg  [`WordWidth-1:0] out_Result;
reg out_Carry,out_Zero,out_Neg,out_Overflow;


input [`WordWidth-1:0] in_LeftOperand,in_RightOperand;
input in_LowCarry;

//must be one bit more than input and output
reg [`WordWidth-1:0] tmp;
reg [`WordWidth-1:0] out_HighCarry;

wire ssy;

integer ssycnt;

always @(in_LeftOperand or in_RightOperand or in_LowCarry)
begin
	//this two add will be replace by futrue macro cell
	{out_Carry,tmp}={1'b0,in_LeftOperand}+{1'b0,in_RightOperand}+{`WordZero,in_LowCarry};
	//{out_HighCarry[0],tmp[0]}=OneBitFullAdder(in_LeftOperand[0],in_RightOperand[0],in_LowCarry);
	//for(ssycnt=1;ssycnt<32;ssycnt=ssycnt+1)
	//begin
	//	{out_HighCarry[ssycnt],tmp[ssycnt]}=OneBitFullAdder(in_LeftOperand[ssycnt],in_RightOperand[ssycnt],out_HighCarry[ssycnt-1]);
	//end
	//out_Carry=out_HighCarry[31];

	out_Result=tmp[`WordWidth-1:0];
	
	if(tmp==`WordZero)
		out_Zero=1'b1;
	else
		out_Zero=1'b0;
		
	if(in_LeftOperand[`WordWidth-1]==in_RightOperand[`WordWidth-1] && tmp[`WordWidth-1]!=in_RightOperand[`WordWidth-1])
		out_Overflow=1'b1;
	else
		out_Overflow=1'b0;
		
	out_Neg=tmp[`WordWidth-1];
end
endmodule