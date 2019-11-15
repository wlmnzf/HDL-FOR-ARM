`include	"nnARMCore.v"
module nnARM(	//data memory
		DataMemoryBus,		//data bus 
		nDataMemoryWait,	//wait for valid value,this signal can not be used directly by external device other than cpu,because after the CPU send out memory request ,the memory can disable this signal only after 1 cycle
		out_DataMemoryAddress,	//address bus
		out_DataMemoryRW,	//1 read ,0 write, you may need to invert it to connect to memory
		out_DataMemoryEnable,	//1 enable, you may need to invert to connect to memory
		//instruction memory
		MemoryBus,		//instruction bus
		nMemoryWait,		//instruction memory wait
		InstructionAddress,	//instruction address
		MemoryRequest,		//1 enable, you need to invert it to connect to memory
		clock,
		reset);

input clock,reset;

//the signal between MemoryController and InstructionCache
inout [`MemoryBusWidth-1:0] MemoryBus;
input nMemoryWait;
output [`AddressBusWidth-1:0] InstructionAddress;
output nRW,nBW,MemoryRequest;

//signal between data cache and data memory
output	[`AddressBusWidth-1:0]		out_DataMemoryAddress;
inout	[`WordWidth-1:0]		DataMemoryBus;
output					out_DataMemoryEnable,
					out_DataMemoryRW;
input					nDataMemoryWait;

//the signal between instruction cache and instruction prefetch
wire [`InstructionCacheLineWidth-1:0] InstructionOut;
wire InstructionWait;
wire [`AddressBusWidth-1:0] PreFetchedAddress;
wire PreFetchedRequest;

//signal between mem and data cache
wire	[`AddressBusWidth-1:0]		out_MEMAccessAddress;
wire					out_MEMAccessRequest,
					out_MEMAccessRW,
					out_MEMAccessBW;
wire					out_DataCacheWait;
wire	[`WordWidth-1:0]		DataCacheBus;


nnARMCore	inst_nnARMCore(//the signal between instruction cache and instruction prefetch
		.InstructionOut(InstructionOut),
		.InstructionWait(InstructionWait),
		.PreFetchedAddress(PreFetchedAddress),
		.PreFetchedRequest(PreFetchedRequest),
		//signal between mem and DataCacheController
		.out_MEMAccessAddress(out_MEMAccessAddress),		//data address
		.DataCacheBus(DataCacheBus),		//data value for write and read
		.out_MEMAccessRequest(out_MEMAccessRequest),	//enable access
		.out_MEMAccessBW(out_MEMAccessBW),			//1 means byte,0 means word
		.out_MEMAccessRW(out_MEMAccessRW),			//1 means read,0 means write
		.out_DataCacheWait(out_DataCacheWait),		//wait for free	
		.clock(clock),
		.reset(reset)
		);

InstructionCacheController inst_InstructionCacheController(
			.InstructionOut(InstructionOut),
			.InstructionWait(InstructionWait),
			.InstructionAddress(PreFetchedAddress),
			.InstructionRequest(PreFetchedRequest),
			//below is the memory access
			.MemoryBus(MemoryBus),
			.MemoryAddress(InstructionAddress),
			.MemoryRequest(MemoryRequest),
			.nMemoryWait(nMemoryWait),
			.clock(clock),
			.reset(reset)
			);

DataCacheController inst_DataCacheController(	//signal between mem and DataCacheController
			.in_DataCacheAddress(out_MEMAccessAddress),		//data address
			.io_DataCacheBus(DataCacheBus),		//data value for write and read
			.in_DataCacheAccessEnable(out_MEMAccessRequest),	//enable access
			.in_DataCacheBW(out_MEMAccessBW),			//1 means byte,0 means word
			.in_DataCacheRW(out_MEMAccessRW),			//1 means read,0 means write
			.out_DataCacheWait(out_DataCacheWait),		//wait for free
			//signal between DataCacheController and MemoryCotroller
			.out_DataMemoryAddress(out_DataMemoryAddress),		//address goto memory
			.io_DataMemoryBus(DataMemoryBus),	//data value for write to memory
			.out_DataMemoryEnable(out_DataMemoryEnable),		//enable accesss
			.out_DataMemoryRW(out_DataMemoryRW),			//1 means read, 0 means write
			.in_DataMemoryWait(~nDataMemoryWait),		//wait for memory
			//signal for clock and reset
			.clock(clock),
			.reset(reset)
			);

//copy following code to you favor place for memory
/*
MemoryController inst_DataMemoryController(
			.DataBus(DataMemoryBus),	//data bus ,bidirection
			.nWAIT(nDataMemoryWait),	//wait for valid value,this signal can not be used directly by external device other than cpu,because after the CPU send out memory request ,the memory can disable this signal only after 1 cycle
			.AddressBus(out_DataMemoryAddress),	//address bus
			.nRW(~out_DataMemoryRW),		//0 is read,1 is write
			.nBW(1'b1),		//0 is read byte,1 is read word ,not support
			.nMREQ(~out_DataMemoryEnable),		//0 is memory request,1 is for other device(coprocessor)
			.SEQ(1'b0),		//1 is sequential access mode ,
			.MCLK(clock),		//main clock
			.nRESET(reset)
			);


MemoryController inst_MemoryController(
			.DataBus(MemoryBus),	//data bus ,bidirection
			.nWAIT(nMemoryWait),	//wait for valid value,this signal can not be used directly by external device other than cpu,because after the CPU send out memory request ,the memory can disable this signal only after 1 cycle
			.AddressBus(InstructionAddress),	//address bus
			.nRW(1'b0),		//0 is read,1 is write
			.nBW(1'b1),		//0 is read byte,1 is read word ,not support
			.nMREQ(~MemoryRequest),		//0 is memory request,1 is for other device(coprocessor)
			.SEQ(1'b0),		//1 is sequential access mode ,
			.MCLK(clock),		//main clock
			.nRESET(reset)
			);
*/
endmodule