`include "Def_StructureParameter.v"
`include "InstructionPreFetch.v"
`include "MemoryController.v"
`include "InstructionCacheController.v"

module tb_InstructionPreFetch;
reg clock,reset;
reg [`AddressBusWidth-1:0] Address,Address1;
wire [`AddressBusWidth-1:0] PreFetchedAddress,MemoryAddress;
wire [`InstructionWidth-1:0] Instruction;
wire Wait,PreFetchedWait,PreFetchedRequest,MemoryRequest,nMemoryWait;
wire [4*(`InstructionWidth)-1:0] PreFetchedInstructions;
wire [`MemoryBusWidth-1:0] MemoryBus;

integer ssycnt;

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

	Address=0;
end


always
begin
	#50 clock=~clock;
end

always @(posedge clock)
begin
	if(reset==1'b1)
	begin
		if(Wait==1'b0)
		begin
			//send out instruction fetch
			//following is the sequense generate address
			Address=Address+4;

			//and the following address is random generate
			//Address1=$random;
			//Address={12'h000,Address1[19:2],2'b00};
			$monitor($time,"pipeline request address:	%h",Address);
		end
	end
end
endmodule