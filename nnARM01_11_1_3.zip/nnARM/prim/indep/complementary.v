module complementary(out_Result,
			in_Operand);
			
output [`WordWidth-1:0] out_Result;
reg [`WordWidth-1:0] out_Result;

input [`WordWidth-1:0] in_Operand;

reg [`WordWidth-1:0] flag;

integer ssycnt;

always @(in_Operand)
begin
	flag=`WordZero;
	out_Result[0]=in_Operand[0];
	if(in_Operand[0]==1'b1)
		flag[0]=1'b1;
	for(ssycnt=1;ssycnt<`WordWidth;ssycnt=ssycnt+1)
	begin
		if(flag[ssycnt-1]==1'b1)
		begin
			//i have see a 1,now all will bw invert
			out_Result[ssycnt]=~in_Operand[ssycnt];
			flag[ssycnt]=1'b1;
		end
		else
		begin
			//i have not see a 1
			if(in_Operand[ssycnt]==1'b1)
			begin
				//now see a 1
				flag[ssycnt]=1'b1;
			end
			else
			begin
				flag[ssycnt]=1'b0;
			end
			out_Result[ssycnt]=in_Operand[ssycnt];
		end
	end
end

endmodule