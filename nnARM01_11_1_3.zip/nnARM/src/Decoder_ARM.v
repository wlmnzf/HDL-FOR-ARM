module Decoder_ARM(	in_ValidInstruction_IFID,
			in_PipelineRegister_IFID,
			in_AddressGoWithInstruction,
			in_NextInstructionAddress,
			out_IDOwnCanGo,
			//signal for register file
			out_LeftReadRegisterEnable,
			out_LeftReadRegisterNumber,
			out_RightReadRegisterEnable,
			out_RightReadRegisterNumber,
			//use to read the shift count stored in register
			out_ThirdReadRegisterEnable,
			out_ThirdReadRegisterNumber,
			//signal for register file
			//signal for ALU
			out_ALUEnable,
			out_ALUType,
//			out_ALULeftRegister,
//			out_ALURightRegister,
//			out_ALUThirdRegister,
			out_ALULeftFromImm,
			out_ALURightFromImm,
			out_ALUThirdFromImm,
			out_CPSRFromImm,
			out_SPSRFromImm,
			out_ALUTargetRegister,
			out_ALUExtendedImmediateValue,	//extended 32bit immediate value ,go to right bus
			out_ALURightShiftType,
			out_ALUSecondImmediateValue,	//serve as the shift count
			out_SimpleALUType,		//serve for the pre index mode of load/store
			out_SimpleALUTargetRegister,
			out_ALUMisc,			//some special signal
			out_ALUPSRType,
			out_AddressGoWithInstruction2ALU,
			out_NextAddressGoWithInstruction2ALU,
			//signal for mem stage
			out_MEMEnable,
			out_MEMType,
			out_MEMTargetRegister,
			out_SimpleMEMType,
			out_SimpleMEMTargetRegister,
			out_MEMPSRType,
			//Thumb state
			in_ThumbState,
			in_IsInPrivilegedMode,
			//interrupt signal
			in_TrueFiq,
			in_TrueIrq,
			//can AUL go
			in_ALUCanGo,
			//clear internal state
			in_ChangePC,
			in_MEMChangePC,
			clock,
			reset
			);


//////////////////////////////////////////////////
//////////////////////////////////////////////////
//	input and output declaration		//
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//signal come from if register
input 							in_ValidInstruction_IFID;
input 	[`InstructionWidth-1:0]			in_PipelineRegister_IFID;
input	[`AddressBusWidth-1:0]			in_AddressGoWithInstruction,in_NextInstructionAddress;

//can id its own go
output							out_IDOwnCanGo;

//the three read register signal
output							out_LeftReadRegisterEnable,
								out_RightReadRegisterEnable,
								out_ThirdReadRegisterEnable;
output	[`Def_RegisterSelectWidth-1:0]	out_LeftReadRegisterNumber,
								out_RightReadRegisterNumber,
								out_ThirdReadRegisterNumber;
								

//signal go to alu execute stage
output							out_ALUEnable;		//only when there is space for new operation and a known valid instruction can it be 1'b1
output	[`ByteWidth-1:0]				out_ALUType;		//what type of main alu thread 
//the source operand register,the alu will use it to enable forwarding
//output	[`Def_RegisterSelectWidth-1:0]	out_ALULeftRegister,
//								out_ALURightRegister,
//								out_ALUThirdRegister;
//if the source operand come from immediate value,then forwording will be disable
output							out_ALULeftFromImm,
								out_ALURightFromImm,
								out_ALUThirdFromImm,
								out_CPSRFromImm,
								out_SPSRFromImm;
//target register of the main alu result,will be use to enable forwarding and write back
output	[`Def_RegisterSelectWidth-1:0]	out_ALUTargetRegister;
//the immediate value go to right operand of alu
output	[`WordWidth-1:0]				out_ALUExtendedImmediateValue;
//shift type of right operand
output	[`Def_ShiftTypeWidth-1:0]		out_ALURightShiftType;
//the shift count specify in immediate field,will go to the third read bus
output	[`WordWidth-1:0]				out_ALUSecondImmediateValue;

//simple thread operation type ad target register
output	[`ByteWidth-1:0]				out_SimpleALUType;
//will be use to write back and enable forwarding
output	[`Def_RegisterSelectWidth-1:0]	out_SimpleALUTargetRegister;
//some special signal
output	[`WordWidth-1:0]		out_ALUMisc;
output	[`ByteWidth-1:0]		out_ALUPSRType;
output	[`AddressBusWidth-1:0]		out_AddressGoWithInstruction2ALU,out_NextAddressGoWithInstruction2ALU;
reg	[`AddressBusWidth-1:0]		out_AddressGoWithInstruction2ALU,out_NextAddressGoWithInstruction2ALU;


//the operations for main mem and simple mem thread
//the alu stage will hold these information untill this instruction reach mem stage
output							out_MEMEnable;
output	[`ByteWidth-1:0]				out_MEMType;
output	[`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister;

output	[`ByteWidth-1:0]				out_SimpleMEMType;
output	[`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister;
output	[`ByteWidth-1:0]				out_MEMPSRType;


//thumb state
input	in_ThumbState;

input	in_IsInPrivilegedMode;

//interrupt signal
input	in_TrueFiq,in_TrueIrq;

//the decoder need to know if alu can go
//if not, decoder will not send out useful information
input								in_ALUCanGo;

//branch signal
input			in_ChangePC,in_MEMChangePC;

//global signal
input clock,reset;

//reg style declaration of output signal
reg								out_IDOwnCanGo;
reg								out_LeftReadRegisterEnable,
								out_RightReadRegisterEnable,
								out_ThirdReadRegisterEnable;
reg		[`Def_RegisterSelectWidth-1:0]	out_LeftReadRegisterNumber,
								out_RightReadRegisterNumber,
								out_ThirdReadRegisterNumber;
reg								out_ALUEnable;
reg		[`ByteWidth-1:0]				out_ALUType;
reg								out_ALULeftFromImm,
								out_ALURightFromImm,
								out_ALUThirdFromImm,
								out_CPSRFromImm,
								out_SPSRFromImm;
reg		[`Def_RegisterSelectWidth-1:0]	out_ALUTargetRegister;
reg		[`WordWidth-1:0]				out_ALUExtendedImmediateValue;
reg		[`Def_ShiftTypeWidth-1:0]		out_ALURightShiftType;
reg		[`WordWidth-1:0]				out_ALUSecondImmediateValue;

reg		[`ByteWidth-1:0]				out_SimpleALUType;
reg		[`Def_RegisterSelectWidth-1:0]	out_SimpleALUTargetRegister;
reg		[`WordWidth-1:0]				out_ALUMisc;
reg		[`ByteWidth-1:0]		out_ALUPSRType;

reg								out_MEMEnable;
reg		[`ByteWidth-1:0]				out_MEMType;
reg		[`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister;

reg		[`ByteWidth-1:0]				out_SimpleMEMType;
reg		[`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister;
reg		[`ByteWidth-1:0]				out_MEMPSRType;



//these register will not be infer

//if current register number will be access in LDM or STM
reg	[`Def_RegisterSelectWidth-1:0]	RegCountInLDMSTM;
reg	IfCurrentRegAccessByLDMSTM;
reg	IsFirstAccess;

//map ARM alu type to independante alu type
reg [`ByteWidth-1:0] ALUTypeMapped;

//in fact this three wire is exclusive to each other
//there will not use at the same time
//so some type of share method must be found to share the same adder
wire	[`WordWidth-1:0]		PCAdder4Result;
wire	[`WordWidth-1:0]		PCAdder8or4Result;
wire	[`WordWidth-1:0]		PCAdder12or4Result;

//pipeline register
//previous operation will write register from MEM
reg	PrevOperationWantWriteRegisterFromMEM;
reg	Next_PrevOperationWantWriteRegisterFromMEM;
reg	[`Def_RegisterSelectWidth-1:0]	PrevWriteRegister;
reg	[`Def_RegisterSelectWidth-1:0]	Next_PrevWriteRegister;

//use in block transfer for register number
reg	[`Def_RegisterSelectWidth-1:0]	IncRegNumber,DecRegNumber;
reg	[`Def_RegisterSelectWidth-1:0]	Next_IncRegNumber,Next_DecRegNumber;

wire	[`Def_RegisterSelectWidth-1:0]	IncRegNumberAdd1,DecRegNumberSub1;

wire	[`WordWidth-1:0]	Inc8or4,Inc12or4;

//use to decode MLAL
reg	MLAL1;
reg	Next_MLAL1;

reg	NowIn_Fiq,NowIn_Irq,NowIn_ALU,NowIn_MRS,NowIn_MSRReg,NowIn_MSRCondition,NowIn_Mul,NowIn_Mull_Mlal,NowIn_SWP,NowIn_BX,NowIn_HalfTransfer,NowIn_LDR,NowIn_STR,NowIn_Undef,NowIn_LDM,NowIn_STM,NowIn_Branch,NowIn_CDT,NowIn_CDO,NowIn_CRT,NowIn_SWI;

reg	ExistState;

//help decode signal
wire	I24_23_10;	//in_PipelineRegister_IFID[24:23]==2'b10
wire	I7_4_11;	//{in_PipelineRegister_IFID[7],in_PipelineRegister_IFID[4]}==2'b11
wire	I7_4_00;	//{in_PipelineRegister_IFID[7],in_PipelineRegister_IFID[4]}==2'b00
wire	I21_20_00;	//in_PipelineRegister_IFID[21:20]==2'b00
wire	I21_20_10;	//in_PipelineRegister_IFID[21:20]==2'b10
wire	I17_16_01;	//in_PipelineRegister_IFID[17:16]=2'b01
wire	I25_24_23_22_0000;	//in_PipelineRegister_IFID[25:22]==4'b0000
wire	I6_5_00;	//in_PipelineRegister_IFID[6:5]==2'b00
wire	I25_24_23_001;	//in_PipelineRegister_IFID[25:23]==3'b001
wire	I25_24_01;	//in_PipelineRegister_IFID[25:24]==2'b01

assign	I24_23_10=in_PipelineRegister_IFID[24] & ~in_PipelineRegister_IFID[23];
assign	I7_4_11=in_PipelineRegister_IFID[7] & in_PipelineRegister_IFID[4];
assign	I7_4_00=~(in_PipelineRegister_IFID[7] | in_PipelineRegister_IFID[4]);
assign	I21_20_00=~(in_PipelineRegister_IFID[21] | in_PipelineRegister_IFID[20]);
assign	I21_20_10=in_PipelineRegister_IFID[21] & ~in_PipelineRegister_IFID[20];
assign	I17_16_01=~in_PipelineRegister_IFID[17] & in_PipelineRegister_IFID[16];
assign	I25_24_23_22_0000=~(in_PipelineRegister_IFID[25] | in_PipelineRegister_IFID[24] | in_PipelineRegister_IFID[23] | in_PipelineRegister_IFID[22]);
assign	I6_5_00=~(in_PipelineRegister_IFID[6] | in_PipelineRegister_IFID[5]);
assign	I25_24_23_001=~in_PipelineRegister_IFID[25] & ~in_PipelineRegister_IFID[24] & in_PipelineRegister_IFID[23];
assign	I25_24_01=~in_PipelineRegister_IFID[25] & in_PipelineRegister_IFID[24];


always	@(in_PipelineRegister_IFID	or
	DecRegNumber			or
	IncRegNumber
	)
begin
	if(in_PipelineRegister_IFID[23]==1'b0)
	begin//down
		RegCountInLDMSTM=DecRegNumber;
		if(DecRegNumber==`Def_RegisterSelectAllOne)
			IsFirstAccess=1'b1;
		else
			IsFirstAccess=1'b0;
	end
	else
	begin//up
		RegCountInLDMSTM=IncRegNumber;
		if(IncRegNumber==`Def_RegisterSelectZero)
			IsFirstAccess=1'b1;
		else
			IsFirstAccess=1'b0;
	end
end

always	@(RegCountInLDMSTM	or
	in_PipelineRegister_IFID
	)
begin
	IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[0];
	case (RegCountInLDMSTM[3:0])
	4'b0000:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[0];
	4'b0001:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[1];
	4'b0010:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[2];
	4'b0011:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[3];
	4'b0100:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[4];
	4'b0101:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[5];
	4'b0110:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[6];
	4'b0111:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[7];
	4'b1000:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[8];
	4'b1001:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[9];
	4'b1010:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[10];
	4'b1011:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[11];
	4'b1100:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[12];
	4'b1101:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[13];
	4'b1110:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[14];
	4'b1111:
		IfCurrentRegAccessByLDMSTM=in_PipelineRegister_IFID[15];
	endcase
end



always	@(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		PrevOperationWantWriteRegisterFromMEM=1'b0;
		PrevWriteRegister=`Def_RegisterSelectZero;
		IncRegNumber=`Def_RegisterSelectZero;
		DecRegNumber=`Def_RegisterSelectAllOne;
		MLAL1=1'b0;
	end
	else
	begin
		PrevOperationWantWriteRegisterFromMEM=Next_PrevOperationWantWriteRegisterFromMEM;
		PrevWriteRegister=Next_PrevWriteRegister;
		IncRegNumber=Next_IncRegNumber;
		DecRegNumber=Next_DecRegNumber;
		MLAL1=Next_MLAL1;
	end
end

assign	IncRegNumberAdd1=IncRegNumber+1;
assign	DecRegNumberSub1=DecRegNumber-1;

//exclusive to each other, must found a method to share this adder
assign	PCAdder4Result=in_AddressGoWithInstruction+32'h0000_0004;
assign	Inc8or4=(in_ThumbState==1'b1)?32'h0000_0004:32'h0000_0008;
//STM in thumb state do not store pc, so use PCAdder12or4Result for stm pc will be ok
assign	Inc12or4=(in_ThumbState==1'b1)?32'h0000_0004:32'h0000_000C;

assign	PCAdder8or4Result=in_AddressGoWithInstruction+Inc8or4;
assign	PCAdder12or4Result=in_AddressGoWithInstruction+Inc12or4;

//output 
always @(in_ValidInstruction_IFID	or
	in_PipelineRegister_IFID	or
	in_ALUCanGo			or
	in_ThumbState			or
	in_TrueFiq			or
	in_TrueIrq			or
	in_NextInstructionAddress	or
	ALUTypeMapped			or
	in_AddressGoWithInstruction	or
	PCAdder4Result	or
	PCAdder8or4Result	or
	PCAdder12or4Result	or
	PrevOperationWantWriteRegisterFromMEM	or
	PrevWriteRegister	or
	IncRegNumber		or
	IncRegNumberAdd1	or
	DecRegNumber		or
	DecRegNumberSub1	or
	MLAL1			or
	IfCurrentRegAccessByLDMSTM	or
	ExistState
)
begin
	//to prevent latch to be infer
	//invalid instruction
	out_LeftReadRegisterEnable=1'b0;
	out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
	out_ALULeftFromImm=1'b1;

	out_RightReadRegisterEnable=1'b0;
	out_RightReadRegisterNumber=`Def_RegisterSelectZero;
	out_ALURightFromImm=1'b1;
		
	//third read bus will not be use
	out_ThirdReadRegisterEnable=1'b0;
	out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
	out_ALUThirdFromImm=1'b1;

	out_ALUEnable=1'b0;
	out_ALUType=`ALUType_Null;
	out_ALUTargetRegister=`Def_LinkRegister;

	//no use here
	out_ALURightShiftType=2'b00;
		
	out_ALUExtendedImmediateValue=`WordDontCare;
	out_ALUSecondImmediateValue=`WordDontCare;
	out_IDOwnCanGo=1'b1;

	//mem not enable
	out_MEMEnable=1'b0;
	out_MEMType=`MEMType_Null;
	out_MEMTargetRegister=`Def_LinkRegister;

	//simple alu will not be use
	out_SimpleALUType=`ALUType_Null;
	out_SimpleALUTargetRegister=`Def_LinkRegister;
	out_ALUMisc=`WordZero;
	//send out the condition code
	out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];

	//simple MEM thread
	out_SimpleMEMType=`MEMType_Null;
	out_SimpleMEMTargetRegister=`Def_LinkRegister;

	//condition code valid in alu and mem stage
	out_ALUPSRType=`ALUPSRType_Null;
	out_MEMPSRType=`MEMPSRType_Null;

	//default is come from register
	out_CPSRFromImm=1'b0;
	out_SPSRFromImm=1'b0;
	
	//only a branch or alu/load/store use pc as base will send address on this port 
	//out to LeftReadBus
	out_AddressGoWithInstruction2ALU=`WordDontCare;
	out_NextAddressGoWithInstruction2ALU=`WordZero;
	
	Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
	Next_PrevWriteRegister=`Def_RegisterSelectZero;
	
	Next_IncRegNumber=`Def_RegisterSelectZero;
	Next_DecRegNumber=`Def_RegisterSelectAllOne;
	
	Next_MLAL1=MLAL1;
	
	{NowIn_Fiq,NowIn_Irq,NowIn_ALU,NowIn_MRS,NowIn_MSRReg,NowIn_MSRCondition,NowIn_Mul,NowIn_Mull_Mlal,NowIn_SWP,NowIn_BX,NowIn_HalfTransfer,NowIn_LDR,NowIn_STR,NowIn_Undef,NowIn_LDM,NowIn_STM,NowIn_Branch,NowIn_CDT,NowIn_CDO,NowIn_CRT,NowIn_SWI}=21'b0000_0000_0000_0000_0000_0;
	
	
	//end of latch infer prevent
	
	if(in_TrueFiq==1'b1 && ExistState==1'b0)
	begin
		//fast interrupt
			out_LeftReadRegisterEnable=1'b0;
			out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALULeftFromImm=1'b0;

			//right read bus will be use to pass target address
			out_RightReadRegisterEnable=1'b0;
			out_RightReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALURightFromImm=1'b1;
			out_ALUExtendedImmediateValue=`Def_FIQ_Service;
		
			out_ThirdReadRegisterEnable=1'b0;
			out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALUThirdFromImm=1'b0;

			//alu main thread will be use to branch
			out_ALUEnable=1'b1;
			out_ALUType=`ALUType_Mov;
			out_ALUTargetRegister=`Def_LinkRegister;

			//do not shift, just use right operand as branch target address
			out_ALURightShiftType=2'b00;
			out_ALUSecondImmediateValue=`WordDontCare;
			
			out_IDOwnCanGo=1'b1;

			//mem not enable
			out_MEMEnable=1'b0;
			out_MEMType=`MEMType_BlankOp;
			out_MEMTargetRegister=`Def_LinkRegister;

			//simple will be use to write pc+4 to r14_svc
			out_SimpleALUType=`ALUType_MvNextInstructionAddress;
			out_SimpleALUTargetRegister=`Def_SBLRegister;
			out_NextAddressGoWithInstruction2ALU=PCAdder4Result;
			
			//branch to service
			out_ALUMisc=`WordZero;
			//send out the condition code
			out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
			//a branch
			out_ALUMisc[6]=1'b1;
			//exception
			out_ALUMisc[8]=1'b1;
			out_ALUMisc[13:9]=`MODE_FIQ;

			//simple MEM thread will be use to write pc+4 to r14_svc
			out_SimpleMEMType=`MEMType_MovSimple;
			out_SimpleMEMTargetRegister=`Def_SBLRegister;

			//condition code valid in alu and mem stage
			out_ALUPSRType=`ALUPSRType_CPSR2SPSR;
			out_MEMPSRType=`MEMPSRType_WriteBoth;

			//default is come from register
			out_CPSRFromImm=1'b0;
			out_SPSRFromImm=1'b0;
	
			//only a branch or alu/load/store use pc as base will send address on this port 
			//out to LeftReadBus
			//not use here
			out_AddressGoWithInstruction2ALU=`WordDontCare;
	
			NowIn_Fiq=1'b1;
			
			Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
			Next_PrevWriteRegister=`Def_RegisterSelectZero;
	end
	else if(in_TrueIrq==1'b1 && ExistState==1'b0)
	begin
		//normal interrupt
		//almost same as FIQ
			out_LeftReadRegisterEnable=1'b0;
			out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALULeftFromImm=1'b0;

			//right read bus will be use to pass target address
			out_RightReadRegisterEnable=1'b0;
			out_RightReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALURightFromImm=1'b1;
			out_ALUExtendedImmediateValue=`Def_IRQ_Service;	//first not same as fiq
		
			out_ThirdReadRegisterEnable=1'b0;
			out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALUThirdFromImm=1'b0;

			//alu main thread will be use to branch
			out_ALUEnable=1'b1;
			out_ALUType=`ALUType_Mov;
			out_ALUTargetRegister=`Def_LinkRegister;

			//do not shift, just use right operand as branch target address
			out_ALURightShiftType=2'b00;
			out_ALUSecondImmediateValue=`WordDontCare;
			
			out_IDOwnCanGo=1'b1;

			//mem not enable
			out_MEMEnable=1'b0;
			out_MEMType=`MEMType_BlankOp;
			out_MEMTargetRegister=`Def_LinkRegister;

			//simple will be use to write pc+4 to r14_svc
			out_SimpleALUType=`ALUType_MvNextInstructionAddress;
			out_SimpleALUTargetRegister=`Def_SBLRegister;
			out_NextAddressGoWithInstruction2ALU=PCAdder4Result;
			
			//branch to service
			out_ALUMisc=`WordZero;
			//send out the condition code
			out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
			//a branch
			out_ALUMisc[6]=1'b1;
			//exception
			out_ALUMisc[8]=1'b1;
			out_ALUMisc[13:9]=`MODE_IRQ;

			//simple MEM thread will be use to write pc+4 to r14_svc
			out_SimpleMEMType=`MEMType_MovSimple;
			out_SimpleMEMTargetRegister=`Def_SBLRegister;

			//condition code valid in alu and mem stage
			out_ALUPSRType=`ALUPSRType_CPSR2SPSR;
			out_MEMPSRType=`MEMPSRType_WriteBoth;

			//default is come from register
			out_CPSRFromImm=1'b0;
			out_SPSRFromImm=1'b0;
	
			//only a branch or alu/load/store use pc as base will send address on this port 
			//out to LeftReadBus
			//not use here
			out_AddressGoWithInstruction2ALU=`WordDontCare;
	
			NowIn_Irq=1'b1;
	
			Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
			Next_PrevWriteRegister=`Def_RegisterSelectZero;
	end
	else if(in_ValidInstruction_IFID==1'b1)
	begin
	   if(in_ALUCanGo==1'b1)
	   begin
	   	//ALU can go
		//valid instruction
		case(in_PipelineRegister_IFID[27:26])
		2'b00:
			begin
				if((in_PipelineRegister_IFID[25] & (~I24_23_10 | in_PipelineRegister_IFID[20]) ) | (~in_PipelineRegister_IFID[25] & ((~I24_23_10 & ~I7_4_11 ) | (I24_23_10 & (in_PipelineRegister_IFID[20] & ~I7_4_11 )) ) )==1'b1)
				begin
					//DATA processing(ALU)
					NowIn_ALU=1'b1;
					//ALU operation
					if(in_PipelineRegister_IFID[25]==1'b0)
					begin
						// op two register together
						//19:16 is the first operand
						//3:0 is the second source operand
						//$monitor($time,"go to two reg ALU");
						//deal with left operand

						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							if(in_PipelineRegister_IFID[4]==1'b1)
								out_AddressGoWithInstruction2ALU=PCAdder12or4Result;
							else
								out_AddressGoWithInstruction2ALU=PCAdder8or4Result;

							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end
				
						//right source register can be direct read
						out_RightReadRegisterEnable=1'b1;
						out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
						//right operand are not from immediate
						out_ALURightFromImm=1'b0;

						//you have deal with the unshifted right operand
						//but you must deal with shift type and shift count
						out_ALURightShiftType=in_PipelineRegister_IFID[6:5];
						//shift count
						if(in_PipelineRegister_IFID[4]==1'b0)
						begin
							//shift count given in instruction
							//no need to read shift count from register file
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
							//ALU must open to read in shift count
							//shift count is a immediate
							out_ALUThirdFromImm=1'b1;
							out_ALUSecondImmediateValue={27'b0000_0000_0000_0000_0000_0000_000,in_PipelineRegister_IFID[11:7]};
						end
						else
						begin
							//the shift count given in a register
							out_ALUSecondImmediateValue=`WordDontCare;
					
							//this register can be direct read
							out_ThirdReadRegisterEnable=1'b1;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[11:8];
							//shift count is not imm
							out_ALUThirdFromImm=1'b0;
						end
				
				
						out_ALUExtendedImmediateValue=`WordDontCare;
						//a valid ALU
						out_ALUEnable=1'b1;
						out_ALUType=ALUTypeMapped;
						//these instruction will not write result,just set status psr
						if(`Def_IsNoResultWritenInstruction)
						begin
							out_ALUTargetRegister=`Def_LinkRegister;
							out_MEMEnable=1'b0;
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;
						end
						else if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)//pc will not be forward or write to register file by mem stage
						begin
							out_ALUTargetRegister=`Def_LinkRegister;
							out_MEMEnable=1'b0;
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;
						end
						else
						begin
							out_ALUTargetRegister=in_PipelineRegister_IFID[15:12];
							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_MovMain;
							out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];
						end
						out_IDOwnCanGo=1'b1;

						//simple thread will not be use in write to R15 or other register
						out_SimpleALUType=`ALUType_Null;
						//simple lu thread will not attend forwarding
						out_SimpleALUTargetRegister=`Def_LinkRegister;

						//simple MEM thread will not be use in write to r15 or other register
						out_SimpleMEMType=`MEMType_Null;
						//simple mem thread will not attend forwarding
						out_SimpleMEMTargetRegister=`Def_LinkRegister;
				
						out_ALUMisc=`WordZero;
						out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
						//main thread result must be used to change pc
						//output new pc to IF using main alu
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
							out_ALUMisc[6]=1'b1;
						else
							out_ALUMisc[6]=1'b0;

				
						//default is come from register
						out_CPSRFromImm=1'b0;
						out_SPSRFromImm=1'b0;

					end//the second operand come from register
					else
					begin
						//the second operand is a immediate value

						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							out_AddressGoWithInstruction2ALU=PCAdder8or4Result;

							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end
					

						//right read bus here will not be use
						out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
						//right register will not be use
						out_RightReadRegisterEnable=1'b0;
						//ALU must read extended immediate value from RightReadBus
						//the value come from the decoder
						out_ALURightFromImm=1'b1;
						//send out imediate value
						out_ALUExtendedImmediateValue={24'h000000,in_PipelineRegister_IFID[7:0]};
				
						//third read bus will be use
						out_ThirdReadRegisterEnable=1'b0;
						out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[11:8];
						out_ALUThirdFromImm=1'b1;
				
						//shift type and count
						//rotate at twice the value of rotate field
						out_ALURightShiftType=`Def_ShiftType_RotateRight;
						out_ALUSecondImmediateValue={24'h000000,3'b000,in_PipelineRegister_IFID[11:8],1'b0};
				
				
						//a valid ALU
						out_ALUEnable=1'b1;
						out_ALUType=ALUTypeMapped;
						//these instruction will not write result,just set status psr
						if(`Def_IsNoResultWritenInstruction)
						begin
							out_ALUTargetRegister=`Def_LinkRegister;
							out_MEMEnable=1'b0;
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;
						end
						else if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)//pc will not be forward or write to register file by mem stage
						begin
							out_ALUTargetRegister=`Def_LinkRegister;
							out_MEMEnable=1'b0;
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;
						end
						else
						begin
							out_ALUTargetRegister=in_PipelineRegister_IFID[15:12];
							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_MovMain;
							out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];
						end
						out_IDOwnCanGo=1'b1;

						//simple thread will not be use in write to R15 or other register
						out_SimpleALUType=`ALUType_Null;
						out_SimpleALUTargetRegister=`Def_LinkRegister;

						//simple MEM thread will not be use in write to r15 or other register
						out_SimpleMEMType=`MEMType_Null;
						out_SimpleMEMTargetRegister=`Def_LinkRegister;

						out_ALUMisc=`WordZero;
						out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
						//main thread result must be used to change pc
						//output new pc to IF using main alu
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
							out_ALUMisc[6]=1'b1;
						else
							out_ALUMisc[6]=1'b0;
				
				
						//default is come from register
						out_CPSRFromImm=1'b0;
						out_SPSRFromImm=1'b0;
					end//the second operand come from imm
			
					//now deal with the status bit of psr 
					if(in_PipelineRegister_IFID[20]==1'b1)
					begin
						//set condition code in psr
						if(in_PipelineRegister_IFID[15:12]!=`Def_PCNumber)
						begin
							//just set condition code
							out_ALUPSRType=`ALUPSRType_WriteConditionCode;
							out_MEMPSRType=`MEMPSRType_WriteConditionCode;
						end
						else
						begin
							//restore spsr to cpsr
							out_ALUPSRType=`ALUPSRType_SPSR2CPSR;
							out_MEMPSRType=`MEMPSRType_WriteCPSR;
						end
					end
					else
					begin
						out_ALUPSRType=`ALUPSRType_Null;
						out_MEMPSRType=`MEMPSRType_Null;
					end
				end//ALU
				else if((~in_PipelineRegister_IFID[25] & I24_23_10 & I21_20_00 & I7_4_00)==1'b1)
				begin
					//MRS
					NowIn_MRS=1'b1;
					out_ALUEnable=1'b1;
					if(in_PipelineRegister_IFID[22]==1'b1)
						out_SimpleALUType=`ALUType_MvSPSR;
					else
						out_SimpleALUType=`ALUType_MvCPSR;
				
					out_SimpleALUTargetRegister=in_PipelineRegister_IFID[15:12];
			
					out_MEMEnable=1'b1;
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;
					out_SimpleMEMType=`MEMType_MovSimple;
					out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[15:12];
				end
				else if((~in_PipelineRegister_IFID[25] & I24_23_10 & I21_20_10 & I17_16_01)==1'b1)
				begin
					//MSRReg
					NowIn_MSRReg=1'b1;
					
					out_ALUEnable=1'b1;
	
					//read right register
					out_RightReadRegisterEnable=1'b1;
					out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
					out_ALURightFromImm=1'b0;
			
					//do not shift right register
					out_ALURightShiftType=2'b00;
					out_ALUSecondImmediateValue=`WordDontCare;

					out_MEMEnable=1'b1;
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;
			
					if(in_PipelineRegister_IFID[22]==1'b1)
					begin
						//write right operand to spsr
						out_ALUPSRType=`ALUPSRType_Right2SPSR;
						out_MEMPSRType=`MEMPSRType_WriteSPSR;
					end
					else
					begin
						//write right to cpsr
						out_ALUPSRType=`ALUPSRType_Right2CPSR;
						out_MEMPSRType=`MEMPSRType_WriteCPSR;
					end
				end//MSRReg
				else if((I24_23_10 & ~in_PipelineRegister_IFID[20] & (in_PipelineRegister_IFID[25] | (in_PipelineRegister_IFID[21] & ~in_PipelineRegister_IFID[16])))==1'b1)
				begin
					//MSRCondition
					NowIn_MSRCondition=1'b1;
					
					out_ALUEnable=1'b1;
					// i want to add alu result to imm to form new psr
					out_ALUType=`ALUType_Mov;

					if(in_PipelineRegister_IFID[22]==1'b0)
					begin
						out_ALUPSRType=`ALUPSRType_ALUResultAsConditionCode2CPSR;
						out_MEMPSRType=`MEMPSRType_WriteCPSR;
					end
					else
					begin
						out_ALUPSRType=`ALUPSRType_ALUResultAsConditionCode2SPSR;
						out_MEMPSRType=`MEMPSRType_WriteSPSR;
					end
			
					//deal with right operand
					if(in_PipelineRegister_IFID[25]==1'b0)
					begin
						//right operand come from register
						out_RightReadRegisterEnable=1'b1;
						out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
						out_ALURightFromImm=1'b0;
				
						//shift type and count
						out_ALURightShiftType=2'b00;
						out_ALUThirdFromImm=1'b1;
						out_ALUSecondImmediateValue=`WordZero;
					end
					else
					begin
						//right operand come from imm
						out_RightReadRegisterEnable=1'b0;
						out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
						out_ALURightFromImm=1'b1;
						out_ALUExtendedImmediateValue={24'h000000,in_PipelineRegister_IFID[7:0]};
				
						//shift type and count
						out_ALURightShiftType=`Def_ShiftType_RotateRight;
						out_ALUThirdFromImm=1'b1;
						out_ALUSecondImmediateValue={27'b0000_0000_0000_0000_0000_0000_000,in_PipelineRegister_IFID[11:8],1'b0};
					end

					out_MEMEnable=1'b1;
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;
				end//MSRCondition
				else if((I25_24_23_22_0000 & I6_5_00)==1'b1)
				begin
					//mul
					NowIn_Mul=1'b1;
					
					out_LeftReadRegisterEnable=1'b1;
					out_LeftReadRegisterNumber=in_PipelineRegister_IFID[3:0];
					out_ALULeftFromImm=1'b0;
			
					out_RightReadRegisterEnable=1'b1;
					out_RightReadRegisterNumber=in_PipelineRegister_IFID[11:8];
					out_ALURightFromImm=1'b0;
			
					out_ThirdReadRegisterEnable=1'b1;
					out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
					out_ALUThirdFromImm=1'b0;
			
					out_ALUEnable=1'b1;
					if(in_PipelineRegister_IFID[21]==1'b0)
					begin
						//multiple only
						out_ALUType=`ALUType_Mul;
					end
					else
					begin
						//mul and add
						out_ALUType=`ALUType_Mla;
					end
			
					out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

					//no use here
					out_ALURightShiftType=2'b00;

					out_ALUExtendedImmediateValue=`WordDontCare;
					out_ALUSecondImmediateValue=`WordDontCare;
					out_IDOwnCanGo=1'b1;

					out_MEMEnable=1'b1;
					out_MEMType=`MEMType_MovMain;
					out_MEMTargetRegister=in_PipelineRegister_IFID[19:16];
			
					//simple thread will not be use
			
					//psr thread
					if(in_PipelineRegister_IFID[20]==1'b0)
					begin
						//do not set condition code
						out_ALUPSRType=`ALUPSRType_Null;
						out_MEMPSRType=`MEMPSRType_Null;
					end
					else
					begin
						//set condition code
						out_ALUPSRType=`ALUPSRType_WriteConditionCode;
						out_MEMPSRType=`MEMPSRType_WriteConditionCode;
					end
				end//mul and mla
				else if((I25_24_23_001 & I6_5_00)==1'b1)
				begin
					NowIn_Mull_Mlal=1'b1;
					//mull or mlal
					if(in_PipelineRegister_IFID[21]==1'b0)
					begin//mull only
						out_LeftReadRegisterEnable=1'b1;
						out_LeftReadRegisterNumber=in_PipelineRegister_IFID[11:8];
						out_ALULeftFromImm=1'b0;
			
						out_RightReadRegisterEnable=1'b1;
						out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
						out_ALURightFromImm=1'b0;

						//no use
						out_ThirdReadRegisterEnable=1'b0;
						out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
						out_ALUThirdFromImm=1'b1;
			
						out_ALUEnable=1'b1;
						//multiple only
						out_ALUType=`ALUType_MULL;
						out_ALUTargetRegister=in_PipelineRegister_IFID[15:12];

						out_SimpleALUType=`ALUType_MovMULLHigh;
						out_SimpleALUTargetRegister=in_PipelineRegister_IFID[19:16];

						//no use here
						out_ALURightShiftType=2'b00;

						out_ALUExtendedImmediateValue=`WordDontCare;
						out_ALUSecondImmediateValue=`WordDontCare;
						out_IDOwnCanGo=1'b1;

						out_MEMEnable=1'b1;
						out_MEMType=`MEMType_MovMain;
						out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];

						out_SimpleMEMType=`MEMType_MovSimple;
						out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];


						//signed or unsigned
						out_ALUMisc[17]=in_PipelineRegister_IFID[22];
			
						//psr thread
						if(in_PipelineRegister_IFID[20]==1'b0)
						begin
							//do not set condition code
							out_ALUPSRType=`ALUPSRType_Null;
							out_MEMPSRType=`MEMPSRType_Null;
						end
						else
						begin
							//set condition code
							out_ALUPSRType=`ALUPSRType_WriteConditionCode;
							out_MEMPSRType=`MEMPSRType_WriteConditionCode;
						end
					end//mull
					else
					begin
						//mlal
						if(MLAL1==1'b0)
						begin//send out a MULL 
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[11:8];
							out_ALULeftFromImm=1'b0;
			
							out_RightReadRegisterEnable=1'b1;
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_ALURightFromImm=1'b0;

							//no use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;
			
							out_ALUEnable=1'b1;
							//multiple only
							out_ALUType=`ALUType_MLALMul;
							out_ALUTargetRegister=`Def_LinkRegister;

							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							//no use here
							out_ALURightShiftType=2'b00;

							out_ALUExtendedImmediateValue=`WordDontCare;
							out_ALUSecondImmediateValue=`WordDontCare;
							out_IDOwnCanGo=1'b0;

							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;

							out_SimpleMEMType=`MEMType_Null;
							out_SimpleMEMTargetRegister=`Def_LinkRegister;


							//signed or unsigned
							out_ALUMisc[17]=in_PipelineRegister_IFID[22];
				
							//psr thread
							//do not set condition code
							out_ALUPSRType=`ALUPSRType_Null;
							out_MEMPSRType=`MEMPSRType_Null;
							
							Next_MLAL1=1'b1;
						end
						else
						begin//send out a add64
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALULeftFromImm=1'b0;
			
							out_RightReadRegisterEnable=1'b1;
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							out_ALURightFromImm=1'b0;

							//no use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;
			
							out_ALUEnable=1'b1;
							//multiple only
							out_ALUType=`ALUType_MLALAdd;
							out_ALUTargetRegister=in_PipelineRegister_IFID[15:12];

							out_SimpleALUType=`ALUType_MovMULLHigh;
							out_SimpleALUTargetRegister=in_PipelineRegister_IFID[19:16];

							//no use here
							out_ALURightShiftType=2'b00;

							out_ALUExtendedImmediateValue=`WordDontCare;
							out_ALUSecondImmediateValue=`WordDontCare;
							out_IDOwnCanGo=1'b1;

							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_MovMain;
							out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];

							out_SimpleMEMType=`MEMType_MovSimple;
							out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];


							//signed or unsigned
							out_ALUMisc[17]=in_PipelineRegister_IFID[22];
				
							//psr thread
							if(in_PipelineRegister_IFID[20]==1'b0)
							begin
								//do not set condition code
								out_ALUPSRType=`ALUPSRType_Null;
								out_MEMPSRType=`MEMPSRType_Null;
							end
							else
							begin
								//set condition code
								out_ALUPSRType=`ALUPSRType_WriteConditionCode;
								out_MEMPSRType=`MEMPSRType_WriteConditionCode;
							end
							
							Next_MLAL1=1'b0;
						end
					end//mlal
				end
				else if((I25_24_01 & ~in_PipelineRegister_IFID[21] & I6_5_00)==1'b1)
				begin
					//SWP
					NowIn_SWP=1'b1;
					out_LeftReadRegisterEnable=1'b1;
					out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
					out_ALULeftFromImm=1'b0;
	
					out_RightReadRegisterEnable=1'b0;
					out_RightReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALURightFromImm=1'b1;
		
					//third read bus will be use to read the stored value
					out_ThirdReadRegisterEnable=1'b1;
					out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[3:0];
					out_ALUThirdFromImm=1'b0;

					out_ALUEnable=1'b1;
					out_ALUType=`ALUType_SWP;
					out_ALUTargetRegister=`Def_LinkRegister;

					//no use here
					out_ALURightShiftType=2'b00;
		
					out_ALUExtendedImmediateValue=`WordDontCare;
					out_ALUSecondImmediateValue=`WordDontCare;
					out_IDOwnCanGo=1'b1;

					//mem not enable
					out_MEMEnable=1'b1;
					out_MEMType=`MEMType_SWP;
					out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];

					out_SimpleALUType=`ALUType_Mvl;
					out_SimpleALUTargetRegister=`Def_LinkRegister;
					out_ALUMisc=`WordZero;
					//send out the condition code
					out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
					//send out 2'b00 to indicate a swp
					out_ALUMisc[19:18]=in_PipelineRegister_IFID[6:5];

					//simple MEM thread
					out_SimpleMEMType=`MEMType_Null;
					out_SimpleMEMTargetRegister=`Def_LinkRegister;

					//condition code valid in alu and mem stage
					out_ALUPSRType=`ALUPSRType_Null;
					out_MEMPSRType=`MEMPSRType_Null;

					//default is come from register
					out_CPSRFromImm=1'b0;
					out_SPSRFromImm=1'b0;
	
					//only a branch or alu/load/store use pc as base will send address on this port 
					//out to LeftReadBus
					out_AddressGoWithInstruction2ALU=`WordDontCare;
					out_NextAddressGoWithInstruction2ALU=`WordZero;
	
					Next_PrevOperationWantWriteRegisterFromMEM=1'b1;
					Next_PrevWriteRegister=in_PipelineRegister_IFID[15:12];
	
					Next_IncRegNumber=`Def_RegisterSelectZero;
					Next_DecRegNumber=`Def_RegisterSelectAllOne;
	
					Next_MLAL1=MLAL1;
					
					//swp byte or word
					out_ALUMisc[20]=in_PipelineRegister_IFID[22];
				end
				else if((I25_24_01 & ~in_PipelineRegister_IFID[22] & in_PipelineRegister_IFID[8])==1'b1)
				begin
					//BX
					NowIn_BX=1'b1;
					//deal with left operand
					out_LeftReadRegisterEnable=1'b0;
					out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALULeftFromImm=1'b1;
			
					//right operand use reg
					out_RightReadRegisterEnable=1'b1;
					out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
					out_ALURightFromImm=1'b0;
			
					//shift count act as third operand
					out_ThirdReadRegisterEnable=1'b0;
					out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALUThirdFromImm=1'b1;
			
					out_ALUEnable=1'b1;
					out_ALUType=`ALUType_Mov;
					out_ALUTargetRegister=`Def_LinkRegister;
			
					out_ALURightShiftType=2'b00;
					//right operand
					out_ALUExtendedImmediateValue=`WordDontCare;
					//shift count
					out_ALUSecondImmediateValue=`WordDontCare;
					out_IDOwnCanGo=1'b1;
			
					out_MEMEnable=1'b1;
					//main mem stage wil not be use
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;
					out_ALUMisc=`WordZero;
					out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
					//main thread result must be used to change pc
					//output new pc to IF using main alu
					out_ALUMisc[6]=1'b1;
			
					//exchange between thumb and ARM state
					out_ALUPSRType=`ALUPSRType_ModifyThumbState;
					out_MEMPSRType=`MEMPSRType_WriteCPSR;

					//default is come from register
					out_CPSRFromImm=1'b0;
					out_SPSRFromImm=1'b0;

					//only when there is a branch or a alu using pc
					//can i out address of this instrcution to out_AddressGoWithInstruction2ALU
					//because it go to LeftReadBus
					out_AddressGoWithInstruction2ALU=`WordZero;
					//no need to deal with psr
				end//bx
				else
				begin
					//half word transfer
					NowIn_HalfTransfer=1'b1;
					out_ALUMisc[19:18]=in_PipelineRegister_IFID[6:5];
					if(in_PipelineRegister_IFID[20]==1'b1)
					begin
						//halfword load
						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							out_AddressGoWithInstruction2ALU=PCAdder8or4Result;
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end
				
						//deal with offset
						//right read bus
						if(in_PipelineRegister_IFID[22]==1'b0)
						begin
							//offset come from register and need a shift
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b1;
							out_ALURightFromImm=1'b0;

							//imm is not need here
							out_ALUExtendedImmediateValue=`WordDontCare;
						end
						else
						begin
							//offset come from imm in instruction
							//no use here
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;

							//imm act as offset
							out_ALUExtendedImmediateValue={24'h000000,in_PipelineRegister_IFID[11:8],in_PipelineRegister_IFID[3:0]};
						end
						//shift type
						out_ALURightShiftType=`Def_ShiftType_LogicLeft;
						//shift ammount
						out_ALUSecondImmediateValue=`WordZero;
				
						//third read bus will be not use
						out_ThirdReadRegisterEnable=1'b0;
						out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
						out_ALUThirdFromImm=1'b1;
				
						//a valid ALU
						out_ALUEnable=1'b1;
						//add or sub the offset from base
						if(in_PipelineRegister_IFID[23]==1'b1)
						begin
							//add
							out_ALUType=`ALUType_Add;
						end
						else
						begin
							//sub
							out_ALUType=`ALUType_Sub;
						end

						//deal with the case of pre or post index
						if(in_PipelineRegister_IFID[24]==1'b1)
						begin
							//pre index
							//first perform alu then use result as the address to load
							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
							if(in_PipelineRegister_IFID[21]==1'b1)
							begin
								//write back alu result to base register
								out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

								//main thread of mem stage
								out_MEMEnable=1'b1;
								out_MEMType=`MEMType_LoadMainHalfWord;

								if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
									out_MEMTargetRegister=`Def_LinkRegister;
								else
									out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_MovMain;
								out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
							end
							else
							begin
								//no need to write back
								//only when now can the base register be r15
								//because the r15 can not be write back
								out_ALUTargetRegister=`Def_LinkRegister;

								//main thread of mem stage
								out_MEMEnable=1'b1;
								out_MEMType=`MEMType_LoadMainHalfWord;

								if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
									out_MEMTargetRegister=`Def_LinkRegister;
								else
									out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];


								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_Null;
								out_SimpleMEMTargetRegister=`Def_LinkRegister;
							end
						end
						else
						begin
							//post index
							//perform alu but use origin base as address to load
							//in this mode the write back bit is always 1'b0
							//but the alu result must ALWAYS WRITE BACK to base register
							//because if you do not want to write back, you do not need this address mode,
							// a normal address mode with 0 offset will be enough
							//so main alu thread compute the result,main mem thread will load according to simple alu result
							//simple alu will pass leftoperand(base) to main mem,simple mem will pass main alu result to write
							out_SimpleALUType=`ALUType_Mvl;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

							//main thread of mem stage
							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_LoadSimpleHalfWord;

							if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
								out_MEMTargetRegister=`Def_LinkRegister;
							else
								out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];


							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_MovMain;
							out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
						end
						out_IDOwnCanGo=1'b1;

						//when target register is pc,then this bit will tell mem stage to write loaded value to if
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
							out_ALUMisc[7]=1'b1;

						Next_PrevOperationWantWriteRegisterFromMEM=1'b1;
						Next_PrevWriteRegister=in_PipelineRegister_IFID[15:12];
					end//half word load
					else
					begin
						//half word store
						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							out_AddressGoWithInstruction2ALU=PCAdder8or4Result;
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end

						//deal with the offset
						//right read bus
						if(in_PipelineRegister_IFID[22]==1'b0	)
						begin
							//offset come from register and need a shift
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b1;
							out_ALURightFromImm=1'b0;

							//imm is not need here
							out_ALUExtendedImmediateValue=`WordDontCare;
						end
						else
						begin
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;

							//imm act as offset
							out_ALUExtendedImmediateValue={20'h00000,in_PipelineRegister_IFID[11:0]};
						end
						//shift type
						out_ALURightShiftType=`Def_ShiftType_LogicLeft;
						//shift ammount
						//use out_ALUMisc to pass shift count
						// the third read register bus will be use as store value read
						out_ALUMisc[5:0]={6'b000001};
		
						//third read bus will be use to read store value
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
						begin
							out_ALUSecondImmediateValue=PCAdder12or4Result;
							//do not read register
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							//can not be forward
							out_ALUThirdFromImm=1'b1;
						end
						else
						begin
							out_ALUSecondImmediateValue=`WordDontCare;
							out_ThirdReadRegisterEnable=1'b1;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							//can be forward
							out_ALUThirdFromImm=1'b0;
						end

						out_ALUEnable=1'b1;
						//add or sub the offset from base
						if(in_PipelineRegister_IFID[23]==1'b1)
						begin
							//add
							out_ALUType=`ALUType_Add;
						end
						else
						begin
							//sub
							out_ALUType=`ALUType_Sub;
						end
			
						//deal with the case of pre or post index
						if(in_PipelineRegister_IFID[24]==1'b1)
						begin
							//pre index
							//first perform alu then use result as the address to store
							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
							if(in_PipelineRegister_IFID[21]==1'b1)
							begin
								//write back alu result to base register
								out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

								//main thread of mem stage
								out_MEMEnable=1'b1;
								out_MEMType=`MEMType_StoreMainHalfWord;
								out_MEMTargetRegister=`Def_LinkRegister;

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_MovMain;
								out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
							end
							else
							begin
								//no need to write back
								out_ALUTargetRegister=`Def_LinkRegister;

								//main thread of mem stage
								out_MEMEnable=1'b1;
								out_MEMType=`MEMType_StoreMainHalfWord;
								out_MEMTargetRegister=`Def_LinkRegister;

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_Null;
								out_SimpleMEMTargetRegister=`Def_LinkRegister;
							end
						end
						else
						begin
							//post index
							//perform alu but use origin base as address to load
							//in this mode the write back bit is always 1'b0
							//but the alu result must ALWAYS WRITE BACK to base register
							//because if you do not want to write back, you do not need this address mode,
							// a normal address mode with 0 offset will be enough
							//so main alu thread compute the result,main mem thread will load according to simple alu result
							//simple alu will pass leftoperand(base) to main mem,simple mem will pass main alu result to write
							out_SimpleALUType=`ALUType_Mvl;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
	
							out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];
				
							//main thread of mem stage
							out_MEMEnable=1'b1;
							out_MEMType=`MEMType_StoreSimpleHalfWord;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_MovMain;
							out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
						end
						out_IDOwnCanGo=1'b1;
					end//half word store
				end
			end
		2'b01:
			begin
				if(in_PipelineRegister_IFID[25]==1'b0 || in_PipelineRegister_IFID[4]==1'b0)
				begin
					//ldr or str
					if(in_PipelineRegister_IFID[20]==1'b1)
					begin//ldr
						NowIn_LDR=1'b1;
						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							out_AddressGoWithInstruction2ALU=PCAdder8or4Result;
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end
				
						//deal with offset
						//right read bus
						if(in_PipelineRegister_IFID[25]==1'b1)
						begin
							//offset come from register and need a shift
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b1;
							out_ALURightFromImm=1'b0;

							//imm is not need here
							out_ALUExtendedImmediateValue=`WordDontCare;

							//shift type
							out_ALURightShiftType=in_PipelineRegister_IFID[6:5];
							//shift ammount
							out_ALUSecondImmediateValue={24'h000000,3'b000,in_PipelineRegister_IFID[11:7]};
						end
						else
						begin
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;

							//imm act as offset
							out_ALUExtendedImmediateValue={20'h00000,in_PipelineRegister_IFID[11:0]};

							out_ALURightShiftType=in_PipelineRegister_IFID[6:5];
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;
						end
				
						//third read bus will be use
						out_ThirdReadRegisterEnable=1'b0;
						out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
						out_ALUThirdFromImm=1'b1;
				
						//a valid ALU
						out_ALUEnable=1'b1;
						//add or sub the offset from base
						if(in_PipelineRegister_IFID[23]==1'b1)
						begin
							//add
							out_ALUType=`ALUType_Add;
						end
						else
						begin
							//sub
							out_ALUType=`ALUType_Sub;
						end

						//deal with the case of pre or post index
						if(in_PipelineRegister_IFID[24]==1'b1)
						begin
							//pre index
							//first perform alu then use result as the address to load
							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
							if(in_PipelineRegister_IFID[21]==1'b1)
							begin
								//write back alu result to base register
								out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

								//main thread of mem stage
								out_MEMEnable=1'b1;
								if(in_PipelineRegister_IFID[22]==1'b1)
									out_MEMType=`MEMType_LoadMainByte;
								else
									out_MEMType=`MEMType_LoadMainWord;

								if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
									out_MEMTargetRegister=`Def_LinkRegister;
								else
									out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_MovMain;
								out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
							end
							else
							begin
								//no need to write back
								//only when now can the base register be r15
								//because the r15 can not be write back
								out_ALUTargetRegister=`Def_LinkRegister;

								//main thread of mem stage
								out_MEMEnable=1'b1;
								if(in_PipelineRegister_IFID[22]==1'b1)
									out_MEMType=`MEMType_LoadMainByte;
								else
									out_MEMType=`MEMType_LoadMainWord;

								if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
									out_MEMTargetRegister=`Def_LinkRegister;
								else
									out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];


								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_Null;
								out_SimpleMEMTargetRegister=`Def_LinkRegister;
							end
						end
						else
						begin
							//post index
							//perform alu but use origin base as address to load
							//in this mode the write back bit is always 1'b0
							//but the alu result must ALWAYS WRITE BACK to base register
							//because if you do not want to write back, you do not need this address mode,
							// a normal address mode with 0 offset will be enough
							//so main alu thread compute the result,main mem thread will load according to simple alu result
							//simple alu will pass leftoperand(base) to main mem,simple mem will pass main alu result to write
							out_SimpleALUType=`ALUType_Mvl;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

							//main thread of mem stage
							out_MEMEnable=1'b1;
							if(in_PipelineRegister_IFID[22]==1'b1)
								out_MEMType=`MEMType_LoadSimpleByte;
							else
								out_MEMType=`MEMType_LoadSimpleWord;

							if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
								out_MEMTargetRegister=`Def_LinkRegister;
							else
								out_MEMTargetRegister=in_PipelineRegister_IFID[15:12];


							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_MovMain;
							out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
						end
						out_IDOwnCanGo=1'b1;

						//when target register is pc,then this bit will tell mem stage to write loaded value to if
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
							out_ALUMisc[7]=1'b1;

						Next_PrevOperationWantWriteRegisterFromMEM=1'b1;
						Next_PrevWriteRegister=in_PipelineRegister_IFID[15:12];
					end//ldr
					else
					begin//str
						NowIn_STR=1'b1;
						//left source register can be direct read
						if({4'h0,in_PipelineRegister_IFID[19:16]}==`Def_PCNumber)
						begin
							//left register is pc
							//do not read register file
							//just send out pc on out_AddressGoWithInstruction2ALU
							out_AddressGoWithInstruction2ALU=PCAdder8or4Result;
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left come from imm pc
							//do not forward
							out_ALULeftFromImm=1'b1;
						end
						else
						begin
							//left register is not pc
							out_LeftReadRegisterEnable=1'b1;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
						end

						//deal with the offset
						//right read bus
						if(in_PipelineRegister_IFID[25]==1'b1)
						begin
							//offset come from register and need a shift
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b1;
							out_ALURightFromImm=1'b0;

							//imm is not need here
							out_ALUExtendedImmediateValue=`WordDontCare;

							//shift type
							out_ALURightShiftType=in_PipelineRegister_IFID[6:5];
							//shift ammount
							//use out_ALUMisc to pass shift count
							// the third read register bus will be use as store value read
							out_ALUMisc[5:0]={in_PipelineRegister_IFID[11:7],1'b1};
						end
						else
						begin
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;

							//imm act as offset
							out_ALUExtendedImmediateValue={20'h00000,in_PipelineRegister_IFID[11:0]};

							out_ALURightShiftType=in_PipelineRegister_IFID[6:5];
							//shift ammount is always 0
							//use out_ALUMisc to pass shift count
							// the third read register bus will be use as store value read
							out_ALUMisc[5:0]={6'b000001};
						end
		
						//third read bus will be use to read store value
						if({4'h0,in_PipelineRegister_IFID[15:12]}==`Def_PCNumber)
						begin
							out_ALUSecondImmediateValue=PCAdder12or4Result;
							//do not read register
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							//can not be forward
							out_ALUThirdFromImm=1'b1;
						end
						else
						begin
							out_ALUSecondImmediateValue=`WordDontCare;
							out_ThirdReadRegisterEnable=1'b1;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							//can be forward
							out_ALUThirdFromImm=1'b0;
						end

						out_ALUEnable=1'b1;
						//add or sub the offset from base
						if(in_PipelineRegister_IFID[23]==1'b1)
						begin
							//add
							out_ALUType=`ALUType_Add;
						end
						else
						begin
							//sub
							out_ALUType=`ALUType_Sub;
						end
			
						//deal with the case of pre or post index
						if(in_PipelineRegister_IFID[24]==1'b1)
						begin
							//pre index
							//first perform alu then use result as the address to store
							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
							if(in_PipelineRegister_IFID[21]==1'b1)
							begin
								//write back alu result to base register
								out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

								//main thread of mem stage
								out_MEMEnable=1'b1;
								if(in_PipelineRegister_IFID[22]==1'b1)
									out_MEMType=`MEMType_StoreMainByte;
								else
									out_MEMType=`MEMType_StoreMainWord;
								out_MEMTargetRegister=`Def_LinkRegister;

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_MovMain;
								out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
							end
							else
							begin
								//no need to write back
								out_ALUTargetRegister=`Def_LinkRegister;

								//main thread of mem stage
								out_MEMEnable=1'b1;
								if(in_PipelineRegister_IFID[22]==1'b1)
									out_MEMType=`MEMType_StoreMainByte;
								else
									out_MEMType=`MEMType_StoreMainWord;
								out_MEMTargetRegister=`Def_LinkRegister;

								//simple thread of mem stage
								out_SimpleMEMType=`MEMType_Null;
								out_SimpleMEMTargetRegister=`Def_LinkRegister;
							end
						end
						else
						begin
							//post index
							//perform alu but use origin base as address to load
							//in this mode the write back bit is always 1'b0
							//but the alu result must ALWAYS WRITE BACK to base register
							//because if you do not want to write back, you do not need this address mode,
							// a normal address mode with 0 offset will be enough
							//so main alu thread compute the result,main mem thread will load according to simple alu result
							//simple alu will pass leftoperand(base) to main mem,simple mem will pass main alu result to write
							out_SimpleALUType=`ALUType_Mvl;
							out_SimpleALUTargetRegister=`Def_LinkRegister;
	
							out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];
				
							//main thread of mem stage
							out_MEMEnable=1'b1;
							if(in_PipelineRegister_IFID[22]==1'b1)
								out_MEMType=`MEMType_StoreSimpleByte;
							else
								out_MEMType=`MEMType_StoreSimpleWord;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_MovMain;
							out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
						end
						out_IDOwnCanGo=1'b1;
					end//str
				end
				else
				begin
					//undef
					NowIn_Undef=1'b1;
				end
			end
		2'b10:
			begin
				if(in_PipelineRegister_IFID[25]==1'b0)
				begin
					//LDM stm
					if(in_PipelineRegister_IFID[20]==1'b1)
					begin//ldm
						NowIn_LDM=1'b1;
						if(in_PipelineRegister_IFID[23]==1'b0)
						begin//down
						   if(DecRegNumber[7:4]==4'b1110)
						   begin
						   	//perform delayed branch
						   	//except delay branch signal, nothing is use
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							out_ALULeftFromImm=1'b1;
				
							//deal with offset
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;
			
							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Sub;
							out_ALUTargetRegister=`Def_LinkRegister;

							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							//main thread of mem stage
							out_MEMEnable=1'b1;
							//always load word
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_Null;
							out_SimpleMEMTargetRegister=`Def_LinkRegister;

							out_IDOwnCanGo=1'b1;
							//out_ALUMisc[14] means delay branch
							if(in_PipelineRegister_IFID[15]==1'b1)
								out_ALUMisc[14]=1'b1;
							else
								out_ALUMisc[14]=1'b0;

							//out_ALUMisc[15] means store delay branch target
							out_ALUMisc[15]=1'b0;
				
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[15]==1'b1 && in_PipelineRegister_IFID[22]==1'b1)
							begin
								//condition code valid in alu and mem stage
								out_ALUPSRType=`ALUPSRType_SPSR2CPSR;
								out_MEMPSRType=`MEMPSRType_WriteCPSR;
							end

				
							Next_IncRegNumber=`Def_RegisterSelectZero;
							Next_DecRegNumber=`Def_RegisterSelectAllOne;

							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;

						   end//of DecRegNumber[7:4]==4'b1110
						   else
						   begin
							out_LeftReadRegisterEnable=1'b1;
				
							//if write back is need, then just read left register as base
							//if write back is not need and it is the first access ,also read left register as base
							// if write back is not need and it is not the first access, then just use LocalForwardRegister
							if(in_PipelineRegister_IFID[21]==1'b1 || IsFirstAccess==1'b1)
								out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							else 
								out_LeftReadRegisterNumber=`Def_LocalForwardRegister;
					
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
				
							//deal with offset
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							//imm act as offset
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								out_ALUExtendedImmediateValue=32'h0000_0004;
							else
								out_ALUExtendedImmediateValue=32'h0000_0000;
		
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;

							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Sub;

							//deal with the case of pre or post index
							if(in_PipelineRegister_IFID[24]==1'b1)
							begin
								//pre index
								//first perform alu then use result as the address to load
								out_SimpleALUType=`ALUType_Null;
								out_SimpleALUTargetRegister=`Def_LinkRegister;
								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									//write back alu result to base register
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadMainWord;
							
										if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,DecRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadMainWord;
							
										if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,DecRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									//no need to write back, so just write the modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end
							else
							begin
								//post index
								//perform alu but use origin base as address to load
								out_SimpleALUType=`ALUType_Mvl;
								out_SimpleALUTargetRegister=`Def_LinkRegister;

								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadSimpleWord;

										if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,DecRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadSimpleWord;
										
										if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,DecRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									//no need to write back, so just write modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end

							out_IDOwnCanGo=1'b0;
							out_ALUMisc[14]=1'b0;

							//when target register is pc,and PC is to be load
							//then tell mem stage to store this pc and wait for delayed branch signal
							//out_ALUMisc[15] means store delay branch target
							if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber && in_PipelineRegister_IFID[15]==1'b1)
								out_ALUMisc[15]=1'b1;
							else
								out_ALUMisc[15]=1'b0;
				
							//out_ALUMisc[16] means access user bank registers
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[15]==1'b0 && in_PipelineRegister_IFID[22]==1'b1)
								out_ALUMisc[16]=1'b1;
							else
								out_ALUMisc[16]=1'b0;
				
							Next_IncRegNumber=IncRegNumberAdd1;
							Next_DecRegNumber=DecRegNumberSub1;

							Next_PrevOperationWantWriteRegisterFromMEM=IfCurrentRegAccessByLDMSTM;
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								Next_PrevWriteRegister={4'b0000,DecRegNumber[3:0]};
							else
								Next_PrevWriteRegister=`Def_LinkRegister;
					
						   end//of DecRegNumber[7:4]!=4'b1110
						end//of down
						else//up
						begin
						   if(IncRegNumber[7:4]==4'b0001)
						   begin
						   	//perform delayed branch
						   	//except delay branch signal, nothing is use
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							out_ALULeftFromImm=1'b1;
				
							//deal with offset
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;

							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;
		
							//sub 4 from current register
							out_ALUType=`ALUType_Sub;
							out_ALUTargetRegister=`Def_LinkRegister;

							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							//main thread of mem stage
							out_MEMEnable=1'b1;
							//always load word
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_Null;
							out_SimpleMEMTargetRegister=`Def_LinkRegister;

							out_IDOwnCanGo=1'b1;
							//out_ALUMisc[14] means delay branch
							if(in_PipelineRegister_IFID[15]==1'b1)
								out_ALUMisc[14]=1'b1;
							else
								out_ALUMisc[14]=1'b0;

							//out_ALUMisc[15] means store delay branch target
							out_ALUMisc[15]=1'b0;
				
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[15]==1'b1 && in_PipelineRegister_IFID[22]==1'b1)
							begin
								//condition code valid in alu and mem stage
								out_ALUPSRType=`ALUPSRType_SPSR2CPSR;
								out_MEMPSRType=`MEMPSRType_WriteCPSR;
							end

				
							Next_IncRegNumber=`Def_RegisterSelectZero;
							Next_DecRegNumber=`Def_RegisterSelectAllOne;
	
							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;

						   end//of IncRegNumber[7:4]==4'b0001
						   else
						   begin
							out_LeftReadRegisterEnable=1'b1;
				
							//if write back is need, then just read left register as base
							//if write back is not need and it is the first access ,also read left register as base
							// if write back is not need and it is not the first access, then just use LocalForwardRegister
							if(in_PipelineRegister_IFID[21]==1'b1 || IsFirstAccess==1'b1)
								out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							else 
								out_LeftReadRegisterNumber=`Def_LocalForwardRegister;
					
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
				
							//deal with offset
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							//imm act as offset
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								out_ALUExtendedImmediateValue=32'h0000_0004;
							else
								out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;

							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Add;

							//deal with the case of pre or post index
							if(in_PipelineRegister_IFID[24]==1'b1)
							begin
								//pre index
								//first perform alu then use result as the address to load
								out_SimpleALUType=`ALUType_Null;
								out_SimpleALUTargetRegister=`Def_LinkRegister;
								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									//write back alu result to base register
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadMainWord;
							
										if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,IncRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadMainWord;
							
										if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,IncRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									//no need to write back, so just write the modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end
							else
							begin
								//post index
								//perform alu but use origin base as address to load
								out_SimpleALUType=`ALUType_Mvl;
								out_SimpleALUTargetRegister=`Def_LinkRegister;

								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadSimpleWord;

										if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,IncRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always load word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_LoadSimpleWord;
							
										if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber)
											out_MEMTargetRegister=`Def_LinkRegister;
										else
											out_MEMTargetRegister={4'b0000,IncRegNumber[3:0]};
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									//no need to write back, so just write modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end

							out_IDOwnCanGo=1'b0;
							out_ALUMisc[14]=1'b0;

							//when target register is pc,and PC is to be load
							//then tell mem stage to store this pc and wait for delayed branch signal
							//out_ALUMisc[15] means store delay branch target
							if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber && in_PipelineRegister_IFID[15]==1'b1)
								out_ALUMisc[15]=1'b1;
							else
								out_ALUMisc[15]=1'b0;
				
							//out_ALUMisc[16] means access user bank registers
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[15]==1'b0 && in_PipelineRegister_IFID[22]==1'b1)
								out_ALUMisc[16]=1'b1;
							else
								out_ALUMisc[16]=1'b0;
				
							Next_IncRegNumber=IncRegNumberAdd1;
							Next_DecRegNumber=DecRegNumberSub1;

							Next_PrevOperationWantWriteRegisterFromMEM=IfCurrentRegAccessByLDMSTM;
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								Next_PrevWriteRegister={4'b0000,IncRegNumber[3:0]};
							else
								Next_PrevWriteRegister=`Def_LinkRegister;
					
						   end//of IncRegNumber[7:4]!=4'b0001
						end//of up
					end//ldm
					else
					begin//stm
						NowIn_STM=1'b1;
						if(in_PipelineRegister_IFID[23]==1'b0)
						begin//down
						   if(DecRegNumber[7:4]==4'b1110)
						   begin
						   	//this is stm, no need to do anything in this cycle
						   	//just insert a blank into pipeline
			   	
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							out_ALULeftFromImm=1'b1;
				
							//deal with offset
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;

							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Sub;
							out_ALUTargetRegister=`Def_LinkRegister;

							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							//main thread of mem stage
							out_MEMEnable=1'b1;
							//always load word
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_Null;
							out_SimpleMEMTargetRegister=`Def_LinkRegister;

							out_IDOwnCanGo=1'b1;

							out_ALUMisc[14]=1'b0;

							out_ALUMisc[15]=1'b0;
				
							Next_IncRegNumber=`Def_RegisterSelectZero;
							Next_DecRegNumber=`Def_RegisterSelectAllOne;

							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;
			
						   end//of DecRegNumber[7:4]==4'b1110
						   else
						   begin
							out_LeftReadRegisterEnable=1'b1;
				
							//if write back is need, then just read left register as base
							//if write back is not need and it is the first access ,also read left register as base
							// if write back is not need and it is not the first access, then just use LocalForwardRegister
							if(in_PipelineRegister_IFID[21]==1'b1 || IsFirstAccess==1'b1)
								out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							else 
								out_LeftReadRegisterNumber=`Def_LocalForwardRegister;
					
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
				
							//deal with offset
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
		
							//imm act as offset
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								out_ALUExtendedImmediateValue=32'h0000_0004;
							else
								out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							//but must be pass by out_ALUMisc
							out_ALUMisc[5:0]=6'b000001;
							//this is the third register bus that use to read stored register
							if({4'b0000,DecRegNumber[3:0]}==`Def_PCNumber)
							begin
								if(in_PipelineRegister_IFID[15]==1'b1)
								begin
									out_ALUSecondImmediateValue=PCAdder12or4Result;
									out_ThirdReadRegisterEnable=1'b0;
									out_ThirdReadRegisterNumber={4'b0000,DecRegNumber[3:0]};
									out_ALUThirdFromImm=1'b1;
								end
								else
								begin
									out_ALUSecondImmediateValue=PCAdder12or4Result;
									out_ThirdReadRegisterEnable=1'b0;
									out_ThirdReadRegisterNumber={4'b0000,DecRegNumber[3:0]};
									out_ALUThirdFromImm=1'b1;
								end
							end
							else
							begin
								out_ALUSecondImmediateValue=`WordDontCare;
								//third read bus will be use to read stored register
								out_ThirdReadRegisterEnable=IfCurrentRegAccessByLDMSTM;
								out_ThirdReadRegisterNumber={4'b0000,DecRegNumber[3:0]};
								out_ALUThirdFromImm=1'b0;
							end


							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Sub;

							//deal with the case of pre or post index
							if(in_PipelineRegister_IFID[24]==1'b1)
							begin
								//pre index
								//first perform alu then use result as the address to store
								out_SimpleALUType=`ALUType_Null;
								out_SimpleALUTargetRegister=`Def_LinkRegister;
								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									//write back alu result to base register
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreMainWord;
										//no need to write 
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreMainWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									//no need to write back, so just write the modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end
							else
							begin
								//post index
								//perform alu but use origin base as address to store
								out_SimpleALUType=`ALUType_Mvl;
								out_SimpleALUTargetRegister=`Def_LinkRegister;

								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreSimpleWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreSimpleWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									//no need to write back, so just write modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end

							out_IDOwnCanGo=1'b0;
							out_ALUMisc[14]=1'b0;

							out_ALUMisc[15]=1'b0;
				
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[22]==1'b1)
								out_ALUMisc[16]=1'b1;
							else
								out_ALUMisc[16]=1'b0;
				
							Next_IncRegNumber=IncRegNumberAdd1;
							Next_DecRegNumber=DecRegNumberSub1;

							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;
					
						   end//of DecRegNumber[7:4]!=4'b1110
						end//of down
						else//up
						begin
			  			   if(IncRegNumber[7:4]==4'b0001)
						   begin
			   				//this is stm, no need to do anything in this cycle
			   				//just insert a blank into pipeline
			   
							out_LeftReadRegisterEnable=1'b0;
							out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							out_ALULeftFromImm=1'b1;
				
							//deal with offset
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
		
							out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							out_ALUSecondImmediateValue=`WordZero;

							//third read bus will be use
							out_ThirdReadRegisterEnable=1'b0;
							out_ThirdReadRegisterNumber=in_PipelineRegister_IFID[15:12];
							out_ALUThirdFromImm=1'b1;

							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Add;
							out_ALUTargetRegister=`Def_LinkRegister;

							out_SimpleALUType=`ALUType_Null;
							out_SimpleALUTargetRegister=`Def_LinkRegister;

							//main thread of mem stage
							out_MEMEnable=1'b1;
							//always load word
							out_MEMType=`MEMType_BlankOp;
							out_MEMTargetRegister=`Def_LinkRegister;

							//simple thread of mem stage
							out_SimpleMEMType=`MEMType_Null;
							out_SimpleMEMTargetRegister=`Def_LinkRegister;

							out_IDOwnCanGo=1'b1;

							out_ALUMisc[14]=1'b0;

							out_ALUMisc[15]=1'b0;
				
							Next_IncRegNumber=`Def_RegisterSelectZero;
							Next_DecRegNumber=`Def_RegisterSelectAllOne;

							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;

						   end//of IncRegNumber[7:4]==4'b1110
						   else
						   begin
							out_LeftReadRegisterEnable=1'b1;
				
							//if write back is need, then just read left register as base
							//if write back is not need and it is the first access ,also read left register as base
							// if write back is not need and it is not the first access, then just use LocalForwardRegister
							if(in_PipelineRegister_IFID[21]==1'b1 || IsFirstAccess==1'b1)
								out_LeftReadRegisterNumber=in_PipelineRegister_IFID[19:16];
							else 
								out_LeftReadRegisterNumber=`Def_LocalForwardRegister;
						
							//left operand are not from immediate
							out_ALULeftFromImm=1'b0;
				
							//deal with offset
							//offset come from imm in instruction
							out_RightReadRegisterNumber=in_PipelineRegister_IFID[3:0];
							out_RightReadRegisterEnable=1'b0;
							out_ALURightFromImm=1'b1;
	
							//imm act as offset
							if(IfCurrentRegAccessByLDMSTM==1'b1)
								out_ALUExtendedImmediateValue=32'h0000_0004;
							else
								out_ALUExtendedImmediateValue=32'h0000_0000;
	
							out_ALURightShiftType=`Def_ShiftType_LogicLeft;
							//shift ammount is always 0
							//but must be pass by out_ALUMisc
							out_ALUMisc[5:0]=6'b000001;
							//this is the third register bus that use to read stored register
							if({4'b0000,IncRegNumber[3:0]}==`Def_PCNumber)
							begin
								if(in_PipelineRegister_IFID[15]==1'b1)
								begin
									out_ALUSecondImmediateValue=PCAdder12or4Result;
									out_ThirdReadRegisterEnable=1'b0;
									out_ThirdReadRegisterNumber={4'b0000,IncRegNumber[3:0]};
									out_ALUThirdFromImm=1'b1;
								end
								else
								begin
									out_ALUSecondImmediateValue=PCAdder12or4Result;
									out_ThirdReadRegisterEnable=1'b0;
									out_ThirdReadRegisterNumber={4'b0000,IncRegNumber[3:0]};
									out_ALUThirdFromImm=1'b1;
								end
							end
							else
							begin
								out_ALUSecondImmediateValue=`WordDontCare;
								//third read bus will be use to read stored register
								out_ThirdReadRegisterEnable=IfCurrentRegAccessByLDMSTM;
								out_ThirdReadRegisterNumber={4'b0000,IncRegNumber[3:0]};
								out_ALUThirdFromImm=1'b0;
							end


							//a valid ALU
							out_ALUEnable=1'b1;

							//sub 4 from current register
							out_ALUType=`ALUType_Add;

							//deal with the case of pre or post index
							if(in_PipelineRegister_IFID[24]==1'b1)
							begin
								//pre index
								//first perform alu then use result as the address to store
								out_SimpleALUType=`ALUType_Null;
								out_SimpleALUTargetRegister=`Def_LinkRegister;
								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									//write back alu result to base register
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];

									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreMainWord;
										//no need to write 
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreMainWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end


									//simple thread of mem stage
									//no need to write back, so just write the modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end
							else
							begin
								//post index
								//perform alu but use origin base as address to store
								out_SimpleALUType=`ALUType_Mvl;
								out_SimpleALUTargetRegister=`Def_LinkRegister;

								if(in_PipelineRegister_IFID[21]==1'b1)
								begin
									out_ALUTargetRegister=in_PipelineRegister_IFID[19:16];
			
									//main thread of mem stage
									out_MEMEnable=1'b1;

									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreSimpleWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=in_PipelineRegister_IFID[19:16];
								end
								else
								begin
									//no need to write back
									//so just write base value to Def_LocalForwardRegister 
									out_ALUTargetRegister=`Def_LocalForwardRegister;

									//main thread of mem stage
									out_MEMEnable=1'b1;
						
									//always store word
									if(IfCurrentRegAccessByLDMSTM==1'b1)
									begin
										out_MEMType=`MEMType_StoreSimpleWord;
										//no need to write
										out_MEMTargetRegister=`Def_LinkRegister;
									end
									else
									begin
										out_MEMType=`MEMType_BlankOp;
										out_MEMTargetRegister=`Def_LinkRegister;
									end

									//simple thread of mem stage
									//no need to write back, so just write modified base to Def_LocalForwardRegister
									out_SimpleMEMType=`MEMType_MovMain;
									out_SimpleMEMTargetRegister=`Def_LocalForwardRegister;
								end
							end

							out_IDOwnCanGo=1'b0;
							out_ALUMisc[14]=1'b0;

							out_ALUMisc[15]=1'b0;
				
							if(in_IsInPrivilegedMode==1'b1 && in_PipelineRegister_IFID[22]==1'b1)
								out_ALUMisc[16]=1'b1;
							else
								out_ALUMisc[16]=1'b0;
				
							Next_IncRegNumber=IncRegNumberAdd1;
							Next_DecRegNumber=DecRegNumberSub1;

							Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
							Next_PrevWriteRegister=`Def_LinkRegister;
					
						   end//of IncRegNumber[7:4]!=4'b1110
						end//of up
					end//stm
				end
				else
				begin
					//branch
					NowIn_Branch=1'b1;
					
					//deal with left operand
					//first i must use my pc ahead as the left register
					out_LeftReadRegisterEnable=1'b0;
					out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALULeftFromImm=1'b1;
			
					//right operand use imm
					out_RightReadRegisterEnable=1'b0;
					out_RightReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALURightFromImm=1'b1;
			
					//shift count act as third operand
					out_ThirdReadRegisterEnable=1'b0;
					out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALUThirdFromImm=1'b1;
			
					out_ALUEnable=1'b1;
					out_ALUType=`ALUType_Add;
					out_ALUTargetRegister=`Def_LinkRegister;
			
					out_ALURightShiftType=2'b00;
					//right operand
					if(in_ThumbState==1'b0)
						out_ALUExtendedImmediateValue={{6{in_PipelineRegister_IFID[23]}},in_PipelineRegister_IFID[23:0],2'b00};
					else
						out_ALUExtendedImmediateValue={{7{in_PipelineRegister_IFID[23]}},in_PipelineRegister_IFID[23:0],1'b0};

					//shift count
					out_ALUSecondImmediateValue=`WordZero;
					out_IDOwnCanGo=1'b1;
	
					out_MEMEnable=1'b1;
					//main mem stage wil not be use
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;
					out_ALUMisc=`WordZero;
					out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
					//main thread result must be used to change pc
					//output new pc to IF using main alu
					out_ALUMisc[6]=1'b1;
					if(in_PipelineRegister_IFID[24]==1'b1)
					begin
						//branch with link
						//write pc+4 to R14 unsing simple thread
						out_SimpleALUType=`ALUType_MvNextInstructionAddress;
						out_SimpleALUTargetRegister=`Def_SBLRegister;
						out_NextAddressGoWithInstruction2ALU=in_NextInstructionAddress;
				
						out_SimpleMEMType=`MEMType_MovSimple;
						out_SimpleMEMTargetRegister=`Def_SBLRegister;
					end//normal branch do not need to store pc+4 to R14
			
					//only when there is a branch or a alu using pc
					//can i out address of this instrcution to out_AddressGoWithInstruction2ALU
					//because it go to LeftReadBus
					out_AddressGoWithInstruction2ALU=PCAdder8or4Result;
					//no need to deal with psr
				end//branch
			end
		2'b11:
			begin
				if(in_PipelineRegister_IFID[25]==1'b0)
				begin
					//cop data transfer
					NowIn_CDT=1'b1;
				end
				else if(in_PipelineRegister_IFID[24]==1'b0)
				begin
					if(in_PipelineRegister_IFID[4]==1'b0)
					begin
						//cop data op
						NowIn_CDO=1'b1;
					end
					else
					begin
						//cop reg transfer
						NowIn_CRT=1'b1;
					end
				end
				else
				begin
					//SWI
					NowIn_SWI=1'b1;
					//software interrupt
			
					out_LeftReadRegisterEnable=1'b0;
					out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALULeftFromImm=1'b0;

					//right read bus will be use to pass target address -- 0x8
					out_RightReadRegisterEnable=1'b0;
					out_RightReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALURightFromImm=1'b1;
					out_ALUExtendedImmediateValue=`Def_SWI_Service;
		
					out_ThirdReadRegisterEnable=1'b0;
					out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
					out_ALUThirdFromImm=1'b0;

					//alu main thread will be use to branch
					out_ALUEnable=1'b1;
					out_ALUType=`ALUType_Mov;
					out_ALUTargetRegister=`Def_LinkRegister;

					//do not shift, just use right operand as branch target address
					out_ALURightShiftType=2'b00;
					out_ALUSecondImmediateValue=`WordZero;
			
					out_IDOwnCanGo=1'b1;

					//mem not enable
					out_MEMEnable=1'b0;
					out_MEMType=`MEMType_BlankOp;
					out_MEMTargetRegister=`Def_LinkRegister;

					//simple will be use to write pc+4 to r14_svc
					out_SimpleALUType=`ALUType_MvNextInstructionAddress;
					out_SimpleALUTargetRegister=`Def_SBLRegister;
					out_NextAddressGoWithInstruction2ALU=in_NextInstructionAddress;
			
					//branch to service
					out_ALUMisc=`WordZero;
					//send out the condition code
					out_ALUMisc[31:28]=in_PipelineRegister_IFID[31:28];
					//a branch
					out_ALUMisc[6]=1'b1;
					//exception
					out_ALUMisc[8]=1'b1;
					out_ALUMisc[13:9]=`MODE_SVC;

					//simple MEM thread will be use to write pc+4 to r14_svc
					out_SimpleMEMType=`MEMType_MovSimple;
					out_SimpleMEMTargetRegister=`Def_SBLRegister;

					//condition code valid in alu and mem stage
					out_ALUPSRType=`ALUPSRType_CPSR2SPSR;
					out_MEMPSRType=`MEMPSRType_WriteBoth;

					//default is come from register
					out_CPSRFromImm=1'b0;
					out_SPSRFromImm=1'b0;
	
					//only a branch or alu/load/store use pc as base will send address on this port 
					//out to LeftReadBus
					//not use here
					out_AddressGoWithInstruction2ALU=`WordDontCare;
	
	
					Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
					Next_PrevWriteRegister=`Def_RegisterSelectZero;
				end//swi
			end
		endcase


		//you must decide if current send out operation have source operand come from 
		//prenious send out operation from MEM stage
		if(`Def_PrevOperationWriteSourceOfCurrentOperationFromMEM)
		begin
			out_IDOwnCanGo=1'b0;
			out_ALUEnable=1'b0;
			Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
			Next_PrevWriteRegister=`Def_RegisterSelectZero;
		end
	   end//have space in alu for new instruction
	   else
	   begin
		   	//no entry for the ALU operation
			//invalid instruction
			out_LeftReadRegisterEnable=1'b0;
			out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALULeftFromImm=1'b0;

			out_RightReadRegisterEnable=1'b0;
			out_RightReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALURightFromImm=1'b0;

			//third read bus will not be use
			out_ThirdReadRegisterEnable=1'b0;
			out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
			out_ALUThirdFromImm=1'b0;

			out_ALUEnable=1'b0;
			out_ALUType=`ALUType_Null;
			out_ALUTargetRegister=`Def_LinkRegister;

			//no use here
			out_ALURightShiftType=2'b00;
			
			out_ALUMisc[31:28]=`ConditionField_NV;
			
			out_ALUExtendedImmediateValue=`WordDontCare;
			out_ALUSecondImmediateValue=`WordDontCare;
		   	out_IDOwnCanGo=1'b1;

			//mem not enable
			out_MEMEnable=1'b0;
			out_MEMType=`MEMType_Null;
			out_MEMTargetRegister=`Def_LinkRegister;

			//simple alu will not be use
			out_SimpleALUType=`ALUType_Null;
			out_SimpleALUTargetRegister=`Def_LinkRegister;

			//simple MEM thread
			out_SimpleMEMType=`MEMType_Null;
			out_SimpleMEMTargetRegister=`Def_LinkRegister;
		
			//no entry in ALU,so must remember previos state
			Next_PrevOperationWantWriteRegisterFromMEM=PrevOperationWantWriteRegisterFromMEM;
			Next_PrevWriteRegister=PrevWriteRegister;
			
			Next_IncRegNumber=IncRegNumber;
			Next_DecRegNumber=DecRegNumber;
	   end//no space for new instruction in ALU
	end//valid instruction
	else
	begin
		//invalid instruction
		out_LeftReadRegisterEnable=1'b0;
		out_LeftReadRegisterNumber=`Def_RegisterSelectZero;
		out_ALULeftFromImm=1'b0;

		out_RightReadRegisterEnable=1'b0;
		out_RightReadRegisterNumber=`Def_RegisterSelectZero;
		out_ALURightFromImm=1'b0;
		
		//third read bus will not be use
		out_ThirdReadRegisterEnable=1'b0;
		out_ThirdReadRegisterNumber=`Def_RegisterSelectZero;
		out_ALUThirdFromImm=1'b0;

		out_ALUEnable=1'b0;
		out_ALUType=`ALUType_Null;
		out_ALUTargetRegister=`Def_LinkRegister;

		//no use here
		out_ALURightShiftType=2'b00;

		out_ALUMisc[31:28]=`ConditionField_NV;
		
		out_ALUExtendedImmediateValue=`WordDontCare;
		out_ALUSecondImmediateValue=`WordDontCare;
		out_IDOwnCanGo=1'b1;

		//mem not enable
		out_MEMEnable=1'b0;
		out_MEMType=`MEMType_Null;
		out_MEMTargetRegister=`Def_LinkRegister;

		//simple alu will not be use
		out_SimpleALUType=`ALUType_Null;
		out_SimpleALUTargetRegister=`Def_LinkRegister;

		//simple MEM thread
		out_SimpleMEMType=`MEMType_Null;
		out_SimpleMEMTargetRegister=`Def_LinkRegister;
		
		Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
		Next_PrevWriteRegister=`Def_RegisterSelectZero;
	end
	
	
	if(in_ChangePC==1'b1 || in_MEMChangePC==1'b1)
	begin
		Next_PrevOperationWantWriteRegisterFromMEM=1'b0;
		Next_PrevWriteRegister=`Def_RegisterSelectZero;
		Next_IncRegNumber=`Def_RegisterSelectZero;
		Next_DecRegNumber=`Def_RegisterSelectAllOne;
	end
end




//map ARM alu type to independante alu type
always @(in_PipelineRegister_IFID[24:21])
begin
	ALUTypeMapped=`ALUType_Null;
	case (in_PipelineRegister_IFID[24:21])
	`ARMALU_AND:
		ALUTypeMapped=`ALUType_And;
	`ARMALU_EOR:
		ALUTypeMapped=`ALUType_Eor;
	`ARMALU_SUB:
		ALUTypeMapped=`ALUType_Sub;
	`ARMALU_RSB:
		ALUTypeMapped=`ALUType_Rsb;
	`ARMALU_ADD:
		ALUTypeMapped=`ALUType_Add;
	`ARMALU_ADC:
		ALUTypeMapped=`ALUType_Adc;
	`ARMALU_SBC:
		ALUTypeMapped=`ALUType_Sbc;
	`ARMALU_RSC:
		ALUTypeMapped=`ALUType_Rsc;
	`ARMALU_TST:
		ALUTypeMapped=`ALUType_Tst;
	`ARMALU_TEQ:
		ALUTypeMapped=`ALUType_Teq;
	`ARMALU_CMP:
		ALUTypeMapped=`ALUType_Cmp;
	`ARMALU_CMN:
		ALUTypeMapped=`ALUType_Cmn;
	`ARMALU_ORR:
		ALUTypeMapped=`ALUType_Orr;
	`ARMALU_MOV:
		ALUTypeMapped=`ALUType_Mov;
	`ARMALU_BIC:
		ALUTypeMapped=`ALUType_Bic;
	`ARMALU_MVN:
		ALUTypeMapped=`ALUType_Mvn;
	endcase
end


//assign out_ALULeftRegister=LeftRegisterNumber;
//assign out_ALURightRegister=RightRegisterNumber;
//assign out_ALUThirdRegister=ThirdRegisterNumber;


//assign out_NextAddressGoWithInstruction2ALU=in_NextInstructionAddress;


//if there is a state?
always	@(PrevOperationWantWriteRegisterFromMEM	or
	IncRegNumber	or
	DecRegNumber	or
	MLAL1
)
begin
	if(PrevOperationWantWriteRegisterFromMEM==1'b0	&&
		IncRegNumber==`Def_RegisterSelectZero	&&
		DecRegNumber==`Def_RegisterSelectAllOne	&&
		MLAL1==1'b0)
	begin
		ExistState=1'b0;
	end
	else
	begin
		ExistState=1'b1;
	end
	
end
endmodule
