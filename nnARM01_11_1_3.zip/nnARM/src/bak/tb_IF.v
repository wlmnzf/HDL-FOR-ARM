`include "Def_StructureParameter.v"
`include "InstructionPreFetch.v"
`include "MemoryController.v"
`include "InstructionCacheController.v"
`include "Pipeline.v"

module tb_InstructionPreFetch;
reg clock,reset;
wire [`AddressBusWidth-1:0] PreFetchedAddress,MemoryAddress;
wire [`InstructionWidth-1:0] Instruction;
wire Wait,PreFetchedWait,PreFetchedRequest,MemoryRequest,nMemoryWait;
wire [4*(`InstructionWidth)-1:0] PreFetchedInstructions;
wire [`MemoryBusWidth-1:0] MemoryBus;
wire [`AddressBusWidth-1:0] Address;

integer ssycnt;


Pipeline	Inst_Pipeline(Instruction,
		Wait,
		Address,
		//above is for Instruction fetch
		clock,
		reset
		);

InstructionPreFetch Inst_InstructionPreFetch(Instruction,
				Wait,
				Address,
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
		Inst_MemoryController.Memory[ssycnt]=ssycnt;
	end


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