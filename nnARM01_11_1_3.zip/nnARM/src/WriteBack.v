module	WriteBack(//input from MEM to hold MEM result
		in_MEMWriteEnable,
		in_MainWriteEnable,
		in_MainWriteRegister,
		in_MainWriteResult,
		in_SimpleWriteEnable,
		in_SimpleWriteRegister,
		in_SimpleWriteResult,
		in_CPSR,
		in_CPSRWriteEnable,
		in_SPSR,
		in_SPSRWriteEnable,
		in_IfChangeState,
		in_ChangeStateAction,
		in_MemAccessUserBankRegister,
		//output to register
		out_IfChangeState,
		out_ChangeStateAction,
		out_MemAccessUserBankRegister,
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
		//can Write back go
		out_WBOwnCanGo,
		out_WBWriteEnable,
		clock,
		reset
);

input	clock,reset;

input						in_MEMWriteEnable;
input						in_MainWriteEnable;
input	[`Def_RegisterSelectWidth-1:0]		in_MainWriteRegister;
input	[`WordWidth-1:0]			in_MainWriteResult;

input						in_SimpleWriteEnable;
input	[`Def_RegisterSelectWidth-1:0]		in_SimpleWriteRegister;
input	[`WordWidth-1:0]			in_SimpleWriteResult;

input	[`WordWidth-1:0]			in_CPSR;
input						in_CPSRWriteEnable;
input	[`WordWidth-1:0]			in_SPSR;
input						in_SPSRWriteEnable;

input						in_IfChangeState;
input	[4:0]					in_ChangeStateAction;
input						in_MemAccessUserBankRegister;


output						out_IfChangeState;
output	[4:0]					out_ChangeStateAction;
output						out_MemAccessUserBankRegister;

output	[`WordWidth-1:0]			out_WriteBus;
output						out_WriteRegisterEnable;
output	[`Def_RegisterSelectWidth-1:0]		out_WriteRegisterNumber;

output	[`WordWidth-1:0]			out_ThirdWriteBus;
output						out_ThirdWriteRegisterEnable;
output	[`Def_RegisterSelectWidth-1:0]		out_ThirdWriteRegisterNumber;

output	[`WordWidth-1:0]			out_CPSR2PSR;
output						out_CPSRWriteEnable;

output	[`WordWidth-1:0]			out_SPSR2PSR;
output						out_SPSRWriteEnable;

output						out_WBOwnCanGo;
output						out_WBWriteEnable;

reg						IfChangeState;
reg	[4:0]					ChangeStateAction;
reg						MemAccessUserBankRegister;

reg	[`WordWidth-1:0]			WriteBus;
reg						WriteRegisterEnable;
reg	[`Def_RegisterSelectWidth-1:0]		WriteRegisterNumber;

reg	[`WordWidth-1:0]			ThirdWriteBus;
reg						ThirdWriteRegisterEnable;
reg	[`Def_RegisterSelectWidth-1:0]		ThirdWriteRegisterNumber;

reg	[`WordWidth-1:0]			CPSR2PSR;
reg						CPSRWriteEnable;

reg	[`WordWidth-1:0]			SPSR2PSR;
reg						SPSRWriteEnable;

reg						WBWriteEnable;


reg						Next_IfChangeState;
reg	[4:0]					Next_ChangeStateAction;
reg						Next_MemAccessUserBankRegister;

reg	[`WordWidth-1:0]			Next_WriteBus;
reg						Next_WriteRegisterEnable;
reg	[`Def_RegisterSelectWidth-1:0]		Next_WriteRegisterNumber;

reg	[`WordWidth-1:0]			Next_ThirdWriteBus;
reg						Next_ThirdWriteRegisterEnable;
reg	[`Def_RegisterSelectWidth-1:0]		Next_ThirdWriteRegisterNumber;

reg	[`WordWidth-1:0]			Next_CPSR2PSR;
reg						Next_CPSRWriteEnable;

reg	[`WordWidth-1:0]			Next_SPSR2PSR;
reg						Next_SPSRWriteEnable;

reg						Next_WBWriteEnable;

always	@(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		IfChangeState=1'b0;
		ChangeStateAction=5'b00000;
		MemAccessUserBankRegister=1'b0;

		WriteBus=`WordZero;
		WriteRegisterEnable=1'b0;
		WriteRegisterNumber=`Def_RegisterSelectZero;
		
		ThirdWriteBus=`WordZero;
		ThirdWriteRegisterEnable=1'b0;
		ThirdWriteRegisterNumber=`Def_RegisterSelectZero;
		
		CPSR2PSR=`WordZero;
		CPSRWriteEnable=1'b0;
		
		SPSR2PSR=`WordZero;
		SPSRWriteEnable=1'b0;
		
		WBWriteEnable=1'b0;
	end
	else
	begin
		IfChangeState=Next_IfChangeState;
		ChangeStateAction=Next_ChangeStateAction;
		MemAccessUserBankRegister=Next_MemAccessUserBankRegister;

		WriteBus=Next_WriteBus;
		WriteRegisterEnable=Next_WriteRegisterEnable;
		WriteRegisterNumber=Next_WriteRegisterNumber;
		
		ThirdWriteBus=Next_ThirdWriteBus;
		ThirdWriteRegisterEnable=Next_ThirdWriteRegisterEnable;
		ThirdWriteRegisterNumber=Next_ThirdWriteRegisterNumber;
		
		CPSR2PSR=Next_CPSR2PSR;
		CPSRWriteEnable=Next_CPSRWriteEnable;
		
		SPSR2PSR=Next_SPSR2PSR;
		SPSRWriteEnable=Next_SPSRWriteEnable;

		WBWriteEnable=Next_WBWriteEnable;
	end
end


always	@(in_MEMWriteEnable	or
	in_IfChangeState	or
	in_ChangeStateAction	or
	in_MemAccessUserBankRegister	or
	in_MainWriteResult		or
	in_MainWriteEnable	or
	in_MainWriteRegister	or
	in_SimpleWriteResult	or
	in_SimpleWriteEnable	or
	in_SimpleWriteRegister	or
	in_CPSR		or
	in_CPSRWriteEnable	or
	in_SPSR		or
	in_SPSRWriteEnable	
)
begin
	if(out_WBOwnCanGo==1'b1)
	begin
		if(in_MEMWriteEnable==1'b1)
		begin
			Next_IfChangeState=in_IfChangeState;
			Next_ChangeStateAction=in_ChangeStateAction;
			Next_MemAccessUserBankRegister=in_MemAccessUserBankRegister;
		
			Next_WriteBus=in_MainWriteResult;
			Next_WriteRegisterEnable=in_MainWriteEnable;
			Next_WriteRegisterNumber=in_MainWriteRegister;
		
			Next_ThirdWriteBus=in_SimpleWriteResult;
			Next_ThirdWriteRegisterEnable=in_SimpleWriteEnable;
			Next_ThirdWriteRegisterNumber=in_SimpleWriteRegister;
			
			Next_CPSR2PSR=in_CPSR;
			Next_CPSRWriteEnable=in_CPSRWriteEnable;
			
			Next_SPSR2PSR=in_SPSR;
			Next_SPSRWriteEnable=in_SPSRWriteEnable;
			
			Next_WBWriteEnable=1'b1;
		end
		else
		begin
			Next_IfChangeState=1'b0;
			Next_ChangeStateAction=5'b00000;
			Next_MemAccessUserBankRegister=1'b0;
		
			Next_WriteBus=`WordZero;
			Next_WriteRegisterEnable=1'b0;
			Next_WriteRegisterNumber=`Def_LinkRegister;
		
			Next_ThirdWriteBus=`WordZero;
			Next_ThirdWriteRegisterEnable=1'b0;
			Next_ThirdWriteRegisterNumber=`Def_LinkRegister;
		
			Next_CPSR2PSR=`WordZero;
			Next_CPSRWriteEnable=1'b0;
		
			Next_SPSR2PSR=`WordZero;
			Next_SPSRWriteEnable=1'b0;

			Next_WBWriteEnable=1'b0;
		end
	end
	else
	begin
		//write back can not go
		//preserve origin value
		Next_IfChangeState=IfChangeState;
		Next_ChangeStateAction=ChangeStateAction;
		Next_MemAccessUserBankRegister=MemAccessUserBankRegister;
		
		Next_WriteBus=WriteBus;
		Next_WriteRegisterEnable=WriteRegisterEnable;
		Next_WriteRegisterNumber=WriteRegisterNumber;
	
		Next_ThirdWriteBus=ThirdWriteBus;
		Next_ThirdWriteRegisterEnable=ThirdWriteRegisterEnable;
		Next_ThirdWriteRegisterNumber=ThirdWriteRegisterNumber;
		
		Next_CPSR2PSR=CPSR2PSR;
		Next_CPSRWriteEnable=CPSRWriteEnable;
		
		Next_SPSR2PSR=SPSR2PSR;
		Next_SPSRWriteEnable=SPSRWriteEnable;

		Next_WBWriteEnable=WBWriteEnable;
	end
end

assign	out_WBOwnCanGo=1'b1;

assign	out_IfChangeState=IfChangeState;
assign	out_ChangeStateAction=ChangeStateAction;
assign	out_MemAccessUserBankRegister=MemAccessUserBankRegister;
assign	out_WriteBus=WriteBus;
assign	out_WriteRegisterEnable=WriteRegisterEnable;
assign	out_WriteRegisterNumber=WriteRegisterNumber;
assign	out_ThirdWriteBus=ThirdWriteBus;
assign	out_ThirdWriteRegisterEnable=ThirdWriteRegisterEnable;
assign	out_ThirdWriteRegisterNumber=ThirdWriteRegisterNumber;
assign	out_CPSR2PSR=CPSR2PSR;
assign	out_CPSRWriteEnable=CPSRWriteEnable;
assign	out_SPSR2PSR=SPSR2PSR;
assign	out_SPSRWriteEnable=SPSRWriteEnable;
assign	out_WBWriteEnable=WBWriteEnable;
endmodule