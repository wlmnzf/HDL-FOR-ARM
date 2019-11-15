module ALUComb(ALUCombResult,
		ALUHighResult,
		out_Carry,
		out_Zero,
		out_Neg,
		out_Overflow,
		ALUComb_ALUType,
		ALUComb_LeftOperand,
		ALUComb_RightOperand,
		ALUComb_ThirdOperand,
		ALUComb_RightOperandShiftType,
		ALUComb_RightOperandShiftCount,
		ALUComb_ShiftCountInReg,	//shift count in register
		ALUComb_ShiftCountHigh3Bit,	//the [7:5] bit of shoft count when shift count is in register
		ALUComb_Operand2IsReg,
		in_Carry,
		in_Overflow,
		in_Neg,
		in_Zero,
		in_LongMulSig,
		clock,
		reset
);

input [`ByteWidth-1:0] ALUComb_ALUType;
input [`WordWidth-1:0] ALUComb_LeftOperand,ALUComb_RightOperand,ALUComb_ThirdOperand;
input [`Def_ShiftTypeWidth-1:0] ALUComb_RightOperandShiftType;
input [`Def_ShiftCountWidth-1:0] ALUComb_RightOperandShiftCount;
input	[2:0] ALUComb_ShiftCountHigh3Bit;
input	ALUComb_ShiftCountInReg;
input	ALUComb_Operand2IsReg;
input	in_Carry,in_Overflow,in_Neg,in_Zero;
input	in_LongMulSig;
input	clock;
input	reset;

reg	pin_Carry;

output [`WordWidth-1:0] ALUCombResult,ALUHighResult;
reg [`WordWidth-1:0] ALUCombResult,ALUHighResult;

output	out_Carry,out_Zero,out_Neg,out_Overflow;
reg	out_Carry,out_Zero,out_Neg,out_Overflow;


reg [`WordWidth-1:0] LeftTmp,RightTmp,LeftAdd,RightAdd,LeftAddHigh,RightAddHigh;
reg LowCarry;

//mul result
wire	[65:0]	MULResult;

//the status from alu
wire alu_Carry,alu_Zero,alu_Neg,alu_Overflow;
wire alu_CarryHigh,alu_ZeroHigh,alu_NegHigh,alu_OverflowHigh;

//the status from barrel shifter
wire barrel_Carry;

wire [`WordWidth-1:0] ShiftResult,ComplementResult;
wire [`WordWidth-1:0] out_Result,out_ResultHigh;

//record the multiple result of MLAL
reg	[65:0]	MLALReg;
reg	[65:0]	Next_MLALReg;


always	@(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		MLALReg=66'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00;
	end
	else
	begin
		MLALReg=Next_MLALReg;
	end
end

BarrelShift inst_BarrelShift(ShiftResult,
			barrel_Carry,
			ALUComb_RightOperand,
			ALUComb_RightOperandShiftCount,
			ALUComb_RightOperandShiftType,
			ALUComb_ShiftCountInReg,
			ALUComb_ShiftCountHigh3Bit,
			ALUComb_Operand2IsReg,
			in_Carry
);

//select who is to be left operand and who is to be right operand to the adder
always @(ALUComb_LeftOperand or ALUComb_ALUType or ShiftResult)
begin
	if(ALUComb_ALUType==`ALUType_Rsb || ALUComb_ALUType==`ALUType_Rsc)
	begin
		LeftTmp=ShiftResult;
		RightTmp=ALUComb_LeftOperand;
	end
	else
	begin
		LeftTmp=ALUComb_LeftOperand;
		RightTmp=ShiftResult;
	end
end


			
complementary inst_complementary(ComplementResult,
			RightTmp);

WordAdder	inst_WordAdder(out_Result,
		alu_Carry,
		alu_Zero,
		alu_Neg,
		alu_Overflow,
		LeftAdd,
		RightAdd,
		LowCarry);

WordAdder	inst_HighWordAdder(out_ResultHigh,
		alu_CarryHigh,
		alu_ZeroHigh,
		alu_NegHigh,
		alu_OverflowHigh,
		LeftAddHigh,
		RightAddHigh,
		alu_Carry);

		
always @(ALUComb_ALUType or 
	ALUComb_LeftOperand	or
	ALUComb_RightOperand	or
	ALUComb_ThirdOperand	or
	LeftTmp or 
	RightTmp or 
	out_Result or 
	out_ResultHigh	or
	ComplementResult or 
	ShiftResult or
	alu_Carry or
	alu_Neg or
	alu_Zero or
	alu_Overflow or
	alu_CarryHigh or
	alu_NegHigh or
	alu_ZeroHigh or
	alu_OverflowHigh or
	barrel_Carry	or
	MULResult	or
	in_Carry	or
	in_Overflow	or
	in_Neg		or
	in_Zero		or
	ALUComb_RightOperandShiftType	or
	ALUComb_RightOperandShiftCount	or
	MLALReg
)
begin
	LeftAdd=`WordZero;
	RightAdd=`WordZero;
	LeftAddHigh=`WordZero;
	RightAddHigh=`WordZero;
	LowCarry=1'b0;
	ALUCombResult=`WordZero;
	ALUHighResult=`WordZero;

	Next_MLALReg=MLALReg;

	
	//if shift of right operand is LSL 0 then carry of logic operation will not be affect
	if(ALUComb_RightOperandShiftType==`Def_ShiftType_LogicLeft && ALUComb_RightOperandShiftCount==`Def_ShiftCountZero)
		pin_Carry=1'b1;
	else
		pin_Carry=1'b0;
	
	//prevent of latch infer
	out_Carry=1'b0;
	out_Neg=1'b0;
	out_Overflow=1'b0;
	case (ALUComb_ALUType)
	`ALUType_Add:
	   begin
		LeftAdd=LeftTmp;
		RightAdd=RightTmp;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Sub:
	   begin
		LeftAdd=LeftTmp;
		RightAdd=ComplementResult;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_And:
	   begin
		ALUCombResult=LeftTmp & RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Eor:
	   begin
		ALUCombResult=LeftTmp ^ RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Rsb:
	   begin
		LeftAdd=LeftTmp;
		RightAdd=ComplementResult;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Adc:
	   begin
		LowCarry=in_Carry;
		LeftAdd=LeftTmp;
		RightAdd=RightTmp;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Sbc:
	   begin
		LowCarry=in_Carry;
		LeftAdd=LeftTmp;
		RightAdd=~RightTmp;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Rsc:
	   begin
		LowCarry=in_Carry;
		LeftAdd=LeftTmp;
		RightAdd=~RightTmp;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Tst:
	   begin
		ALUCombResult=LeftTmp & RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Teq:
	   begin
		ALUCombResult=LeftTmp ^ RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Cmp:
	   begin
		LeftAdd=LeftTmp;
		RightAdd=ComplementResult;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Cmn:
	   begin
		LeftAdd=LeftTmp;
		RightAdd=RightTmp;
		ALUCombResult=out_Result;
		out_Carry=alu_Carry;
		out_Neg=alu_Neg;
		out_Overflow=alu_Overflow;
	   end
	`ALUType_Orr:
	   begin
		ALUCombResult=LeftTmp | RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Mov:
	   begin
		ALUCombResult=ShiftResult;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Bic:
	   begin
		ALUCombResult=LeftTmp & ~RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Mvn:
	   begin
		ALUCombResult=~RightTmp;
		out_Overflow=in_Overflow;
		out_Carry=(pin_Carry==1'b1)?in_Carry:barrel_Carry;
		out_Neg=ALUCombResult[31];
	   end
	`ALUType_Mul:
	   begin
		ALUCombResult=MULResult[31:0];
		out_Neg=ALUCombResult[31];
		//overflow will not be affect
		out_Overflow=in_Overflow;
		//carry is meaningless
		out_Carry=1'b0;
	   end
	`ALUType_Mla:
	   begin
	   	LeftAdd=MULResult[31:0];
	   	RightAdd=ALUComb_ThirdOperand;
	   	ALUCombResult=out_Result;
		out_Neg=ALUCombResult[31];
		//overflow will not be affect
		out_Overflow=in_Overflow;
		//carry is meaningless
		out_Carry=1'b0;
	   end
	`ALUType_MULL:
	   begin
		ALUCombResult=MULResult[31:0];
		ALUHighResult=MULResult[63:32];
		out_Neg=MULResult[63];
		//overflow will not be affect
		out_Overflow=in_Overflow;
		//carry is meaningless
		out_Carry=1'b0;
	  end
	`ALUType_MLALMul:
	begin
		ALUCombResult=MULResult[31:0];
		ALUHighResult=MULResult[63:32];
		out_Neg=MULResult[63];
		//overflow will not be affect
		out_Overflow=in_Overflow;
		//carry is meaningless
		out_Carry=1'b0;
		Next_MLALReg=MULResult;
	end
	`ALUType_MLALAdd:
	begin
		LeftAdd=MLALReg[31:0];
		LeftAddHigh=MLALReg[63:32];
		RightAdd=ALUComb_LeftOperand;
		RightAddHigh=ALUComb_RightOperand;
		ALUCombResult=out_Result;
		ALUHighResult=out_ResultHigh;
		out_Neg=out_ResultHigh[31];
		//overflow will not be affect
		out_Overflow=in_Overflow;
		//carry is meaningless
		out_Carry=1'b0;
	end
	endcase
	out_Zero=({ALUHighResult,ALUCombResult}==64'h0000_0000_0000_0000)?1'b1:1'b0;
end
//assign	MULResult=66'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_00;
mul	inst_mul(
		.out_MulResult(MULResult),
		.in_a(ALUComb_LeftOperand),
		.in_b(ALUComb_RightOperand),
		.in_LongMulSig(in_LongMulSig)
);

endmodule
