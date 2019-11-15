`include "Complementary.v"

module tb_Complementary;

reg clock,reset;
reg [`WordWidth-1:0] in_Operand;
wire [`WordWidth-1:0] out_Result;

complementary I1(out_Result,in_Operand);
initial
begin
	clock=1'b0;
	reset=1'b1;
	#10
	reset=1'b0;
	#100
	reset=1'b1;

	in_Operand=32'b0000_1001_0000_0111_1001_1110_0111_0000;

	#1000
	$stop;
	$finish;
end

always
begin
	#100
	clock=~clock;
end
endmodule