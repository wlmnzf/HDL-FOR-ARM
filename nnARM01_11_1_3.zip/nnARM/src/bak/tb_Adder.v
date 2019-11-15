`include "Def_StructureParameter.v"
`include "Adder.v"

module tb_Adder;

reg [`WordWidth-1:0] in_LeftOperand,in_RightOperand;
reg in_LowCarry;
wire [`WordWidth-1:0] out_Result;
wire out_Carry,out_Zero,out_Neg,out_Overflow;


WordAdder I1(out_Result,
		out_Carry,
		out_Zero,
		out_Neg,
		out_Overflow,
		in_LeftOperand,
		in_RightOperand,
		in_LowCarry);
		
initial
begin
	in_LowCarry=1'b0;
	in_LeftOperand=32'h00001011;
	in_RightOperand=32'h10001010;
	
	#100
	in_LeftOperand=32'h70001011;
	in_RightOperand=32'h70001010;
	
	#100
	in_LeftOperand=32'h00001011;
	in_RightOperand=32'hf0001010;
	
	#100
	in_LeftOperand=32'hf0001011;
	in_RightOperand=32'hf0001010;
	
	#100
	in_LeftOperand=32'h80001011;
	in_RightOperand=32'h80001010;
	
	#100
	$stop;
	$finish;
end
endmodule