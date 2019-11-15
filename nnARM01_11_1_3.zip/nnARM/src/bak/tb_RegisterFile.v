`include "RegisterFile.v"

module tb_RegisterFile;
reg in_LeftReadEnable,in_RightReadEnable,in_WriteEnable;
reg [`Def_RegisterSelectWidth-1:0] in_LeftReadRegisterNumber,in_RightReadRegisterNumber,in_WriteRegisterNumber;
reg [`WordWidth-1:0] in_WriteBus;
reg clock,reset;

wire [`WordWidth-1:0] out_LeftReadBus,out_RightReadBus;

integer ssycnt;
RegisterFile	Inst_RegisterFile(	in_LeftReadEnable,
			in_LeftReadRegisterNumber,
			out_LeftReadBus,
			in_RightReadEnable,
			in_RightReadRegisterNumber,
			out_RightReadBus,
			in_WriteEnable,
			in_WriteRegisterNumber,
			in_WriteBus,
			clock,
			reset
);


initial 
begin
	reset=1'b1;
	clock=1'b0;
	#10
	reset=1'b0;
	#100
	reset=1'b1;
	for(ssycnt=0;ssycnt<`Def_RegisterNumber;ssycnt=ssycnt+1)
	begin
		#200
		in_WriteEnable=1'b1;
		in_WriteRegisterNumber=ssycnt;
		in_WriteBus=ssycnt;
	end
	for(ssycnt=0;ssycnt<`Def_RegisterNumber;ssycnt=ssycnt+1)
	begin
		#200
		in_LeftReadEnable=1'b1;
		in_LeftReadRegisterNumber=ssycnt;
	end	
end

always
begin
	#100
	clock=~clock;
end


endmodule