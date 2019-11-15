module	MemoryMux(//instruction cache signal
				out_InstructionBus,
				out_InstructionWait,
				in_InstructionAddress,
				in_InstructionRequest,
				//data cache signal
				io_DataBus,
				out_DataWait,
				in_DataAddress,
				in_DataRequest,
				in_DataRW,
				//to memory
				io_MemoryBus,
				in_MemoryWait,
				out_MemoryAddress,
				out_MemoryRequest,
				out_MemoryRW);

endmodule