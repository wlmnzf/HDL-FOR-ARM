//////////////////////////////////////////////////////////////////////////
//			system 						//
//author:ShengYu Shen from National University of Defence Technology	//
//create time: 2001 3 19						//
//////////////////////////////////////////////////////////////////////////

`include "timescalar.v"
`include "MemoryController.v"
`include "nnARM.v"

module System;
wire [4:0] nM;
wire [31:0] AddressBus;
wire [31:0] DataBus;
wire nENOUT,nMREQ,SEQ,nRW,nBW,LOCK,nTRANS,nOPC,nCPI,ABORT,CPA,CPB,nWAIT,PROG32,DATA32,BIGEND,nIRQ,nFIQ,ALE,DBE;

reg nRESET,MCLK;

integer ssycnt;
nnARM Inst_nnARM(nM,	//inverted processor mode 5 bit
	AddressBus,	//address bus 32 bit
	nENOUT,		//enable data output
	nMREQ,		//memory request
	SEQ,		//sequential address
	nRW,		//read or write 
	nBW,		//transfer byte or word
	LOCK,		//locked memory access
	nTRANS,		//memory translate
	nOPC,		//operation code fetch or data fetch
	nCPI,		//coprocessor instruction
	DataBus,	//input data bus
	ABORT,		//abort the memory access
	CPA,		//coprocessor absent
	CPB,		//coprocessor busy
	MCLK,		//main clock
	nWAIT,		//wait for slow peripharels
	PROG32,		//config arm to run at 32 bit program address space
	DATA32,		//config arm to run at 32 bit data address space
	BIGEND,		//config arm to run at bigendian
	nIRQ,		//interrupt request
	nFIQ,		//fast interrupt request
	nRESET,		//reset system
	ALE,		//address latch enable
	DBE		//data bus enable
);

MemoryController Inst_MemoryController (DataBus,	//data bus ,bidirection
			nWAIT,
			AddressBus,	//address bus
			nRW,		//0 is read,1 is write
			nBW,		//0 is read byte,1 is read word
			nMREQ,		//0 is memory request,1 is for other device(coprocessor)
			SEQ,		//1 is sequential access mode
			MCLK,		//main clock
			nRESET
			);



initial
begin
	for(ssycnt=0;ssycnt<`MemorySize;ssycnt=ssycnt+1)
	begin
		Inst_MemoryController.Memory[ssycnt]=`MemoryElementZero;
	end

	Inst_MemoryController.Memory[0]=8'h00;
	Inst_MemoryController.Memory[1]=8'h00;
	Inst_MemoryController.Memory[2]=8'h01;
	Inst_MemoryController.Memory[3]=8'h00;

	Inst_MemoryController.Memory[32'h00010000]=8'h10;
	Inst_MemoryController.Memory[32'h00010001]=8'h00;
	Inst_MemoryController.Memory[32'h00010002]=8'h00;
	Inst_MemoryController.Memory[32'h00010003]=8'hea;

	Inst_MemoryController.Memory[32'h00010010]=8'h10;
	Inst_MemoryController.Memory[32'h00010011]=8'h00;
	Inst_MemoryController.Memory[32'h00010012]=8'h00;
	Inst_MemoryController.Memory[32'h00010013]=8'hea;

	Inst_MemoryController.Memory[32'h00010020]=8'h10;
	Inst_MemoryController.Memory[32'h00010021]=8'h00;
	Inst_MemoryController.Memory[32'h00010022]=8'h00;
	Inst_MemoryController.Memory[32'h00010023]=8'hea;

	MCLK=1'b0;	
	nRESET=1'b0;
	#500 nRESET=1'b1;

	#10000
	$stop;
	$finish;
end


always
begin
	#(`ClockCycle/2) MCLK=~MCLK;
end


endmodule