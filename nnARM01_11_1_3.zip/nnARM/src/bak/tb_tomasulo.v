`include "Def_StructureParameter.v"
`include "InstructionPreFetch.v"
`include "MemoryController.v"
`include "InstructionCacheController.v"
`include "Pipeline.v"
`include "ALUShell.v"
`include "Arbitrator.v"
`include "RegisterFile.v"
`include "TestInstruction.v"

module tb_InstructionPreFetch;
reg clock,reset;
wire [`AddressBusWidth-1:0] PreFetchedAddress,MemoryAddress;
wire [`InstructionWidth-1:0] Instruction;
wire Wait,PreFetchedWait,PreFetchedRequest,MemoryRequest,nMemoryWait;
wire [4*(`InstructionWidth)-1:0] PreFetchedInstructions;
wire [`MemoryBusWidth-1:0] MemoryBus;
wire [`AddressBusWidth-1:0] out_InstructionAddress;

//the three tomasulo bus
wire [`WordWidth-1:0] LeftBus,RightBus,WriteBus;
wire WriteEnable;
wire [`Def_RegisterSelectWidth-1:0] WriteRegisterNumber;
wire out_WriteRequest;
wire [`ByteWidth-1:0] out_WriteComponentEntry;
wire [2:0] out_ALUBlankEntry;
wire [`ByteWidth-1:0] out_ALUType;
wire [`ByteWidth-1:0] out_ALULeftComponentEntry,out_ALURightComponentEntry;
wire [`Def_RegisterSelectWidth-1:0] out_ALUTargetRegister,out_LeftReadRegisterNumber,out_RightReadRegisterNumber;
integer ssycnt;

reg [`InstructionWidth-1:0] TestInstruction;

Arbitrator Inst_Arbitrator(out_WriteRequest,
		out_ALUWriteEnable);

ALUShell Inst_ALUShell(WriteBus,		//write result
		WriteRegisterNumber,	//write to which register
		out_WriteComponentEntry,	//other component entry can listen at this and decide whether to read in
		out_WriteRegisterEnable,
		out_WriteRequest,		//request for a write channel,now there is only one channel
		out_ALUWriteEnable,			//tell ALU that he can use the channel
		//above is signal relate to write
		//below is signal relate to new signal
		out_ALUHaveBlankEntry,
		out_ALUBlankEntry,		//3 bit blank entry
		out_ALUEnable,
		out_ALUType,
		out_ALULeftReadBusOpen,		//1 means use register value,else use function componet
		out_ALURightReadBusOpen,		//1 means use register value,else use function componet
		out_ALULeftComponentEntry,	//which component and entry to use as my operand source
		out_ALURightComponentEntry,	//which component and entry to use as my operand source
		LeftBus,
		RightBus,
		out_ALUTargetRegister,
		clock,
		reset
		);
		
RegisterFile Inst_RegisterFile(	out_LeftReadRegisterEnable,
			out_LeftReadRegisterNumber,
			LeftBus,
			out_RightReadRegisterEnable,
			out_RightReadRegisterNumber,
			RightBus, 
			WriteEnable,
			WriteRegisterNumber,
			WriteBus,
			clock,
			reset
);

Pipeline  Inst_Pipeline(Instruction,		//input from instruction prefetched buffer
		Wait,	//wait for the prefetch buffer 
		out_InstructionAddress,	//output to instruction prefetched buffer
		//above is for Instruction fetch
		//signal for register file
		out_LeftReadRegisterEnable,
		out_LeftReadRegisterNumber,
		out_RightReadRegisterEnable,
		out_RightReadRegisterNumber,
		//out_WriteRegisterEnable,
		//out_WriteRegisterNumber,
		//read signal can be send out by pipeline
		//but the write signal must be send out by the function component itself
		//signal for register file
		//signal for ALU
		out_ALUType,
		out_ALUEnable,
		out_ALULeftReadBusOpen,		//1 means use register value,else use function componet
		out_ALURightReadBusOpen,	//1 means use register value,else use function componet
		out_ALULeftComponentEntry,	//which component and entry to use as my operand source
		out_ALURightComponentEntry,	//which component and entry to use as my operand source
		out_ALUTargetRegister,
		RightBus,	//extended 32bit immediate value 
		out_ALUHaveBlankEntry,		//if ALU have Blank entry?
		out_ALUBlankEntry,		//the blank entry will use by current operation if ALU have Blank entry
		clock,
		reset
		);

InstructionPreFetch Inst_InstructionPreFetch(Instruction,
				Wait,
				out_InstructionAddress,
				//above is the fetched instruction go to pipeline
				//below is the prefetched instruction come from cache or memory
				PreFetchedInstructions,
				PreFetchedWait,
				PreFetchedAddress,
				PreFetchedRequest,
				clock,
				reset);

InstructionCacheController Inst_InstructionCacheController(PreFetchedInstructions,
			PreFetchedWait,
			PreFetchedAddress,
			PreFetchedRequest,
			//below is the memory access
			MemoryBus,
			MemoryAddress,
			MemoryRequest,
			nMemoryWait,
			clock,
			reset
			);

MemoryController  Inst_MemoryController(MemoryBus,
			nMemoryWait,
			MemoryAddress,
			1'b0,
			1'b1,
			~MemoryRequest,
			1'b0,
			clock,
			reset
			);

initial
begin
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//			initial memory				//
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////


	for(ssycnt=0;ssycnt<`MemorySize;ssycnt=ssycnt+1)
	begin
//		Inst_MemoryController.Memory[ssycnt]=ssycnt;
		Inst_MemoryController.Memory[ssycnt]=`ByteZero;
	end

	TestInstruction=`TestInstruction_Add1;
	Inst_MemoryController.Memory[0]=TestInstruction[7:0];
	Inst_MemoryController.Memory[1]=TestInstruction[15:8];
	Inst_MemoryController.Memory[2]=TestInstruction[23:16];
	Inst_MemoryController.Memory[3]=TestInstruction[31:24];

	TestInstruction=`TestInstruction_Add2;
	Inst_MemoryController.Memory[4]=TestInstruction[7:0];
	Inst_MemoryController.Memory[5]=TestInstruction[15:8];
	Inst_MemoryController.Memory[6]=TestInstruction[23:16];
	Inst_MemoryController.Memory[7]=TestInstruction[31:24];


	clock=1'b0;
	reset=1'b1;

	#10
	reset=1'b0;

	#500
	reset<=1'b1;

end


always
begin
	#50 clock=~clock;
end

endmodule