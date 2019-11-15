module BarrelShift(	out_ShiftOut,
			out_Carry,		//carry for logic operation
			in_ShiftIn,
			in_ShiftCount,
			in_ShiftType,
			in_ShiftCountInReg,
			in_ShiftCountHigh3Bit,
			in_Operand2IsReg,
			in_Carry);

output [`WordWidth-1:0] out_ShiftOut;
reg [`WordWidth-1:0] out_ShiftOut;

output		out_Carry;

input [`WordWidth-1:0] in_ShiftIn;
input [`Def_ShiftCountWidth-1:0]  in_ShiftCount;
input [`Def_ShiftTypeWidth-1:0] in_ShiftType;
input	[2:0]			in_ShiftCountHigh3Bit;
input				in_ShiftCountInReg;
input				in_Operand2IsReg;
input	in_Carry;

reg [`WordWidth-1:0] Barrel;
reg Carry;
wire	IfLow5BitEquZero,IfHigh3BitEqu001,IfEqu32,IfG32,IfHigh3BitEqu000,IfGE32;



assign	IfLow5BitEquZero=(in_ShiftCount==5'b00000)?1'b1:1'b0;
assign	IfHigh3BitEqu001=(in_ShiftCountHigh3Bit==3'b001)?1'b1:1'b0;
assign	IfHigh3BitEqu000=(in_ShiftCountHigh3Bit==3'b000)?1'b1:1'b0;
assign	IfEqu32=IfLow5BitEquZero & IfHigh3BitEqu001;
assign	IfG32=!IfEqu32 & !IfHigh3BitEqu000;
assign	IfGE32=!IfHigh3BitEqu000;


assign out_Carry=Carry;

always @(in_ShiftIn or 
	in_ShiftCount or 
	in_ShiftType or
	in_ShiftCountInReg or
	IfEqu32	or
	IfG32	or
	IfGE32	or
	IfLow5BitEquZero	or
	in_Carry	or
	in_Operand2IsReg
	)
begin
	Barrel=in_ShiftIn;
	Carry=1'b0;
	
	if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_LogicLeft && IfEqu32==1'b1)
	begin
		Carry=Barrel[0];
		Barrel=`WordZero;
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_LogicLeft &&  IfG32==1'b1)
	begin
		Carry=1'b0;
		Barrel=`WordZero;
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_LogicRight && IfEqu32==1'b1)
	begin
		Carry=Barrel[`WordWidth-1];
		Barrel=`WordZero;
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_LogicRight && IfG32==1'b1)
	begin
		Carry=1'b0;
		Barrel=`WordZero;
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_ArithmeticRight && IfGE32==1'b1)
	begin
		Carry=Barrel[`WordWidth-1];
		Barrel={32{Barrel[`WordWidth-1]}};
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b1 && in_ShiftType==`Def_ShiftType_RotateRight && IfEqu32==1'b1)
	begin
		Carry=Barrel[`WordWidth-1];
		//Barrel remain unchange
	end//for ROR by more than 32 bit , the high 3 bit will not be consider
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b0 && IfLow5BitEquZero && in_ShiftType==`Def_ShiftType_LogicRight)
	begin
		Carry=Barrel[`WordWidth-1];
		Barrel=`WordZero;
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b0 && IfLow5BitEquZero && in_ShiftType==`Def_ShiftType_ArithmeticRight)
	begin
		Carry=Barrel[`WordWidth-1];
		Barrel={(`WordWidth){Barrel[`WordWidth-1]}};
	end
	else if(in_Operand2IsReg==1'b1 && in_ShiftCountInReg==1'b0 && IfLow5BitEquZero && in_ShiftType==`Def_ShiftType_RotateRight)
	begin
		Carry=Barrel[0];
		Barrel={in_Carry,Barrel[`WordWidth-1:1]};
	end
	else
	begin	
	//shift 16 bits
	if(in_ShiftCount[4]==1'b1)
	begin
		case(in_ShiftType)
		`Def_ShiftType_LogicLeft:
		begin
			Carry=Barrel[`WordWidth-16];
			Barrel={Barrel[`WordWidth-1-16:0],16'h0000};
		end
		`Def_ShiftType_LogicRight:
		begin
			Carry=Barrel[15];
			Barrel={16'h0000,Barrel[`WordWidth-1:16]};
		end
		`Def_ShiftType_ArithmeticRight:
		begin
			Carry=Barrel[15];
			Barrel={{16{Barrel[`WordWidth-1]}},Barrel[`WordWidth-1:16]};
		end
		`Def_ShiftType_RotateRight:
		begin
			Carry=Barrel[15];
			Barrel={Barrel[15:0],Barrel[`WordWidth-1:16]};
		end
		endcase
	end
	
	//shift 8 bits
	if(in_ShiftCount[3]==1'b1)
	begin
		case(in_ShiftType)
		`Def_ShiftType_LogicLeft:
		begin
			Carry=Barrel[`WordWidth-8];
			Barrel={Barrel[`WordWidth-1-8:0],8'h00};
		end
		`Def_ShiftType_LogicRight:
		begin
			Carry=Barrel[7];
			Barrel={8'h00,Barrel[`WordWidth-1:8]};
		end
		`Def_ShiftType_ArithmeticRight:
		begin
			Carry=Barrel[7];
			Barrel={{8{Barrel[`WordWidth-1]}},Barrel[`WordWidth-1:8]};
		end
		`Def_ShiftType_RotateRight:
		begin
			Carry=Barrel[7];
			Barrel={Barrel[7:0],Barrel[`WordWidth-1:8]};
		end
		endcase
	end
	
	//shift 4 bits
	if(in_ShiftCount[2]==1'b1)
	begin
		case(in_ShiftType)
		`Def_ShiftType_LogicLeft:
		begin
			Carry=Barrel[`WordWidth-4];
			Barrel={Barrel[`WordWidth-1-4:0],4'h0};
		end
		`Def_ShiftType_LogicRight:
		begin
			Carry=Barrel[3];
			Barrel={4'h0,Barrel[`WordWidth-1:4]};
		end
		`Def_ShiftType_ArithmeticRight:
		begin
			Carry=Barrel[3];
			Barrel={{4{Barrel[`WordWidth-1]}},Barrel[`WordWidth-1:4]};
		end
		`Def_ShiftType_RotateRight:
		begin
			Carry=Barrel[3];
			Barrel={Barrel[3:0],Barrel[`WordWidth-1:4]};
		end
		endcase
	end
	
	//shift 2 bits
	if(in_ShiftCount[1]==1'b1)
	begin
		case(in_ShiftType)
		`Def_ShiftType_LogicLeft:
		begin
			Carry=Barrel[`WordWidth-2];
			Barrel={Barrel[`WordWidth-1-2:0],2'b00};
		end
		`Def_ShiftType_LogicRight:
		begin
			Carry=Barrel[1];
			Barrel={2'b00,Barrel[`WordWidth-1:2]};
		end
		`Def_ShiftType_ArithmeticRight:
		begin
			Carry=Barrel[1];
			Barrel={{2{Barrel[`WordWidth-1]}},Barrel[`WordWidth-1:2]};
		end
		`Def_ShiftType_RotateRight:
		begin
			Carry=Barrel[1];
			Barrel={Barrel[1:0],Barrel[`WordWidth-1:2]};
		end
		endcase
	end
	
	//shift 1 bits
	if(in_ShiftCount[0]==1'b1)
	begin
		case(in_ShiftType)
		`Def_ShiftType_LogicLeft:
		begin
			Carry=Barrel[`WordWidth-1];
			Barrel={Barrel[`WordWidth-1-1:0],1'b0};
		end
		`Def_ShiftType_LogicRight:
		begin
			Carry=Barrel[0];
			Barrel={1'b0,Barrel[`WordWidth-1:1]};
		end
		`Def_ShiftType_ArithmeticRight:
		begin
			Carry=Barrel[0];
			Barrel={Barrel[`WordWidth-1],Barrel[`WordWidth-1:1]};
		end
		`Def_ShiftType_RotateRight:
		begin
			Carry=Barrel[0];
			Barrel={Barrel[0],Barrel[`WordWidth-1:1]};
		end
		endcase
	end
	end
	
	out_ShiftOut=Barrel;
end

endmodule