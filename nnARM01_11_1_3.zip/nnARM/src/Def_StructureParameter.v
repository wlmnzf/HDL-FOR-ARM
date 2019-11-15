//////////////////////////////////////////////////////////////////////////
//			define structure parameter			//
//									//
//	this file define parameter for overal system structure		//
//									//
//author:ShengYu Shen from national university of defense technology	//
//create time: 2001 3 16						//
//////////////////////////////////////////////////////////////////////////

`define WordWidth		32
`define WordZero		32'h0000_0000
`define	WordZ			32'hzzzz_zzzz
`define ByteNumberInWord	4
`define ByteSelectWidthInWord	2
`define	Def_ByteSelectField				1:0



`define ByteWidth		8
`define ByteZero		8'h00
`define	ByteZ			8'hzz

//general register paramter
`define GeneralRegisterNumber	31
`define GeneralRegisterWidth	32
`define GeneralRegisterZero	`WordZero
`define SRLR			R14
`define PC			R15
`define CPSR			R16
`define SPSR			R17
`define SRC_nM			`CPSR[4:0]
`define	T			`CPSR[5]
`define	I			`CPSR[7]
`define	F			`CPSR[6]
`define	N			`CPSR[31]
`define	Z			`CPSR[30]
`define	C			`CPSR[29]
`define	V			`CPSR[28]


//bus parameter
`define AddressBusWidth		`WordWidth
`define AddressBusZero		`WordZero
`define	AddressBusZ		`WordZ

`define DataBusWidth		`WordWidth
`define	DataBusZero		`WordZero
`define	DataBusZ		`WordZ

//instruction parameter
`define InstructionWidth	`WordWidth
`define InstructionWidth_Byte	4
`define	InstructionZero		`WordZero
`define InstructionZ		`WordZ



//pipeline register parameter
`define PipelineRegister_IFID_Width	`InstructionWidth
`define	PipelineRegister_IFID_Zero	32'h0000_0000


//PreviousReset register statue
`define	WaitForContentOf0	2'b01
`define	WaitForFirstInstruction	2'b10




//the decoder definition
`define	InstructionDecoderCondition_IsBranch	(PipelineRegister_IFID[27:24]==4'b1010)
`define	InstructionDecoderCondition_IsBranchWithLink	(PipelineRegister_IFID[27:24]==4'b1011)
`define InstructionDecoder_BranchOffset		{8'b00000000,PipelineRegister_IFID[23:0]}

//the exemem register decoder
`define EXEMEMCondition_IsBranch		(PipelineRegister_EXEMEM[27:24]==4'b1010)
`define	EXEMEMCondition_IsBranchWithLink	(PipelineRegister_EXEMEM[27:24]==4'b1011)

//the MEMWB register decoder
`define MEMWBCondition_IsBranch		(PipelineRegister_MEMWB[27:24]==4'b1010)
`define	MEMWBCondition_IsBranchWithLink	(PipelineRegister_MEMWB[27:24]==4'b1011)

`define	EXEMEM_IsBranch				(PipelineRegister_EXEMEM[27:24]==4'b1010)
`define MEMAccessMemory				(`EXEMEM_IsBranch)


//definition relate to branch instruction
//this relate the prefetch mechanism and when to execute the branch
`define	PCAheadOfCurrentPC	32'hfffffffc

//can the pipeline go forward?
`define	WBOwnCanGo	1'b1
`define	MEMOwnCanGo	(!(`MEMAccessMemory) || (`MEMAccessMemory && WhoAccessMemory[`MEMAccessMemoryPosition]==1'b1 && nWAIT==1'b1 && HaveBeenWait==1'b1) )
`define	EXEOwnCanGo	1'b1
`define	IDOwnCanGo	1'b1
`define	IFOwnCanGo	(WhoAccessMemory[`IFAccessMemoryPosition]==1'b1 && nWAIT==1'b1 && HaveBeenWait==1'b1)
//whether IF can go depend on the following pipeline stage and the memory access


//where to set 1 to indicate varias memory access source
`define	IFAccessMemoryPosition	1
`define	MEMAccessMemoryPosition	2

`define	WordDontCare	`WordZero