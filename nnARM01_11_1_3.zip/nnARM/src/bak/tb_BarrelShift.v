`include "BarrelShift.v"
`include "Def_BarrelShift.v"

module tb_BarrelShift;
reg [`WordWidth-1:0] in_ShiftIn;
reg [1:0] in_ShiftType;
reg [4:0] in_ShiftCount;
reg clock,reset;
wire [`WordWidth-1:0] out_ShiftOut;

BarrelShift 	I1(	out_ShiftOut,
			in_ShiftIn,
			in_ShiftCount,
			in_ShiftType);
			
initial
begin
	clock=1'b0;
	reset=1'b1;
	
	#10
	reset=1'b0;
	
	#100
	reset=1'b1;
	
	#200
	in_ShiftIn=32'b1110_0100_0010_0000_0010_0000_0010_1101;
	in_ShiftType=`Def_ShiftType_LogicLeft;
	in_ShiftCount=5'b1111;
	
	#200
	in_ShiftIn=32'b1110_0100_0010_0000_0010_0000_0010_1101;
	in_ShiftType=`Def_ShiftType_LogicRight;
	in_ShiftCount=5'b1111;
	
	#200
	in_ShiftIn=32'b1110_0100_0010_0000_0010_0000_0010_1101;
	in_ShiftType=`Def_ShiftType_ArithmeticRight;
	in_ShiftCount=5'b1111;
	
	#200
	in_ShiftIn=32'b1110_0100_0010_0000_0010_0000_0010_1101;
	in_ShiftType=`Def_ShiftType_RotateRight;
	in_ShiftCount=5'b1111;

	#200
	$stop;
	$finish;	
end

always
begin
	#100 clock=~clock;
end
endmodule