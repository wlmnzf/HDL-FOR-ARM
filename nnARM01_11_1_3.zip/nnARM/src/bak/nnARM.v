`include "Def_StructureParameter.v"
`include "InstructionPreFetch.v"
`include "MemoryController.v"
`include "InstructionCacheController.v"
`include "DataCacheController.v"
`include "IF.v"
`include "Decoder_ARM.v"
`include "ALUShell.v"
`include "ALUComb.v"
`include "mem.v"
`include "wb.v"
`include "Arbitrator.v"
`include "RegisterFile.v"
`include "BusTransfer.v"
`include "CanGoGen.v"
`include "psr.v"

module nnARM(clock,
		reset);
//global signal 
input clock,reset;

//the signal between MemoryController and InstructionCache
wire [`MemoryBusWidth-1:0] MemoryBus;
wire nMemoryWait;
wire [`AddressBusWidth-1:0] InstructionAddress;
wire nRW,nBW,MemoryRequest,SEQ;

//the signal between instruction cache and instruction prefetch
wire [`InstructionCacheLineWidth-1:0] InstructionOut;
wire InstructionWait;
wire [`AddressBusWidth-1:0] PreFetchedAddress;
wire PreFetchedRequest;

//signal between instruction prefetch and if
wire Wait;
wire [`InstructionWidth-1:0] Instruction;
wire [`AddressBusWidth-1:0] out_InstructionAddress,out_NextInstructionAddress;

//signal between if and register file
//use to update pc and read pc
wire		out_FourthReadRegisterEnable;
wire	[`Def_RegisterSelectWidth-1:0]	out_FourthReadRegisterNumber;
wire	[`WordWidth-1:0] FourthReadBus;
wire		out_SecondWriteRegisterEnable;
wire	[`Def_RegisterSelectWidth-1:0]	out_SecondWriteRegisterNumber;
wire	[`WordWidth-1:0]	SecondWriteBus;

//signal between if and id
wire  [`InstructionWidth-1:0]	Pipeline_IFID;
wire					Valid_Pipeline_IFID;
wire	[`AddressBusWidth-1:0]	out_AddressGoWithInstruction;

//signal between id and register file
wire	out_LeftReadRegisterEnable,out_RightReadRegisterEnable,out_ThirdReadRegisterEnable;
wire	[`Def_RegisterSelectWidth-1:0]	out_LeftReadRegisterNumber,out_RightReadRegisterNumber,out_ThirdReadRegisterNumber;

//signal between decoder and alu
wire out_ALUEnable;
wire [`ByteWidth-1:0] out_ALUType;
wire [`Def_RegisterSelectWidth-1:0] out_ALULeftRegister;
wire [`Def_RegisterSelectWidth-1:0] out_ALURightRegister;
wire [`Def_RegisterSelectWidth-1:0] out_ALUThirdRegister;
wire out_ALULeftFromImm;
wire out_ALURightFromImm;
wire out_ALUThirdFromImm;
wire out_CPSRFromImm;
wire out_SPSRFromImm;
wire [`Def_RegisterSelectWidth-1:0] out_ALUTargetRegister;
wire [`Def_ShiftTypeWidth-1:0] out_ALURightShiftType;
wire [`ByteWidth-1:0]	out_SimpleALUType;
wire [`Def_RegisterSelectWidth-1:0]	out_SimpleALUTargetRegister;
wire [`WordWidth-1:0]			out_ALUMisc;
wire [`ByteWidth-1:0]			out_ALUPSRType;
wire [`AddressBusWidth-1:0]		out_NextAddressGoWithInstruction2ALU;

//signal bwtween decoder and mem
wire			out_MEMEnable;
wire [`ByteWidth-1:0]	out_MEMType;
wire [`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister;
wire [`ByteWidth-1:0]	out_SimpleMEMType;
wire [`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister;
wire [`ByteWidth-1:0]			out_MEMPSRType;

//signal go from alu to mem
wire	out_ALUWriteEnable;
wire	[`WordWidth-1:0]  out_ALUWriteBus;
wire	[`WordWidth-1:0]	out_ALUCPSR2MEM,out_ALUSPSR2MEM;
wire	[`Def_RegisterSelectWidth-1:0] out_ALUTargetRegister2MEM;
wire	[`WordWidth-1:0]			out_SimpleALUResult2MEM;
wire	[`Def_RegisterSelectWidth-1:0]	out_SimpleALUTargetRegister2MEM;
wire	[`ByteWidth-1:0]			out_MEMType2MEM;
wire	[`Def_RegisterSelectWidth-1:0]			out_MEMTargetRegister2MEM;
wire	[`ByteWidth-1:0]			out_SimpleMEMType2MEM;
wire	[`Def_RegisterSelectWidth-1:0]			out_SimpleMEMTargetRegister2MEM;
wire	[`WordWidth-1:0]				out_StoredValue;
wire	[`ByteWidth-1:0]				out_MEMPSRType2MEM,out_ALUPSRType2MEM;
wire						out_IsLoadToPC;
wire						out_IfChangeState2MEM;
wire	[4:0]					out_ChangeStateAction2MEM;

//signal go out of mem and into wb and forward to alu
wire			out_MEMWriteEnable;
wire	[`WordWidth-1:0]	out_MEMWriteResult;
wire	[`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister2WB;
wire	[`WordWidth-1:0]			out_SimpleMEMResult2WB;
wire	[`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister2WB;
wire	[`ByteWidth-1:0]		out_MEMPSRType2WB;
wire	[`WordWidth-1:0]		out_CPSR2WB,out_SPSR2WB;

//connection between ALUShell and ALUComb
wire	[`WordWidth-1:0]	ALUCombResult;
wire			Carry,Zero,Neg,Overflow;
wire	[`ByteWidth-1:0]	ALUComb_ALUType;
wire	[`WordWidth-1:0]	ALUComb_LeftOperand,
			ALUComb_RightOperand,
			ALUComb_ThirdOperand;
wire	[`Def_ShiftTypeWidth-1:0]	ALUComb_RightOperandShiftType;
wire	[`Def_ShiftCountWidth-1:0]	ALUComb_RightOperandShiftCount;
wire	[2:0]				ALUComb_ShiftCountHigh3Bit;
wire					ALUComb_ShiftCountInReg;
wire					ALUComb_Carry,ALUComb_Neg,ALUComb_Zero,ALUComb_Overflow;

//who can go and who can not go
wire	out_IFCanGo,out_IFOwnCanGo;
wire	out_IDCanGo,out_IDOwnCanGo;
wire	out_EXECanGo,out_EXEOwnCanGo;
wire	out_MEMCanGo,out_MEMOwnCanGo;

//signal between mem and data cache
wire	[`AddressBusWidth-1:0]		out_MEMAccessAddress;
wire					out_MEMAccessRequest,
					out_MEMAccessRW,
					out_MEMAccessBW;
wire					out_DataCacheWait;
wire	[`WordWidth-1:0]		DataCacheBus;
					

//signal between data cache and data memory
wire	[`AddressBusWidth-1:0]		out_DataMemoryAddress;
wire	[`WordWidth-1:0]		DataMemoryBus;
wire					out_DataMemoryEnable,
					out_DataMemoryRW;
wire					nDataMemoryWait;

//psr register file
wire	[`WordWidth-1:0]		out_CPSR,out_SPSR;
wire					in_SPSRWriteEnable;
wire					in_CPSRWriteEnable;
wire	[`WordWidth-1:0]		out_CPSRWriteValue,out_SPSRWriteValue;
wire	[4:0]				out_ChangeStateAction2WB;
wire					out_IfChangeState2WB;

//alu send out these signal to if to update pc
wire					out_ChangePC;
wire	[`AddressBusWidth-1:0]		out_NewPC;

//mem send out these signal to if to update pc
wire					out_MEMChangePC;
wire	[`AddressBusWidth-1:0]		out_MEMNewPC;

//global signal
wire [`WordWidth-1:0] LeftReadBus,RightReadBus,ThirdReadBus,WriteBus,SecondWriteBus,ThirdWriteBus;
wire WriteRegisterEnable,ThirdWriteRegisterEnable;
wire [`Def_RegisterSelectWidth-1:0] WriteRegisterNumber,ThirdWriteRegisterNumber;

CanGoGen		inst_CanGoGen(.out_IFCanGo(out_IFCanGo),
					.out_IDCanGo(out_IDCanGo),
					.out_EXECanGo(out_EXECanGo),
					.out_MEMCanGo(out_MEMCanGo),
					.in_IFOwnCanGo(out_IFOwnCanGo),
					.in_IDOwnCanGo(out_IDOwnCanGo),
					.in_EXEOwnCanGo(out_EXEOwnCanGo),
					.in_MEMOwnCanGo(out_MEMOwnCanGo)
);

StatusRegisters		inst_StatusRegisters(	//change of state
			.in_IfChangeState(out_IfChangeState2WB),
			.in_ChangeStateAction(out_ChangeStateAction2WB),
			//write to register
			.in_CPSRWriteEnable(out_CPSRWriteEnable),
			.in_CPSRWriteValue(out_CPSRWriteValue),
			.in_SPSRWriteEnable(out_SPSRWriteEnable),
			.in_SPSRWriteValue(out_SPSRWriteValue),
			//output of status register
			.out_CPSR(out_CPSR),
			.out_SPSR(out_SPSR),
			.clock(clock),
			.reset(reset)
);


RegisterFile  inst_RegisterFile(	//change of state
			.in_IfChangeState(out_IfChangeState2WB),
			.in_ChangeStateAction(out_ChangeStateAction2WB),
			.in_LeftReadEnable(out_LeftReadRegisterEnable),
			.in_LeftReadRegisterNumber(out_LeftReadRegisterNumber),
			.out_LeftReadBus(LeftReadBus),
			.in_RightReadEnable(out_RightReadRegisterEnable),
			.in_RightReadRegisterNumber(out_RightReadRegisterNumber),
			.out_RightReadBus(RightReadBus),
			.in_ThirdReadEnable(out_ThirdReadRegisterEnable),
			.in_ThirdReadRegisterNumber(out_ThirdReadRegisterNumber),
			.out_ThirdReadBus(ThirdReadBus),
			.in_FourthReadEnable(out_FourthReadRegisterEnable),
			.in_FourthReadRegisterNumber(out_FourthReadRegisterNumber),
			.out_FourthReadBus(FourthReadBus),
			.in_WriteEnable(WriteRegisterEnable),
			.in_WriteRegisterNumber(WriteRegisterNumber),
			.in_WriteBus(WriteBus),
			.in_SecondWriteEnable(out_SecondWriteRegisterEnable),
			.in_SecondWriteRegisterNumber(out_SecondWriteRegisterNumber),
			.in_SecondWriteBus(SecondWriteBus),
			.in_ThirdWriteEnable(ThirdWriteRegisterEnable),
			.in_ThirdWriteRegisterNumber(ThirdWriteRegisterNumber),
			.in_ThirdWriteBus(ThirdWriteBus),
			//the processor mode
			.in_ProcessorMode(out_CPSR[4:0]),
			.clock(clock),
			.reset(reset)
);

//WB	inst_WB(//the write to register file
//		.out_WBWriteBus(WriteBus),
//		.out_WBWriteEnable(WriteRegisterEnable),
//		.out_WBWriteTargetRegister(WriteRegisterNumber),
		//input from mem
//		.in_MEMWriteEnable(out_MEMWriteEnable),
//		.in_MEMWriteResult(out_MEMWriteResult),
//		.in_MEMWriteTargetRegister(out_MEMTargetRegister),
//		.clock(clock),
//		.reset(reset)
//		);


MEM	inst_MEM(	//signal from ALU
			.in_ALUValid(out_ALUWriteEnable),
			.in_ALUWriteBus(out_ALUWriteBus),
			.in_ALUTargetRegister(out_ALUTargetRegister2MEM),
			.in_SimpleALUResult(out_SimpleALUResult2MEM),
			.in_SimpleALUTargetRegister(out_SimpleALUTargetRegister2MEM),
			.in_StoredValue(out_StoredValue),
			.in_CPSR(out_ALUCPSR2MEM),
			.in_SPSR(out_ALUSPSR2MEM),
			.in_IfChangeState(out_IfChangeState2MEM),
			.in_ChangeStateAction(out_ChangeStateAction2MEM),
			//signal come from alu that origin come from decoder
			.in_MEMType(out_MEMType2MEM),
			.in_MEMTargetRegister(out_MEMTargetRegister2MEM),
			.in_SimpleMEMType(out_SimpleMEMType2MEM),
			.in_SimpleMEMTargetRegister(out_SimpleMEMTargetRegister2MEM),
			.in_MEMPSRType(out_MEMPSRType2MEM),
			.in_IsLoadToPC(out_IsLoadToPC),
			//signal goto wb
			.out_MEMWriteEnable(out_MEMWriteEnable),
			.out_MEMWriteResult(out_MEMWriteResult),
			.out_MEMTargetRegister(out_MEMTargetRegister2WB),
			.out_SimpleMEMResult(out_SimpleMEMResult2WB),
			.out_SimpleMEMTargetRegister(out_SimpleMEMTargetRegister2WB),
			.out_MEMPSRType2WB(out_MEMPSRType2WB),
			.out_CPSR2WB(out_CPSR2WB),
			.out_SPSR2WB(out_SPSR2WB),
			.out_IfChangeState(out_IfChangeState2WB),
			.out_ChangeStateAction(out_ChangeStateAction2WB),
			//the first and third write bus
			.out_WriteBus(WriteBus),
			.out_WriteRegisterEnable(WriteRegisterEnable),
			.out_WriteRegisterNumber(WriteRegisterNumber),
			.out_ThirdWriteBus(ThirdWriteBus),
			.out_ThirdWriteRegisterEnable(ThirdWriteRegisterEnable),
			.out_ThirdWriteRegisterNumber(ThirdWriteRegisterNumber),
			.out_CPSR2PSR(out_CPSRWriteValue),
			.out_CPSRWriteEnable(out_CPSRWriteEnable),
			.out_SPSR2PSR(out_SPSRWriteValue),
			.out_SPSRWriteEnable(out_SPSRWriteEnable),
			//can MEM go?
			.out_MEMOwnCanGo(out_MEMOwnCanGo),
			.in_EXECanGo(out_EXECanGo),
			//signal relate to load/store
			.out_MEMAccessAddress(out_MEMAccessAddress),
			.out_MEMAccessRequest(out_MEMAccessRequest),
			.out_MEMAccessRW(out_MEMAccessRW),
			.out_MEMAccessBW(out_MEMAccessBW),
			.in_DataCacheWait(out_DataCacheWait),
			.io_DataBus(DataCacheBus),
			//signal relate to change pc
			.out_MEMChangePC(out_MEMChangePC),
			.out_MEMNewPC(out_MEMNewPC),
			//other signal
			.clock(clock),
			.reset(reset)
			);


ALUComb inst_ALUComb(.ALUCombResult(ALUCombResult),
		.out_Carry(Carry),
		.out_Zero(Zero),
		.out_Neg(Neg),
		.out_Overflow(Overflow),
		.ALUComb_ALUType(ALUComb_ALUType),
		.ALUComb_LeftOperand(ALUComb_LeftOperand),
		.ALUComb_RightOperand(ALUComb_RightOperand),
		.ALUComb_ThirdOperand(ALUComb_ThirdOperand),
		.ALUComb_RightOperandShiftType(ALUComb_RightOperandShiftType),
		.ALUComb_RightOperandShiftCount(ALUComb_RightOperandShiftCount),
		.ALUComb_ShiftCountInReg(ALUComb_ShiftCountInReg),	//shift count in register
		.ALUComb_ShiftCountHigh3Bit(ALUComb_ShiftCountHigh3Bit),	//the [7:5] bit of shoft count when shift count is in register
		.in_Carry(ALUComb_Carry),
		.in_Overflow(ALUComb_Overflow),
		.in_Neg(ALUComb_Neg),
		.in_Zero(ALUComb_Zero)
);


ALUShell inst_ALUShell(.out_ALUWriteEnable(out_ALUWriteEnable),
		.out_ALUWriteBus(out_ALUWriteBus),		//write result
		.out_CPSR(out_ALUCPSR2MEM),
		.out_SPSR(out_ALUSPSR2MEM),
		.out_ALUTargetRegister(out_ALUTargetRegister2MEM),	//write to which register
		.out_SimpleALUResult(out_SimpleALUResult2MEM),
		.out_SimpleALUTargetRegister(out_SimpleALUTargetRegister2MEM),
		.out_MEMType(out_MEMType2MEM),
		.out_MEMTargetRegister(out_MEMTargetRegister2MEM),
		.out_SimpleMEMType(out_SimpleMEMType2MEM),
		.out_SimpleMEMTargetRegister(out_SimpleMEMTargetRegister2MEM),
		.out_StoredValue(out_StoredValue),
		.out_ALUPSRType(out_ALUPSRType2MEM),
		.out_MEMPSRType(out_MEMPSRType2MEM),
		.out_IsLoadToPC(out_IsLoadToPC),
		.out_IfChangeState(out_IfChangeState2MEM),
		.out_ChangeStateAction(out_ChangeStateAction2MEM),
		//above is signal relate to write
		//below is signal relate to new operation come from decoder
		.in_ALUEnable(out_ALUEnable),
		.in_ALUType(out_ALUType),
		.in_ALULeftRegister(out_ALULeftRegister),		
		.in_ALURightRegister(out_ALURightRegister),		
		.in_ALUThirdRegister(out_ALUThirdRegister),
		.in_ALULeftFromImm(out_ALULeftFromImm),
		.in_ALURightFromImm(out_ALURightFromImm),
		.in_ALUThirdFromImm(out_ALUThirdFromImm),
		.in_CPSRFromImm(out_CPSRFromImm),
		.in_SPSRFromImm(out_SPSRFromImm),
		.in_ALURightShiftType(out_ALURightShiftType),
		.in_ALULeftReadBus(LeftReadBus),
		.in_ALURightReadBus(RightReadBus),
		.in_ALUThirdReadBus(ThirdReadBus),
		.in_ALUCPSRReadBus(out_CPSR),
		.in_ALUSPSRReadBus(out_SPSR),
		.in_ALUTargetRegister(out_ALUTargetRegister),
		.in_SimpleALUType(out_SimpleALUType),
		.in_SimpleALUTargetRegister(out_SimpleALUTargetRegister),
		.in_ALUMisc(out_ALUMisc),		//some special signal
		.in_ALUPSRType(out_ALUPSRType),
		.in_NextAddressGoWithInstruction2ALU(out_NextAddressGoWithInstruction2ALU),
		//pass to mem stage for this instruction's mem operation
		.in_MEMEnable(out_MEMEnable),
		.in_MEMType(out_MEMType),
		.in_MEMTargetRegister(out_MEMTargetRegister),
		.in_SimpleMEMType(out_SimpleMEMType),
		.in_SimpleMEMTargetRegister(out_SimpleMEMTargetRegister),
		.in_MEMPSRType(out_MEMPSRType),
		//below is signal relate to forward operand from mem stage
		.in_MEMWriteEnable(out_MEMWriteEnable),
		.in_MEMWriteResult(out_MEMWriteResult),
		.in_MEMTargetRegister2WB(out_MEMTargetRegister2WB),
		.in_SimpleMEMResult(out_SimpleMEMResult2WB),
		.in_SimpleMEMTargetRegister2WB(out_SimpleMEMTargetRegister2WB),
		.in_MEMPSRType2WB(out_MEMPSRType2WB),
		.in_MEMCPSR2WB(out_CPSR2WB),
		.in_MEMSPSR2WB(out_SPSR2WB),
		//below is signal relate to ALUComb connection
		.ALUCombResult(ALUCombResult),
		.in_Carry(Carry),
		.in_Zero(Zero),
		.in_Neg(Neg),
		.in_Overflow(Overflow),
		.ALUComb_ALUType(ALUComb_ALUType),
		.ALUComb_LeftOperand(ALUComb_LeftOperand),
		.ALUComb_RightOperand(ALUComb_RightOperand),
		.ALUComb_ThirdOperand(ALUComb_ThirdOperand),
		.ALUComb_RightOperandShiftType(ALUComb_RightOperandShiftType),
		.ALUComb_RightOperandShiftCount(ALUComb_RightOperandShiftCount),
		.ALUComb_ShiftCountInReg(ALUComb_ShiftCountInReg),	//shift count in register
		.ALUComb_ShiftCountHigh3Bit(ALUComb_ShiftCountHigh3Bit),	//the [7:5] bit of shoft count when shift count is in register
		//origin CPSR flag
		.ALUComb_Carry(ALUComb_Carry),
		.ALUComb_Neg(ALUComb_Neg),
		.ALUComb_Overflow(ALUComb_Overflow),
		.ALUComb_Zero(ALUComb_Zero),
		//signal relate to pc change in branch instruction
		.out_ChangePC(out_ChangePC),
		.out_NewPC(out_NewPC),
		//can alu go
		.out_ALUOwnCanGo(out_EXEOwnCanGo),
		//can mem go
		.in_MEMCanGo(out_MEMCanGo),
		//mem stage tell you to clear next operation
		.in_MEMChangePC(out_MEMChangePC),
		.clock(clock),
		.reset(reset)
		);


Decoder_ARM  inst_Decoder_ARM(	.in_ValidInstruction_IFID(Valid_Pipeline_IFID),
			.in_PipelineRegister_IFID(Pipeline_IFID),
			.in_AddressGoWithInstruction(out_AddressGoWithInstruction),
			.in_NextInstructionAddress(out_NextInstructionAddress),
			.out_IDOwnCanGo(out_IDOwnCanGo),
			//signal for register file
			.out_LeftReadRegisterEnable(out_LeftReadRegisterEnable),
			.out_LeftReadRegisterNumber(out_LeftReadRegisterNumber),
			.out_RightReadRegisterEnable(out_RightReadRegisterEnable),
			.out_RightReadRegisterNumber(out_RightReadRegisterNumber),
			//use to read the shift count stored in register
			.out_ThirdReadRegisterEnable(out_ThirdReadRegisterEnable),
			.out_ThirdReadRegisterNumber(out_ThirdReadRegisterNumber),
			//signal for register file
			//signal for ALU
			.out_ALUEnable(out_ALUEnable),
			.out_ALUType(out_ALUType),
			.out_ALULeftRegister(out_ALULeftRegister),
			.out_ALURightRegister(out_ALURightRegister),
			.out_ALUThirdRegister(out_ALUThirdRegister),
			.out_ALULeftFromImm(out_ALULeftFromImm),
			.out_ALURightFromImm(out_ALURightFromImm),
			.out_ALUThirdFromImm(out_ALUThirdFromImm),
			.out_CPSRFromImm(out_CPSRFromImm),
			.out_SPSRFromImm(out_SPSRFromImm),
			.out_ALUTargetRegister(out_ALUTargetRegister),
			.out_ALUExtendedImmediateValue(RightReadBus),	//extended 32bit immediate value ,go to right bus
			.out_ALURightShiftType(out_ALURightShiftType),
			.out_ALUSecondImmediateValue(ThirdReadBus),	//serve as the shift count
			.out_SimpleALUType(out_SimpleALUType),		//serve for the pre index mode of load/store
			.out_SimpleALUTargetRegister(out_SimpleALUTargetRegister),
			.out_ALUMisc(out_ALUMisc),			//some special signal
			.out_ALUPSRType(out_ALUPSRType),
			.out_AddressGoWithInstruction2ALU(LeftReadBus),	//pc go on the left read bus
			.out_NextAddressGoWithInstruction2ALU(out_NextAddressGoWithInstruction2ALU),
			//signal for mem stage
			.out_MEMEnable(out_MEMEnable),
			.out_MEMType(out_MEMType),
			.out_MEMTargetRegister(out_MEMTargetRegister),
			.out_SimpleMEMType(out_SimpleMEMType),
			.out_SimpleMEMTargetRegister(out_SimpleMEMTargetRegister),
			.out_MEMPSRType(out_MEMPSRType),
			//can AUL go
			.in_ALUCanGo(out_EXECanGo),
			.clock(clock),
			.reset(reset)
			);


IF  inst_IF(.in_Instruction(Instruction),		//input from instruction prefetched buffer
		.in_InstructionWait(Wait),	//wait for the prefetch buffer 
		.out_InstructionAddress(out_InstructionAddress),	//output to instruction prefetched buffer
		//above is for Instruction fetch
		//use to read pc
		.out_FourthReadRegisterEnable(out_FourthReadRegisterEnable),
		.out_FourthReadRegisterNumber(out_FourthReadRegisterNumber),
		.in_FourthReadBus(FourthReadBus),
		//use to write pc
		.out_SecondWriteRegisterEnable(out_SecondWriteRegisterEnable),
		.out_SecondWriteRegisterNumber(out_SecondWriteRegisterNumber),
		.out_SecondWriteBus(SecondWriteBus),
		//can decoder go
		.in_IDCanGo(out_IDCanGo),
		//fetched instruction
		.out_Instruction(Pipeline_IFID),
		.out_ValidInstruction(Valid_Pipeline_IFID),
		.out_AddressGoWithInstruction(out_AddressGoWithInstruction),
		.out_NextInstructionAddress(out_NextInstructionAddress),
		//signal relate to pc change in branch instruction
		.in_ChangePC(out_ChangePC),
		.in_NewPC(out_NewPC),
		//signal send out by mem that declare to update pc
		.in_MEMChangePC(out_MEMChangePC),
		.in_MEMNewPC(out_MEMNewPC),
		.clock(clock),
		.reset(reset)
		);

InstructionPreFetch inst_InstructionPreFetch(
				.Instruction(Instruction),
				.Wait(Wait),
				.Address(out_InstructionAddress),
				//above is the fetched instruction go to pipeline
				//below is the prefetched instruction come from cache or memory
				.PreFetchedInstructions(InstructionOut),
				.PreFetchedWait(InstructionWait),
				.PreFetchedAddress(PreFetchedAddress),
				.PreFetchedRequest(PreFetchedRequest),
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

endmodule