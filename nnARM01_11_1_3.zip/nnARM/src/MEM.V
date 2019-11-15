module	MEM(	//signal from ALU
			in_ALUValid,
			in_ALUWriteBus,
			in_ALUTargetRegister,
			in_SimpleALUResult,
			in_SimpleALUTargetRegister,
			in_StoredValue,
			in_CPSR,
			in_SPSR,
			in_IfChangeState,
			in_ChangeStateAction,
			in_MEMStoreDelayBranchTarget,
			in_MEMDelayBranch,
			in_MemAccessUserBankRegister2MEM,
			in_MEMHalfWordTransferType2MEM,
			in_SWPByteOrWord2MEM,
			//signal come from alu that origin come from decoder
			in_MEMType,
			in_MEMTargetRegister,
			in_SimpleMEMType,
			in_SimpleMEMTargetRegister,
			in_MEMPSRType,
			in_IsLoadToPC,
			//forwarding
			out_MEMWriteEnable,
			out_MEMWriteResult,
			out_MEMTargetRegister,
			out_SimpleMEMResult,
			out_SimpleMEMTargetRegister,
			out_MEMPSRType2WB,
			out_CPSR2WB,
			out_SPSR2WB,
			//this is also goto register
			out_IfChangeState,
			out_ChangeStateAction,
			out_MemAccessUserBankRegister2WB,
			//the first and third write bus
			out_WriteBus,
			out_WriteRegisterEnable,
			out_WriteRegisterNumber,
			out_ThirdWriteBus,
			out_ThirdWriteRegisterEnable,
			out_ThirdWriteRegisterNumber,
			out_CPSR2PSR,
			out_CPSRWriteEnable,
			out_SPSR2PSR,
			out_SPSRWriteEnable,
			//can MEM go?
			out_MEMOwnCanGo,
			in_EXECanGo,
			in_WBCanGo,
			//signal relate to load/store
			out_MEMAccessAddress,
			out_MEMAccessRequest,
			out_MEMAccessRW,
			out_MEMAccessBW,
			out_MEMAccessHalfWordTransfer,
			out_MEMAccessHalfWordType,
			in_DataCacheWait,
			in_DataBus,
			out_DataBus,
			//signal relate to change pc
			out_MEMChangePC,
			out_MEMNewPC,
			//other signal
			clock,
			reset
			);

////////////////////////////////////////////
//	input and output				//
////////////////////////////////////////////
input						in_ALUValid;
input		[`WordWidth-1:0]		in_ALUWriteBus;
input		[`Def_RegisterSelectWidth-1:0]	in_ALUTargetRegister;
input		[`Def_RegisterSelectWidth-1:0]	in_SimpleALUTargetRegister;
input		[`WordWidth-1:0]		in_StoredValue;
input		[`WordWidth-1:0]		in_CPSR,
						in_SPSR;
input						in_IfChangeState;
input		[4:0]				in_ChangeStateAction;
input						in_MEMStoreDelayBranchTarget,in_MEMDelayBranch;
input						in_MemAccessUserBankRegister2MEM;
input		[1:0]				in_MEMHalfWordTransferType2MEM;
input						in_SWPByteOrWord2MEM;


input		[`WordWidth-1:0]				in_SimpleALUResult;

//signal come from alu that origin come from decoder
input	[`ByteWidth-1:0]		in_MEMType;
input	[`Def_RegisterSelectWidth-1:0]	in_MEMTargetRegister;
input	[`ByteWidth-1:0]			in_SimpleMEMType;
input	[`Def_RegisterSelectWidth-1:0]			in_SimpleMEMTargetRegister;
input	[`ByteWidth-1:0]		in_MEMPSRType;
input					in_IsLoadToPC;

output					out_MEMWriteEnable;
output	[`WordWidth-1:0]		out_MEMWriteResult;
output	[`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister;
output	[`WordWidth-1:0]				out_SimpleMEMResult;
output	[`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister;
output	[`ByteWidth-1:0]		out_MEMPSRType2WB;
output	[`WordWidth-1:0]		out_CPSR2WB,out_SPSR2WB;
output					out_IfChangeState;
output	[4:0]				out_ChangeStateAction;
output					out_MemAccessUserBankRegister2WB;

output					out_MEMOwnCanGo;
input						in_EXECanGo;
input						in_WBCanGo;

reg		[`WordWidth-1:0]		out_MEMWriteResult;
reg		[`Def_RegisterSelectWidth-1:0]	out_MEMTargetRegister;
reg		[`WordWidth-1:0]		out_SimpleMEMResult;
reg		[`Def_RegisterSelectWidth-1:0]	out_SimpleMEMTargetRegister;
reg	[`ByteWidth-1:0]			out_MEMPSRType2WB;
reg	[`WordWidth-1:0]			out_CPSR2WB,out_SPSR2WB;

reg						out_MEMWriteEnable;
reg						out_MEMOwnCanGo;

//signal relate to load/store
output		[`AddressBusWidth-1:0]	out_MEMAccessAddress;
output					out_MEMAccessRequest,
					out_MEMAccessRW,
					out_MEMAccessBW;
					
output					out_MEMAccessHalfWordTransfer;
output		[1:0]			out_MEMAccessHalfWordType;

reg		[`AddressBusWidth-1:0]	out_MEMAccessAddress;
reg					out_MEMAccessRequest,
					out_MEMAccessRW,
					out_MEMAccessBW;

reg					out_MEMAccessHalfWordTransfer;
reg		[1:0]			out_MEMAccessHalfWordType;


input					in_DataCacheWait;

input	[`WordWidth-1:0]		in_DataBus;
output	[`WordWidth-1:0]		out_DataBus;

reg					CanOutputToDataBus;
reg		[`WordWidth-1:0]	tmp_DataBus;

//the first and third write bus
output	[`WordWidth-1:0]	out_WriteBus;
output				out_WriteRegisterEnable;
output	[`Def_RegisterSelectWidth-1:0]	out_WriteRegisterNumber;
output	[`WordWidth-1:0] out_ThirdWriteBus;
output				out_ThirdWriteRegisterEnable;
output	[`Def_RegisterSelectWidth-1:0]	out_ThirdWriteRegisterNumber;
output					out_CPSRWriteEnable;
output	[`WordWidth-1:0]		out_CPSR2PSR;
output					out_SPSRWriteEnable;
output	[`WordWidth-1:0]		out_SPSR2PSR;

//signal relate to change pc
output					out_MEMChangePC;
output	[`AddressBusWidth-1:0]		out_MEMNewPC;

reg		[`WordWidth-1:0]	out_WriteBus;
reg					out_WriteRegisterEnable;
reg		[`Def_RegisterSelectWidth-1:0]	out_WriteRegisterNumber;

reg		[`WordWidth-1:0] 	out_ThirdWriteBus;
reg					out_ThirdWriteRegisterEnable;
reg		[`Def_RegisterSelectWidth-1:0]	out_ThirdWriteRegisterNumber;

reg					out_CPSRWriteEnable;
reg	[`WordWidth-1:0]		out_CPSR2PSR;
reg					out_SPSRWriteEnable;
reg	[`WordWidth-1:0]		out_SPSR2PSR;

reg					out_MEMChangePC;
reg	[`AddressBusWidth-1:0]		out_MEMNewPC;


input		clock,reset;

////////////////////////////////////////////
//	register of pipeline			//
////////////////////////////////////////////
reg					Valid;
reg	[`ByteWidth-1:0]		MEMType,SimpleMEMType;
reg	[`WordWidth-1:0]		ALUResult,SimpleALUResult;
reg	[`Def_RegisterSelectWidth-1:0]	MEMTargetRegister,SimpleMEMTargetRegister;
reg	[`WordWidth-1:0]		StoredValue;
reg	[`ByteWidth-1:0]		MEMPSRType;
reg	[`WordWidth-1:0]		CPSR,SPSR;
reg					IsLoadToPC;
reg					IfChangeState;
reg	[4:0]				ChangeStateAction;
reg					MEMStoreDelayBranchTarget,MEMDelayBranch;
reg	[`WordWidth-1:0]		DelayBranchTarget;
reg					MemAccessUserBankRegister2MEM;
reg	[1:0]				MEMHalfWordTransferType2MEM;
reg					SWPByteOrWord2MEM;
reg					swpstate;

reg					Next_Valid;
reg	[`ByteWidth-1:0]		Next_MEMType,Next_SimpleMEMType;
reg	[`WordWidth-1:0]		Next_ALUResult,Next_SimpleALUResult;
reg	[`Def_RegisterSelectWidth-1:0]	Next_MEMTargetRegister,Next_SimpleMEMTargetRegister;
reg	[`WordWidth-1:0]		Next_StoredValue;
reg	[`ByteWidth-1:0]		Next_MEMPSRType;
reg	[`WordWidth-1:0]		Next_CPSR,Next_SPSR;
reg					Next_IsLoadToPC;
reg					Next_IfChangeState;
reg	[4:0]				Next_ChangeStateAction;
reg					Next_MEMStoreDelayBranchTarget,Next_MEMDelayBranch;
reg	[`WordWidth-1:0]		Next_DelayBranchTarget;
reg					Next_MemAccessUserBankRegister2MEM;
reg	[1:0]				Next_MEMHalfWordTransferType2MEM;
reg					Next_SWPByteOrWord2MEM;
reg					Next_swpstate;

always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		Valid=1'b0;
		MEMType=`MEMType_Null;
		SimpleMEMType=`MEMType_Null;
		ALUResult=`WordZero;
		SimpleALUResult=`WordZero;
		MEMTargetRegister=`Def_RegisterSelectZero;
		SimpleMEMTargetRegister=`Def_RegisterSelectZero;
		StoredValue=`WordZero;
		MEMPSRType=`MEMPSRType_Null;
		CPSR=`WordZero;
		SPSR=`WordZero;
		IsLoadToPC=1'b0;
		IfChangeState=1'b0;
		ChangeStateAction=5'b00000;
		
		MEMStoreDelayBranchTarget=1'b0;
		MEMDelayBranch=1'b0;
		DelayBranchTarget=`WordZero;
		
		MemAccessUserBankRegister2MEM=1'b0;

		MEMHalfWordTransferType2MEM=2'b00;
		
		SWPByteOrWord2MEM=1'b0;
		
		swpstate=1'b0;
	end
	else
	begin
		Valid=Next_Valid;
		MEMType=Next_MEMType;
		SimpleMEMType=Next_SimpleMEMType;
		ALUResult=Next_ALUResult;
		SimpleALUResult=Next_SimpleALUResult;
		MEMTargetRegister=Next_MEMTargetRegister;
		SimpleMEMTargetRegister=Next_SimpleMEMTargetRegister;
		StoredValue=Next_StoredValue;
		MEMPSRType=Next_MEMPSRType;
		CPSR=Next_CPSR;
		SPSR=Next_SPSR;
		IsLoadToPC=Next_IsLoadToPC;
		IfChangeState=Next_IfChangeState;
		ChangeStateAction=Next_ChangeStateAction;

		MEMStoreDelayBranchTarget=Next_MEMStoreDelayBranchTarget;
		MEMDelayBranch=Next_MEMDelayBranch;
		DelayBranchTarget=Next_DelayBranchTarget;
		
		MemAccessUserBankRegister2MEM=Next_MemAccessUserBankRegister2MEM;
		
		MEMHalfWordTransferType2MEM=Next_MEMHalfWordTransferType2MEM;

		SWPByteOrWord2MEM=Next_SWPByteOrWord2MEM;
		
		swpstate=Next_swpstate;
	end
end


always @(MEMType or
		SimpleMEMType or
		ALUResult or
		SimpleALUResult or
		MEMTargetRegister or
		SimpleMEMTargetRegister or
		StoredValue	or
		MEMPSRType	or
		CPSR	or
		SPSR	or
		Valid	or
		IsLoadToPC	or
		IfChangeState	or
		ChangeStateAction	or
		MEMStoreDelayBranchTarget	or
		MEMDelayBranch	or
		MemAccessUserBankRegister2MEM	or
		MEMHalfWordTransferType2MEM	or
		SWPByteOrWord2MEM	or
		in_ALUWriteBus or
		in_SimpleALUResult or
		in_MEMType or
		in_MEMTargetRegister or
		in_SimpleMEMType or
		in_SimpleMEMTargetRegister or
		in_EXECanGo or
		in_ALUValid or
		in_StoredValue	or
		in_MEMPSRType	or
		in_CPSR	or
		in_SPSR	or
		out_MEMOwnCanGo	or
		in_IsLoadToPC	or
		in_IfChangeState	or
		in_ChangeStateAction	or
		in_MEMStoreDelayBranchTarget	or
		in_MEMDelayBranch	or
		in_MemAccessUserBankRegister2MEM	or
		out_MEMChangePC	or
		in_WBCanGo
		)
begin
	if(in_WBCanGo==1'b1)
	begin
		if(out_MEMOwnCanGo==1'b1)
		begin
			if(in_ALUValid==1'b1 && out_MEMChangePC==1'b0)
			begin
				//valid alu and the current mem operation do not write pc
				Next_Valid=1'b1;
				Next_MEMType=in_MEMType;
				Next_SimpleMEMType=in_SimpleMEMType;
				Next_ALUResult=in_ALUWriteBus;
				Next_SimpleALUResult=in_SimpleALUResult;
				Next_MEMTargetRegister=in_MEMTargetRegister;
				Next_SimpleMEMTargetRegister=in_SimpleMEMTargetRegister;
				Next_StoredValue=in_StoredValue;
				Next_MEMPSRType=in_MEMPSRType;
				Next_CPSR=in_CPSR;
				Next_SPSR=in_SPSR;
				Next_IsLoadToPC=in_IsLoadToPC;
				Next_IfChangeState=in_IfChangeState;
				Next_ChangeStateAction=in_ChangeStateAction;
				Next_MEMStoreDelayBranchTarget=in_MEMStoreDelayBranchTarget;
				Next_MEMDelayBranch=in_MEMDelayBranch;
				Next_MemAccessUserBankRegister2MEM=in_MemAccessUserBankRegister2MEM;
				Next_MEMHalfWordTransferType2MEM=in_MEMHalfWordTransferType2MEM;
				Next_SWPByteOrWord2MEM=in_SWPByteOrWord2MEM;
			end
			else
			begin
				//invalid alu ,means a blank in pipeline
				//such as that cause by a long run multipler that have not finished
				//so make a blank in pipeline mem stage
				Next_Valid=1'b0;
				Next_MEMType=`MEMType_Null;
				Next_SimpleMEMType=`MEMType_Null;
				Next_ALUResult=`WordZero;
				Next_SimpleALUResult=`WordZero;
				Next_MEMTargetRegister=`Def_LinkRegister;
				Next_SimpleMEMTargetRegister=`Def_LinkRegister;
				Next_StoredValue=`WordZero;
				Next_MEMPSRType=`MEMPSRType_Null;
				Next_CPSR=`WordZero;
				Next_SPSR=`WordZero;
				Next_IsLoadToPC=1'b0;
				Next_IfChangeState=1'b0;
				Next_ChangeStateAction=5'b00000;
				Next_MEMStoreDelayBranchTarget=1'b0;
				Next_MEMDelayBranch=1'b0;
				Next_MemAccessUserBankRegister2MEM=1'b0;
				Next_MEMHalfWordTransferType2MEM=2'b00;
				Next_SWPByteOrWord2MEM=1'b0;
			end
		end
		else
		begin
			//mem can not go 
			//save current value of register that come from outside
			//all state register that relate to memory access will not be write here
			Next_Valid=Valid;
			Next_MEMType=MEMType;
			Next_SimpleMEMType=SimpleMEMType;
			Next_ALUResult=ALUResult;
			Next_SimpleALUResult=SimpleALUResult;
			Next_MEMTargetRegister=MEMTargetRegister;
			Next_SimpleMEMTargetRegister=SimpleMEMTargetRegister;
			Next_StoredValue=StoredValue;
			Next_MEMPSRType=MEMPSRType;
			Next_CPSR=CPSR;
			Next_SPSR=SPSR;
			Next_IsLoadToPC=IsLoadToPC;
			Next_IfChangeState=IfChangeState;
			Next_ChangeStateAction=ChangeStateAction;
			Next_MEMStoreDelayBranchTarget=MEMStoreDelayBranchTarget;
			Next_MEMDelayBranch=MEMDelayBranch;
			Next_MemAccessUserBankRegister2MEM=MemAccessUserBankRegister2MEM;
			Next_MEMHalfWordTransferType2MEM=MEMHalfWordTransferType2MEM;
			Next_SWPByteOrWord2MEM=SWPByteOrWord2MEM;
		end
	end
	else
	begin
		//mem can not go 
		//save current value of register that come from outside
		//all state register that relate to memory access will not be write here
		Next_Valid=Valid;
		Next_MEMType=MEMType;
		Next_SimpleMEMType=SimpleMEMType;
		Next_ALUResult=ALUResult;
		Next_SimpleALUResult=SimpleALUResult;
		Next_MEMTargetRegister=MEMTargetRegister;
		Next_SimpleMEMTargetRegister=SimpleMEMTargetRegister;
		Next_StoredValue=StoredValue;
		Next_MEMPSRType=MEMPSRType;
		Next_CPSR=CPSR;
		Next_SPSR=SPSR;
		Next_IsLoadToPC=IsLoadToPC;
		Next_IfChangeState=IfChangeState;
		Next_ChangeStateAction=ChangeStateAction;
		Next_MEMStoreDelayBranchTarget=MEMStoreDelayBranchTarget;
		Next_MEMDelayBranch=MEMDelayBranch;
		Next_MemAccessUserBankRegister2MEM=MemAccessUserBankRegister2MEM;
		Next_MEMHalfWordTransferType2MEM=MEMHalfWordTransferType2MEM;
		Next_SWPByteOrWord2MEM=SWPByteOrWord2MEM;
	end
end

//simple thread
always @(SimpleMEMType or
		ALUResult or
		SimpleALUResult or
		SimpleMEMTargetRegister	or
		out_MEMOwnCanGo	or
		out_SimpleMEMResult or
		out_SimpleMEMTargetRegister
)
begin
	case (SimpleMEMType)
	`MEMType_MovMain:
		out_SimpleMEMResult=ALUResult;
	`MEMType_MovSimple:
		out_SimpleMEMResult=SimpleALUResult;
	default:
		out_SimpleMEMResult=`WordZero;
	endcase
	//simple mem target register
	out_SimpleMEMTargetRegister=SimpleMEMTargetRegister;
	//write back register 
	if(out_MEMOwnCanGo==1'b1)
	begin
		out_ThirdWriteBus=out_SimpleMEMResult;
		out_ThirdWriteRegisterEnable=1'b1;
		out_ThirdWriteRegisterNumber=out_SimpleMEMTargetRegister;
	end
	else
	begin
		out_ThirdWriteBus=out_SimpleMEMResult;
		out_ThirdWriteRegisterEnable=1'b0;
		out_ThirdWriteRegisterNumber=out_SimpleMEMTargetRegister;
	end
end

//main thread
always @(MEMType or
		ALUResult or
		SimpleALUResult or
		MEMTargetRegister or
		in_DataCacheWait or
		in_DataBus	or
		StoredValue	or
		MEMStoreDelayBranchTarget	or
		MEMDelayBranch	or
		DelayBranchTarget	or
		SWPByteOrWord2MEM	or
		swpstate
	)
begin
	//only use by load/store
	out_MEMAccessAddress=`AddressBusZero;
	out_MEMAccessRequest=1'b0;
	out_MEMAccessRW=1'b1;
	out_MEMAccessBW=1'b0;
	tmp_DataBus=`WordDontCare;
	//can not output to data bus
	//only store can make it be 1
	CanOutputToDataBus=1'b0;
	
	//normal case do not use half word transfer
	out_MEMAccessHalfWordTransfer=1'b0;
	out_MEMAccessHalfWordType=MEMHalfWordTransferType2MEM;
	
	Next_swpstate=1'b0;
	
	//delay branch target
	if(MEMDelayBranch==1'b1)
		Next_DelayBranchTarget=`WordZero;
	else
		Next_DelayBranchTarget=DelayBranchTarget;

	case (MEMType)
	`MEMType_MovMain:
	begin
		out_MEMWriteEnable=1'b1;
		out_MEMWriteResult=ALUResult;
		out_MEMOwnCanGo=1'b1;
		if(MEMTargetRegister!=`Def_LinkRegister)
		begin
			out_WriteBus=ALUResult;
			out_WriteRegisterEnable=1'b1;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
		else
		begin
			out_WriteBus=ALUResult;
			out_WriteRegisterEnable=1'b0;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
	end
	`MEMType_MovSimple:
	begin
		out_MEMWriteEnable=1'b1;
		out_MEMWriteResult=SimpleALUResult;
		out_MEMOwnCanGo=1'b1;
		if(MEMTargetRegister!=`Def_LinkRegister)
		begin
			out_WriteBus=SimpleALUResult;
			out_WriteRegisterEnable=1'b1;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
		else
		begin
			out_WriteBus=SimpleALUResult;
			out_WriteRegisterEnable=1'b0;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
	end
	`MEMType_LoadMainWord,`MEMType_LoadMainByte,`MEMType_LoadSimpleWord,`MEMType_LoadSimpleByte,`MEMType_LoadMainHalfWord,`MEMType_LoadSimpleHalfWord:
	begin
			if(MEMType==`MEMType_LoadMainWord || MEMType==`MEMType_LoadMainByte || MEMType==`MEMType_LoadMainHalfWord)
			begin//load main
				out_MEMAccessAddress=ALUResult;
			end
			else//load simple
			begin
				out_MEMAccessAddress=SimpleALUResult;
			end
			out_MEMAccessRequest=1'b1;
			out_MEMAccessRW=1'b1;
			if(MEMType==`MEMType_LoadMainHalfWord || MEMType==`MEMType_LoadSimpleHalfWord)
			begin//half word
				out_MEMAccessHalfWordTransfer=1'b1;
			end
			else if(MEMType==`MEMType_LoadMainByte || MEMType==`MEMType_LoadSimpleByte)
			begin//byte
				out_MEMAccessBW=1'b1;
			end
			else//load word even if in load half word mode
			begin
				out_MEMAccessBW=1'b0;
			end
			tmp_DataBus=`WordDontCare;

			if(in_DataCacheWait==1'b1)
			begin
				out_MEMWriteEnable=1'b0;
				out_MEMWriteResult=`WordZero;
				out_MEMOwnCanGo=1'b0;
				//nothing writen to register
				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
			end
			else
			begin
				out_MEMWriteEnable=1'b1;
				out_MEMWriteResult=in_DataBus;
				out_MEMOwnCanGo=1'b1;
				//nothing writen to register
				out_WriteBus=in_DataBus;
				out_WriteRegisterEnable=1'b1;
				out_WriteRegisterNumber=MEMTargetRegister;
				if(MEMStoreDelayBranchTarget==1'b1)
					Next_DelayBranchTarget=in_DataBus;
			end
	end
	`MEMType_StoreMainWord,`MEMType_StoreMainByte,`MEMType_StoreSimpleWord,`MEMType_StoreSimpleByte,`MEMType_StoreMainHalfWord,`MEMType_StoreSimpleHalfWord:
	begin
			//send out address
			if(MEMType==`MEMType_StoreMainWord || MEMType==`MEMType_StoreMainByte ||  MEMType==`MEMType_StoreMainHalfWord)
			begin//Store main
				out_MEMAccessAddress=ALUResult;
			end
			else//Store simple
			begin
				out_MEMAccessAddress=SimpleALUResult;
			end
			out_MEMAccessRequest=1'b1;
			out_MEMAccessRW=1'b0;
			if(MEMType==`MEMType_StoreMainHalfWord || MEMType==`MEMType_StoreSimpleHalfWord)
			begin//half word
				out_MEMAccessHalfWordTransfer=1'b1;
			end
			else if(MEMType==`MEMType_StoreMainByte || MEMType==`MEMType_StoreSimpleByte)
			begin//byte
				out_MEMAccessBW=1'b1;
			end
			else//word
			begin
				out_MEMAccessBW=1'b0;
			end
			//only store can write to data cache bus
			CanOutputToDataBus=1'b1;
			tmp_DataBus=StoredValue;

			if(in_DataCacheWait==1'b1)
			begin
				out_MEMWriteEnable=1'b0;
				out_MEMWriteResult=`WordZero;
				out_MEMOwnCanGo=1'b0;

				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
			end
			else
			begin
				out_MEMWriteEnable=1'b1;
				out_MEMWriteResult=`WordZero;
				out_MEMOwnCanGo=1'b1;

				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
			end
	end
	`MEMType_SWP:
	begin
		if(swpstate==1'b0)
		begin
			//load first
			out_MEMAccessAddress=SimpleALUResult;
			out_MEMAccessRequest=1'b1;
			out_MEMAccessRW=1'b1;
			out_MEMAccessBW=SWPByteOrWord2MEM;
			tmp_DataBus=`WordDontCare;
			//can not output to data bus
			//only store can make it be 1
			CanOutputToDataBus=1'b0;
	
			//half word transfer with 2'b00 in out_MEMAccessHalfWordType means swp
			out_MEMAccessHalfWordTransfer=1'b1;
			out_MEMAccessHalfWordType=MEMHalfWordTransferType2MEM;
	
			out_MEMOwnCanGo=1'b0;
			if(in_DataCacheWait==1'b1)
			begin
				out_MEMWriteEnable=1'b0;
				out_MEMWriteResult=`WordZero;
				//nothing writen to register
				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
				Next_swpstate=1'b0;
			end
			else
			begin
				out_MEMWriteEnable=1'b1;
				out_MEMWriteResult=in_DataBus;
				//writen to register
				out_WriteBus=in_DataBus;
				out_WriteRegisterEnable=1'b1;
				out_WriteRegisterNumber=MEMTargetRegister;
				Next_swpstate=1'b1;
			end
			
		end
		else
		begin//then store
			//only use by load/store
			out_MEMAccessAddress=SimpleALUResult;
			out_MEMAccessRequest=1'b1;
			out_MEMAccessRW=1'b0;
			out_MEMAccessBW=SWPByteOrWord2MEM;
			tmp_DataBus=`WordDontCare;
			//can not output to data bus
			//only store can make it be 1
			CanOutputToDataBus=1'b0;
	
			//half word transfer with 2'b00 in out_MEMAccessHalfWordType means swp
			out_MEMAccessHalfWordTransfer=1'b1;
			out_MEMAccessHalfWordType=MEMHalfWordTransferType2MEM;
	
			//only store can write to data cache bus
			CanOutputToDataBus=1'b1;
			tmp_DataBus=StoredValue;

			if(in_DataCacheWait==1'b1)
			begin
				out_MEMWriteEnable=1'b0;
				out_MEMWriteResult=`WordZero;
				out_MEMOwnCanGo=1'b0;

				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
				
				Next_swpstate=1'b1;
			end
			else
			begin
				out_MEMWriteEnable=1'b1;
				out_MEMWriteResult=`WordZero;
				out_MEMOwnCanGo=1'b1;

				out_WriteBus=`WordZero;
				out_WriteRegisterEnable=1'b0;
				out_WriteRegisterNumber=MEMTargetRegister;
				
				Next_swpstate=1'b0;
			end
		end
	end
	`MEMType_BlankOp:
	begin
		out_MEMWriteEnable=1'b1;
		out_MEMWriteResult=`WordZero;
		out_MEMOwnCanGo=1'b1;
		out_WriteBus=ALUResult;
		out_WriteRegisterEnable=1'b0;
		out_WriteRegisterNumber=MEMTargetRegister;
	end
	default:
	begin
		out_MEMWriteEnable=1'b0;
		out_MEMWriteResult=`WordZero;
		out_MEMOwnCanGo=1'b1;
		if(MEMTargetRegister!=`Def_LinkRegister)
		begin
			out_WriteBus=ALUResult;
			out_WriteRegisterEnable=1'b0;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
		else
		begin
			out_WriteBus=ALUResult;
			out_WriteRegisterEnable=1'b0;
			out_WriteRegisterNumber=MEMTargetRegister;
		end
	end
	endcase
	out_MEMTargetRegister=MEMTargetRegister;
end

//you can not place assign of out_MEMWriteEnable here, because some times when mem can not go, it can still place valid value to next stage,such as in swp
//assign	out_MEMWriteEnable=((in_WBCanGo & out_MEMOwnCanGo)==1'b1)?Valid:1'b0;


//psr thread
always @(MEMPSRType or
	CPSR or
	SPSR
	)
begin
	out_MEMPSRType2WB=MEMPSRType;
	out_CPSR2WB=CPSR;
	out_SPSR2WB=SPSR;
	out_CPSR2PSR=CPSR;
	out_SPSR2PSR=SPSR;
	
	
	case (MEMPSRType)
	`MEMPSRType_WriteSPSR:
	begin
		out_CPSRWriteEnable=1'b0;
		out_SPSRWriteEnable=1'b1;
	end
	`MEMPSRType_SPSR2CPSR:
	begin
		out_CPSRWriteEnable=1'b1;
		out_SPSRWriteEnable=1'b0;
	end
	`MEMPSRType_WriteCPSR:
	begin
		out_CPSRWriteEnable=1'b1;
		out_SPSRWriteEnable=1'b0;
	end
	`MEMPSRType_WriteConditionCode:
	begin
		out_CPSRWriteEnable=1'b1;
		out_SPSRWriteEnable=1'b0;
	end
	`MEMPSRType_WriteBoth:
	begin
		out_CPSRWriteEnable=1'b1;
		out_SPSRWriteEnable=1'b1;
	end
	default:
	begin
		out_CPSRWriteEnable=1'b0;
		out_SPSRWriteEnable=1'b0;
	end
	endcase
end

//output to cache
assign	out_DataBus=tmp_DataBus;

assign	out_MemAccessUserBankRegister2WB=MemAccessUserBankRegister2MEM;
//the following two signal go to register file and psr registers
//so you can not modify them to use in LDM/STM
assign	out_IfChangeState=IfChangeState;
assign	out_ChangeStateAction=ChangeStateAction;

//can write pc?
always @(out_MEMWriteEnable	or
	IsLoadToPC		or
	out_MEMWriteResult	or
	MEMDelayBranch		or
	DelayBranchTarget
)
begin
	if(out_MEMWriteEnable==1'b1)
	begin
		if(IsLoadToPC==1'b1)
		begin
			//can write pc
			out_MEMChangePC=~in_DataCacheWait;
			out_MEMNewPC={out_MEMWriteResult[`WordWidth-1:2],out_CPSR2WB[`ThumbPos]&out_MEMWriteResult[1],1'b0};//half word align
		end
		else if(MEMDelayBranch==1'b1)
		begin
			//delay branch
			out_MEMChangePC=1'b1;
			out_MEMNewPC={DelayBranchTarget[`WordWidth-1:2],out_CPSR2WB[`ThumbPos]&DelayBranchTarget[1],1'b0};//half word align
		end
		else
		begin
			out_MEMChangePC=1'b0;
			out_MEMNewPC={out_MEMWriteResult[`WordWidth-1:2],out_CPSR2WB[`ThumbPos]&out_MEMWriteResult[1],1'b0};//half word align
		end
	end
	else
	begin
		out_MEMChangePC=1'b0;
		out_MEMNewPC={out_MEMWriteResult[`WordWidth-1:2],out_CPSR2WB[`ThumbPos]&out_MEMWriteResult[1],1'b0};//half word align
	end
end
endmodule