//this register file support 4 reads and 3 write
module RegisterFile(	//change of state
			in_IfChangeState,	//this port means access other bank of register, only SWI or FIQ or IRQ or UND or ABT use it
			in_MemAccessUserBankRegister2WB,	//access user bank, use only by LDM/STM
			in_ChangeStateAction,	//which  bank of register to access
			//SWI or FIQ or IRQ or UND or ABT  only use r14 as link register
			//LDM/STM use user bank only
			//other read port
			in_LeftReadEnable,
			in_LeftReadRegisterNumber,
			out_LeftReadBus,
			in_RightReadEnable,
			in_RightReadRegisterNumber,
			out_RightReadBus,
			in_ThirdReadEnable,
			in_ThirdReadRegisterNumber,
			out_ThirdReadBus,
			in_FourthReadEnable,
			in_FourthReadRegisterNumber,
			out_FourthReadBus,
			in_WriteEnable,
			in_WriteRegisterNumber,
			in_WriteBus,
			in_SecondWriteEnable,
			in_SecondWriteRegisterNumber,
			in_SecondWriteBus,
			in_ThirdWriteEnable,
			in_ThirdWriteRegisterNumber,
			in_ThirdWriteBus,
			//the processor mode
			in_ProcessorMode,
			clock,
			reset
);

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//		port declaration		//
//////////////////////////////////////////////////
//////////////////////////////////////////////////
input		in_IfChangeState;
input		in_MemAccessUserBankRegister2WB;
input	[4:0]	in_ChangeStateAction;

input in_LeftReadEnable,in_RightReadEnable,in_ThirdReadEnable,in_FourthReadEnable,in_WriteEnable,in_SecondWriteEnable,in_ThirdWriteEnable;
input [`Def_RegisterSelectWidth-1:0] in_LeftReadRegisterNumber,in_RightReadRegisterNumber,in_ThirdReadRegisterNumber,in_FourthReadRegisterNumber,in_WriteRegisterNumber,in_SecondWriteRegisterNumber,in_ThirdWriteRegisterNumber;

output [`WordWidth-1:0] out_LeftReadBus,out_RightReadBus,out_ThirdReadBus,out_FourthReadBus;
reg [`WordWidth-1:0] out_LeftReadBus,out_RightReadBus,out_ThirdReadBus,out_FourthReadBus;
input [`WordWidth-1:0] in_WriteBus,in_SecondWriteBus,in_ThirdWriteBus;

input [4:0] in_ProcessorMode;

input clock,reset;

//////////////////////////////////////////////////
//////////////////////////////////////////////////
//		memory for registers		//
//////////////////////////////////////////////////
//////////////////////////////////////////////////
//16 general register
reg [`WordWidth-1:0]  Registers0;
reg [`WordWidth-1:0]  Registers1;
reg [`WordWidth-1:0]  Registers2;
reg [`WordWidth-1:0]  Registers3;
reg [`WordWidth-1:0]  Registers4;
reg [`WordWidth-1:0]  Registers5;
reg [`WordWidth-1:0]  Registers6;
reg [`WordWidth-1:0]  Registers7;
reg [`WordWidth-1:0]  Registers8;
reg [`WordWidth-1:0]  Registers9;
reg [`WordWidth-1:0]  Registers10;
reg [`WordWidth-1:0]  Registers11;
reg [`WordWidth-1:0]  Registers12;
reg [`WordWidth-1:0]  Registers13;
reg [`WordWidth-1:0]  Registers14;
reg [`WordWidth-1:0]  Registers15;

//7 reg for FIQ mode
reg [`WordWidth-1:0]  Registers8_FIQ;
reg [`WordWidth-1:0]  Registers9_FIQ;
reg [`WordWidth-1:0]  Registers10_FIQ;
reg [`WordWidth-1:0]  Registers11_FIQ;
reg [`WordWidth-1:0]  Registers12_FIQ;
reg [`WordWidth-1:0]  Registers13_FIQ;
reg [`WordWidth-1:0]  Registers14_FIQ;

//2 reg for supervisor mode
reg [`WordWidth-1:0]  Registers13_SVC;
reg [`WordWidth-1:0]  Registers14_SVC;

//2 reg for abort mode
reg [`WordWidth-1:0]  Registers13_ABT;
reg [`WordWidth-1:0]  Registers14_ABT;

//2 reg for IRQ mode
reg [`WordWidth-1:0]  Registers13_IRQ;
reg [`WordWidth-1:0]  Registers14_IRQ;

//2 reg undefined instruction mode
reg [`WordWidth-1:0]  Registers13_UND;
reg [`WordWidth-1:0]  Registers14_UND;

//Def_LocalForwardRegister
reg [`WordWidth-1:0]  LocalForwardRegister;


integer ssycnt;

//left read
always @(Registers0 or
	Registers1 or
	Registers2 or
	Registers3 or
	Registers4 or
	Registers5 or
	Registers6 or
	Registers7 or
	Registers8 or
	Registers9 or
	Registers10 or
	Registers11 or
	Registers12 or
	Registers13 or
	Registers14 or
	Registers15 or
	Registers8_FIQ or
	Registers9_FIQ or
	Registers10_FIQ or
	Registers11_FIQ or
	Registers12_FIQ or
	Registers13_FIQ or
	Registers14_FIQ or
	Registers13_SVC or
	Registers14_SVC or
	Registers13_ABT or
	Registers14_ABT or
	Registers13_IRQ or
	Registers14_IRQ or
	Registers13_UND or
	Registers14_UND or
	LocalForwardRegister or
	in_ProcessorMode or
	in_LeftReadEnable or
	in_LeftReadRegisterNumber	or
	in_IfChangeState	or
	in_ChangeStateAction	or
	in_MemAccessUserBankRegister2WB
)
begin
	if(in_LeftReadEnable==1'b1)
	begin
		case (in_LeftReadRegisterNumber)
		8'b0000_0000:
			out_LeftReadBus=Registers0;
		8'b0000_0001:
			out_LeftReadBus=Registers1;
		8'b0000_0010:
			out_LeftReadBus=Registers2;
		8'b0000_0011:
			out_LeftReadBus=Registers3;
		8'b0000_0100:
			out_LeftReadBus=Registers4;
		8'b0000_0101:
			out_LeftReadBus=Registers5;
		8'b0000_0110:
			out_LeftReadBus=Registers6;
		8'b0000_0111:
			out_LeftReadBus=Registers7;
		8'b0000_1000:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers8;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers8_FIQ;
			else
				out_LeftReadBus=Registers8;
		end
		8'b0000_1001:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers9;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers9_FIQ;
			else
				out_LeftReadBus=Registers9;
		end
		8'b0000_1010:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers10;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers10_FIQ;
			else
				out_LeftReadBus=Registers10;
		end
		8'b0000_1011:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers11;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers11_FIQ;
			else
				out_LeftReadBus=Registers11;
		end
		8'b0000_1100:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers12;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers12_FIQ;
			else
				out_LeftReadBus=Registers12;
		end
		8'b0000_1101:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_LeftReadBus=Registers13;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers13_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_LeftReadBus=Registers13_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_LeftReadBus=Registers13_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_LeftReadBus=Registers13_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_LeftReadBus=Registers13_UND;
			else//normal
				out_LeftReadBus=Registers13;
		end
		8'b0000_1110:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
				out_LeftReadBus=Registers14;
			else if(in_IfChangeState==1'b1)
			begin
				case(in_ChangeStateAction)
				`MODE_FIQ:
					out_LeftReadBus=Registers14_FIQ;
				`MODE_SVC:
					out_LeftReadBus=Registers14_SVC;
				`MODE_ABT:
					out_LeftReadBus=Registers14_ABT;
				`MODE_IRQ:
					out_LeftReadBus=Registers14_IRQ;
				`MODE_UND:
					out_LeftReadBus=Registers14_UND;
				default:
					out_LeftReadBus=Registers14;
				endcase
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_LeftReadBus=Registers14_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_LeftReadBus=Registers14_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_LeftReadBus=Registers14_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_LeftReadBus=Registers14_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_LeftReadBus=Registers14_UND;
			else//normal
				out_LeftReadBus=Registers14;
		end
		8'b0000_1111:
			out_LeftReadBus=Registers15;
		`Def_LocalForwardRegister:
			out_LeftReadBus=LocalForwardRegister;
		default:
			out_LeftReadBus=`WordZero;
		endcase
	end
	else
	begin
		out_LeftReadBus=`WordZero;
	end
end

//right read
always @(Registers0 or
	Registers1 or
	Registers2 or
	Registers3 or
	Registers4 or
	Registers5 or
	Registers6 or
	Registers7 or
	Registers8 or
	Registers9 or
	Registers10 or
	Registers11 or
	Registers12 or
	Registers13 or
	Registers14 or
	Registers15 or
	Registers8_FIQ or
	Registers9_FIQ or
	Registers10_FIQ or
	Registers11_FIQ or
	Registers12_FIQ or
	Registers13_FIQ or
	Registers14_FIQ or
	Registers13_SVC or
	Registers14_SVC or
	Registers13_ABT or
	Registers14_ABT or
	Registers13_IRQ or
	Registers14_IRQ or
	Registers13_UND or
	Registers14_UND or
	LocalForwardRegister or
	in_ProcessorMode or
	in_RightReadEnable or
	in_RightReadRegisterNumber	or
	in_IfChangeState	or
	in_ChangeStateAction	or
	in_MemAccessUserBankRegister2WB
)
begin
	if(in_RightReadEnable==1'b1)
	begin
		case (in_RightReadRegisterNumber)
		8'b0000_0000:
			out_RightReadBus=Registers0;
		8'b0000_0001:
			out_RightReadBus=Registers1;
		8'b0000_0010:
			out_RightReadBus=Registers2;
		8'b0000_0011:
			out_RightReadBus=Registers3;
		8'b0000_0100:
			out_RightReadBus=Registers4;
		8'b0000_0101:
			out_RightReadBus=Registers5;
		8'b0000_0110:
			out_RightReadBus=Registers6;
		8'b0000_0111:
			out_RightReadBus=Registers7;
		8'b0000_1000:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers8;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers8_FIQ;
			else
				out_RightReadBus=Registers8;
		end
		8'b0000_1001:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers9;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers9_FIQ;
			else
				out_RightReadBus=Registers9;
		end
		8'b0000_1010:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers10;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers10_FIQ;
			else
				out_RightReadBus=Registers10;
		end
		8'b0000_1011:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers11;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers11_FIQ;
			else
				out_RightReadBus=Registers11;
		end
		8'b0000_1100:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers12;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers12_FIQ;
			else
				out_RightReadBus=Registers12;
		end
		8'b0000_1101:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_RightReadBus=Registers13;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers13_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_RightReadBus=Registers13_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_RightReadBus=Registers13_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_RightReadBus=Registers13_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_RightReadBus=Registers13_UND;
			else//normal
				out_RightReadBus=Registers13;
		end
		8'b0000_1110:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
				out_RightReadBus=Registers14;
			if(in_IfChangeState==1'b1)
			begin
				case(in_ChangeStateAction)
				`MODE_FIQ:
					out_RightReadBus=Registers14_FIQ;
				`MODE_SVC:
					out_RightReadBus=Registers14_SVC;
				`MODE_ABT:
					out_RightReadBus=Registers14_ABT;
				`MODE_IRQ:
					out_RightReadBus=Registers14_IRQ;
				`MODE_UND:
					out_RightReadBus=Registers14_UND;
				default:
					out_RightReadBus=Registers14;
				endcase
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_RightReadBus=Registers14_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_RightReadBus=Registers14_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_RightReadBus=Registers14_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_RightReadBus=Registers14_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_RightReadBus=Registers14_UND;
			else//normal
				out_RightReadBus=Registers14;
		end
		8'b0000_1111:
			out_RightReadBus=Registers15;
		`Def_LocalForwardRegister:
			out_RightReadBus=LocalForwardRegister;
		default:
			out_RightReadBus=`WordZero;
		endcase
	end
	else
	begin
		out_RightReadBus=`WordZero;
	end
end

//third read
always @(Registers0 or
	Registers1 or
	Registers2 or
	Registers3 or
	Registers4 or
	Registers5 or
	Registers6 or
	Registers7 or
	Registers8 or
	Registers9 or
	Registers10 or
	Registers11 or
	Registers12 or
	Registers13 or
	Registers14 or
	Registers15 or
	Registers8_FIQ or
	Registers9_FIQ or
	Registers10_FIQ or
	Registers11_FIQ or
	Registers12_FIQ or
	Registers13_FIQ or
	Registers14_FIQ or
	Registers13_SVC or
	Registers14_SVC or
	Registers13_ABT or
	Registers14_ABT or
	Registers13_IRQ or
	Registers14_IRQ or
	Registers13_UND or
	Registers14_UND or
	LocalForwardRegister or
	in_ProcessorMode or
	in_ThirdReadEnable or
	in_ThirdReadRegisterNumber	or
	in_IfChangeState	or
	in_ChangeStateAction	or
	in_MemAccessUserBankRegister2WB
)
begin
	if(in_ThirdReadEnable==1'b1)
	begin
		case (in_ThirdReadRegisterNumber)
		8'b0000_0000:
			out_ThirdReadBus=Registers0;
		8'b0000_0001:
			out_ThirdReadBus=Registers1;
		8'b0000_0010:
			out_ThirdReadBus=Registers2;
		8'b0000_0011:
			out_ThirdReadBus=Registers3;
		8'b0000_0100:
			out_ThirdReadBus=Registers4;
		8'b0000_0101:
			out_ThirdReadBus=Registers5;
		8'b0000_0110:
			out_ThirdReadBus=Registers6;
		8'b0000_0111:
			out_ThirdReadBus=Registers7;
		8'b0000_1000:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers8;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers8_FIQ;
			else
				out_ThirdReadBus=Registers8;
		end
		8'b0000_1001:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers9;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers9_FIQ;
			else
				out_ThirdReadBus=Registers9;
		end
		8'b0000_1010:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers10;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers10_FIQ;
			else
				out_ThirdReadBus=Registers10;
		end
		8'b0000_1011:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers11;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers11_FIQ;
			else
				out_ThirdReadBus=Registers11;
		end
		8'b0000_1100:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers12;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers12_FIQ;
			else
				out_ThirdReadBus=Registers12;
		end
		8'b0000_1101:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_ThirdReadBus=Registers13;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers13_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_ThirdReadBus=Registers13_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_ThirdReadBus=Registers13_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_ThirdReadBus=Registers13_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_ThirdReadBus=Registers13_UND;
			else//normal
				out_ThirdReadBus=Registers13;
		end
		8'b0000_1110:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
				out_ThirdReadBus=Registers14;
			if(in_IfChangeState==1'b1)
			begin
				case(in_ChangeStateAction)
				`MODE_FIQ:
					out_ThirdReadBus=Registers14_FIQ;
				`MODE_SVC:
					out_ThirdReadBus=Registers14_SVC;
				`MODE_ABT:
					out_ThirdReadBus=Registers14_ABT;
				`MODE_IRQ:
					out_ThirdReadBus=Registers14_IRQ;
				`MODE_UND:
					out_ThirdReadBus=Registers14_UND;
				default:
					out_ThirdReadBus=Registers14;
				endcase
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_ThirdReadBus=Registers14_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_ThirdReadBus=Registers14_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_ThirdReadBus=Registers14_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_ThirdReadBus=Registers14_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_ThirdReadBus=Registers14_UND;
			else//normal
				out_ThirdReadBus=Registers14;
		end
		8'b0000_1111:
			out_ThirdReadBus=Registers15;
		`Def_LocalForwardRegister:
			out_ThirdReadBus=LocalForwardRegister;
		default:
			out_ThirdReadBus=`WordZero;
		endcase
	end
	else
	begin
		out_ThirdReadBus=`WordZero;
	end
end

//fourth read
always @(Registers0 or
	Registers1 or
	Registers2 or
	Registers3 or
	Registers4 or
	Registers5 or
	Registers6 or
	Registers7 or
	Registers8 or
	Registers9 or
	Registers10 or
	Registers11 or
	Registers12 or
	Registers13 or
	Registers14 or
	Registers15 or
	Registers8_FIQ or
	Registers9_FIQ or
	Registers10_FIQ or
	Registers11_FIQ or
	Registers12_FIQ or
	Registers13_FIQ or
	Registers14_FIQ or
	Registers13_SVC or
	Registers14_SVC or
	Registers13_ABT or
	Registers14_ABT or
	Registers13_IRQ or
	Registers14_IRQ or
	Registers13_UND or
	Registers14_UND or
	LocalForwardRegister or
	in_ProcessorMode or
	in_FourthReadEnable or
	in_FourthReadRegisterNumber	or
	in_IfChangeState	or
	in_ChangeStateAction	or
	in_MemAccessUserBankRegister2WB
)
begin
	if(in_FourthReadEnable==1'b1)
	begin
		case (in_FourthReadRegisterNumber)
		8'b0000_0000:
			out_FourthReadBus=Registers0;
		8'b0000_0001:
			out_FourthReadBus=Registers1;
		8'b0000_0010:
			out_FourthReadBus=Registers2;
		8'b0000_0011:
			out_FourthReadBus=Registers3;
		8'b0000_0100:
			out_FourthReadBus=Registers4;
		8'b0000_0101:
			out_FourthReadBus=Registers5;
		8'b0000_0110:
			out_FourthReadBus=Registers6;
		8'b0000_0111:
			out_FourthReadBus=Registers7;
		8'b0000_1000:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers8;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers8_FIQ;
			else
				out_FourthReadBus=Registers8;
		end
		8'b0000_1001:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers9;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers9_FIQ;
			else
				out_FourthReadBus=Registers9;
		end
		8'b0000_1010:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers10;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers10_FIQ;
			else
				out_FourthReadBus=Registers10;
		end
		8'b0000_1011:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers11;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers11_FIQ;
			else
				out_FourthReadBus=Registers11;
		end
		8'b0000_1100:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers12;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers12_FIQ;
			else
				out_FourthReadBus=Registers12;
		end
		8'b0000_1101:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
			begin
				out_FourthReadBus=Registers13;
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers13_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_FourthReadBus=Registers13_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_FourthReadBus=Registers13_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_FourthReadBus=Registers13_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_FourthReadBus=Registers13_UND;
			else//normal
				out_FourthReadBus=Registers13;
		end
		8'b0000_1110:
		begin
			if(in_MemAccessUserBankRegister2WB==1'b1)
				out_FourthReadBus=Registers14;
			if(in_IfChangeState==1'b1)
			begin
				case(in_ChangeStateAction)
				`MODE_FIQ:
					out_FourthReadBus=Registers14_FIQ;
				`MODE_SVC:
					out_FourthReadBus=Registers14_SVC;
				`MODE_ABT:
					out_FourthReadBus=Registers14_ABT;
				`MODE_IRQ:
					out_FourthReadBus=Registers14_IRQ;
				`MODE_UND:
					out_FourthReadBus=Registers14_UND;
				default:
					out_FourthReadBus=Registers14;
				endcase
			end
			else if(in_ProcessorMode==`MODE_FIQ)
				out_FourthReadBus=Registers14_FIQ;
			else if(in_ProcessorMode==`MODE_SVC)
				out_FourthReadBus=Registers14_SVC;
			else if(in_ProcessorMode==`MODE_ABT)
				out_FourthReadBus=Registers14_ABT;
			else if(in_ProcessorMode==`MODE_IRQ)
				out_FourthReadBus=Registers14_IRQ;
			else if(in_ProcessorMode==`MODE_UND)
				out_FourthReadBus=Registers14_UND;
			else//normal
				out_FourthReadBus=Registers14;
		end
		8'b0000_1111:
			out_FourthReadBus=Registers15;
		`Def_LocalForwardRegister:
			out_FourthReadBus=LocalForwardRegister;
		default:
			out_FourthReadBus=`WordZero;
		endcase
	end
	else
	begin
		out_FourthReadBus=`WordZero;
	end
end



always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		//initial the register file
		Registers0=`WordZero;
		Registers1=`WordZero;
		Registers2=`WordZero;
		Registers3=`WordZero;
		Registers4=`WordZero;
		Registers5=`WordZero;
		Registers6=`WordZero;
		Registers7=`WordZero;
		Registers8=`WordZero;
		Registers9=`WordZero;
		Registers10=`WordZero;
		Registers11=`WordZero;
		Registers12=`WordZero;
		Registers13=`WordZero;
		Registers14=`WordZero;
		Registers15=`Def_PCInitValue;
		
		Registers8_FIQ =`WordZero;
		Registers9_FIQ =`WordZero;
		Registers10_FIQ =`WordZero;
		Registers11_FIQ =`WordZero;
		Registers12_FIQ =`WordZero;
		Registers13_FIQ =`WordZero;
		Registers14_FIQ =`WordZero;
		Registers13_SVC =`WordZero;
		Registers14_SVC =`WordZero;
		Registers13_ABT =`WordZero;
		Registers14_ABT =`WordZero;
		Registers13_IRQ =`WordZero;
		Registers14_IRQ =`WordZero;
		Registers13_UND =`WordZero;
		Registers14_UND =`WordZero;
		
		LocalForwardRegister=`WordZero;
	end
	else
	begin
		if(in_WriteEnable==1'b1)
		begin
		   case (in_WriteRegisterNumber)
			8'b0000_0000:
				Registers0=in_WriteBus;
			8'b0000_0001:
				Registers1=in_WriteBus;
			8'b0000_0010:
				Registers2=in_WriteBus;
			8'b0000_0011:
				Registers3=in_WriteBus;
			8'b0000_0100:
				Registers4=in_WriteBus;
			8'b0000_0101:
				Registers5=in_WriteBus;
			8'b0000_0110:
				Registers6=in_WriteBus;
			8'b0000_0111:
				Registers7=in_WriteBus;
			8'b0000_1000:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers8=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers8_FIQ=in_WriteBus;
				else
					Registers8=in_WriteBus;
			end
			8'b0000_1001:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers9=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers9_FIQ=in_WriteBus;
				else
					Registers9=in_WriteBus;
			end
			8'b0000_1010:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers10=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers10_FIQ=in_WriteBus;
				else
					Registers10=in_WriteBus;
			end
			8'b0000_1011:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers11=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers11_FIQ=in_WriteBus;
				else
					Registers11=in_WriteBus;
			end
			8'b0000_1100:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers12=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers12_FIQ=in_WriteBus;
				else
					Registers12=in_WriteBus;
			end
			8'b0000_1101:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers13=in_WriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers13_FIQ=in_WriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers13_SVC=in_WriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers13_ABT=in_WriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers13_IRQ=in_WriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers13_UND=in_WriteBus;
				else
					Registers13=in_WriteBus;
			end
			8'b0000_1110:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
					Registers14=in_WriteBus;
				if(in_IfChangeState==1'b1)
				begin
					case(in_ChangeStateAction)
					`MODE_FIQ:
						Registers14_FIQ=in_WriteBus;
					`MODE_SVC:
						Registers14_SVC=in_WriteBus;
					`MODE_ABT:
						Registers14_ABT=in_WriteBus;
					`MODE_IRQ:
						Registers14_IRQ=in_WriteBus;
					`MODE_UND:
						Registers14_UND=in_WriteBus;
					default:
						Registers14=in_WriteBus;
					endcase
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers14_FIQ=in_WriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers14_SVC=in_WriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers14_ABT=in_WriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers14_IRQ=in_WriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers14_UND=in_WriteBus;
				else
					Registers14=in_WriteBus;
			end
			8'b0000_1111:
				Registers15=in_WriteBus;
			`Def_LocalForwardRegister:
				LocalForwardRegister=in_WriteBus;
		   endcase
		end


		//the second write port is reserve for pc update
		if(in_SecondWriteEnable==1'b1)
		begin
		   case (in_SecondWriteRegisterNumber)
			8'b0000_0000:
				Registers0=in_SecondWriteBus;
			8'b0000_0001:
				Registers1=in_SecondWriteBus;
			8'b0000_0010:
				Registers2=in_SecondWriteBus;
			8'b0000_0011:
				Registers3=in_SecondWriteBus;
			8'b0000_0100:
				Registers4=in_SecondWriteBus;
			8'b0000_0101:
				Registers5=in_SecondWriteBus;
			8'b0000_0110:
				Registers6=in_SecondWriteBus;
			8'b0000_0111:
				Registers7=in_SecondWriteBus;
			8'b0000_1000:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers8=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers8_FIQ=in_SecondWriteBus;
				else
					Registers8=in_SecondWriteBus;
			end
			8'b0000_1001:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers9=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers9_FIQ=in_SecondWriteBus;
				else
					Registers9=in_SecondWriteBus;
			end
			8'b0000_1010:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers10=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers10_FIQ=in_SecondWriteBus;
				else
					Registers10=in_SecondWriteBus;
			end
			8'b0000_1011:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers11=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers11_FIQ=in_SecondWriteBus;
				else
					Registers11=in_SecondWriteBus;
			end
			8'b0000_1100:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers12=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers12_FIQ=in_SecondWriteBus;
				else
					Registers12=in_SecondWriteBus;
			end
			8'b0000_1101:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers13=in_SecondWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers13_FIQ=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers13_SVC=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers13_ABT=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers13_IRQ=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers13_UND=in_SecondWriteBus;
				else
					Registers13=in_SecondWriteBus;
			end
			8'b0000_1110:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
					Registers14=in_SecondWriteBus;
				if(in_IfChangeState==1'b1)
				begin
					case(in_ChangeStateAction)
					`MODE_FIQ:
						Registers14_FIQ=in_SecondWriteBus;
					`MODE_SVC:
						Registers14_SVC=in_SecondWriteBus;
					`MODE_ABT:
						Registers14_ABT=in_SecondWriteBus;
					`MODE_IRQ:
						Registers14_IRQ=in_SecondWriteBus;
					`MODE_UND:
						Registers14_UND=in_SecondWriteBus;
					default:
						Registers14=in_SecondWriteBus;
					endcase
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers14_FIQ=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers14_SVC=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers14_ABT=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers14_IRQ=in_SecondWriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers14_UND=in_SecondWriteBus;
				else
					Registers14=in_SecondWriteBus;
			end
			8'b0000_1111:
				Registers15=in_SecondWriteBus;
			`Def_LocalForwardRegister:
				LocalForwardRegister=in_SecondWriteBus;
		   endcase
		end

		//the Third write port is reserve for pc update
		if(in_ThirdWriteEnable==1'b1)
		begin
		   case (in_ThirdWriteRegisterNumber)
			8'b0000_0000:
				Registers0=in_ThirdWriteBus;
			8'b0000_0001:
				Registers1=in_ThirdWriteBus;
			8'b0000_0010:
				Registers2=in_ThirdWriteBus;
			8'b0000_0011:
				Registers3=in_ThirdWriteBus;
			8'b0000_0100:
				Registers4=in_ThirdWriteBus;
			8'b0000_0101:
				Registers5=in_ThirdWriteBus;
			8'b0000_0110:
				Registers6=in_ThirdWriteBus;
			8'b0000_0111:
				Registers7=in_ThirdWriteBus;
			8'b0000_1000:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers8=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers8_FIQ=in_ThirdWriteBus;
				else
					Registers8=in_ThirdWriteBus;
			end
			8'b0000_1001:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers9=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers9_FIQ=in_ThirdWriteBus;
				else
					Registers9=in_ThirdWriteBus;
			end
			8'b0000_1010:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers10=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers10_FIQ=in_ThirdWriteBus;
				else
					Registers10=in_ThirdWriteBus;
			end
			8'b0000_1011:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers11=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers11_FIQ=in_ThirdWriteBus;
				else
					Registers11=in_ThirdWriteBus;
			end
			8'b0000_1100:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers12=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers12_FIQ=in_ThirdWriteBus;
				else
					Registers12=in_ThirdWriteBus;
			end
			8'b0000_1101:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
				begin
					Registers13=in_ThirdWriteBus;
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers13_FIQ=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers13_SVC=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers13_ABT=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers13_IRQ=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers13_UND=in_ThirdWriteBus;
				else
					Registers13=in_ThirdWriteBus;
			end
			8'b0000_1110:
			begin
				if(in_MemAccessUserBankRegister2WB==1'b1)
					Registers14=in_ThirdWriteBus;
				if(in_IfChangeState==1'b1)
				begin
					case(in_ChangeStateAction)
					`MODE_FIQ:
						Registers14_FIQ=in_ThirdWriteBus;
					`MODE_SVC:
						Registers14_SVC=in_ThirdWriteBus;
					`MODE_ABT:
						Registers14_ABT=in_ThirdWriteBus;
					`MODE_IRQ:
						Registers14_IRQ=in_ThirdWriteBus;
					`MODE_UND:
						Registers14_UND=in_ThirdWriteBus;
					default:
						Registers14=in_ThirdWriteBus;
					endcase
				end
				else if(in_ProcessorMode==`MODE_FIQ)
					Registers14_FIQ=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_SVC)
					Registers14_SVC=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_ABT)
					Registers14_ABT=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_IRQ)
					Registers14_IRQ=in_ThirdWriteBus;
				else if(in_ProcessorMode==`MODE_UND)
					Registers14_UND=in_ThirdWriteBus;
				else
					Registers14=in_ThirdWriteBus;
			end
			8'b0000_1111:
				Registers15=in_ThirdWriteBus;
			`Def_LocalForwardRegister:
				LocalForwardRegister=in_ThirdWriteBus;
		   endcase
		end

	end
end

endmodule