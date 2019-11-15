`include "timescalar.v"
`include "nnARM.v"
`include "TestInstruction.v"
`include "Def_StructureParameter.v"
`include "Def_SimulationParameter.v"

module tb_system;

integer ssycnt;
reg clock,reset;
reg [`InstructionWidth-1:0] TestInstruction;
nnARM inst_nnARM(.clock(clock),
		.reset(reset));
		
initial
begin
//	for(ssycnt=0;ssycnt<`MemorySize;ssycnt=ssycnt+1)
//	begin
//		inst_nnARM.inst_DataMemoryController.Memory[ssycnt]=ssycnt;
//	end

//	TestInstruction=`TestInstruction_Add1;
//	inst_nnARM.inst_MemoryController.Memory[0]=TestInstruction[7:0];
//	inst_nnARM.inst_MemoryController.Memory[1]=TestInstruction[15:8];
//	inst_nnARM.inst_MemoryController.Memory[2]=TestInstruction[23:16];
//	inst_nnARM.inst_MemoryController.Memory[3]=TestInstruction[31:24];

//	TestInstruction=`TestInstruction_Add2;
//	inst_nnARM.inst_MemoryController.Memory[4]=TestInstruction[7:0];
//	inst_nnARM.inst_MemoryController.Memory[5]=TestInstruction[15:8];
//	inst_nnARM.inst_MemoryController.Memory[6]=TestInstruction[23:16];
//	inst_nnARM.inst_MemoryController.Memory[7]=TestInstruction[31:24];

	clock=1'b0;
	reset=1'b1;
	#10
	reset=1'b0;
	#500
	reset=1'b1;
	
end

initial
begin
	$readmemh("asc",inst_nnARM.inst_MemoryController.Memory);
	$readmemh("asc",inst_nnARM.inst_DataMemoryController.Memory);
end

always
begin
	#(`HalfClockCycle)
	begin
		clock=~clock;
		if(inst_nnARM.inst_RegisterFile.Registers1==32'h00020026)
			$finish();
	end
end

//always
//begin
//	if(inst_nnARM.inst_RegisterFile.Registers1==32'h00020026)
//		$finish();
//end

endmodule