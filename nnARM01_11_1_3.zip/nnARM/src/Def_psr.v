`define		CPSROperationWidth		`ByteWidth
`define		SPSROperationWidth		`ByteWidth

`define		ALUPSRType_Null			8'b0000_0000
//write whole cpsr
`define		ALUPSRType_WriteCPSR		8'b0000_0001
//put spsr to cpsr
`define		ALUPSRType_SPSR2CPSR		8'b0000_0010
//write condition code only ,for normal alu instruction
`define		ALUPSRType_WriteConditionCode	8'b0000_0011
//write whole spsr
`define		ALUPSRType_WriteSPSR		8'b0000_0100
//move right operand to spsr
`define		ALUPSRType_Right2SPSR		8'b0000_0101
//move right operand to cpsr
`define		ALUPSRType_Right2CPSR		8'b0000_0110
//add alu result as condition code to CPSR
`define		ALUPSRType_ALUResultAsConditionCode2CPSR	8'b0000_0111
//add alu result as condition code to SPSR
`define		ALUPSRType_ALUResultAsConditionCode2SPSR	8'b0000_1000
//cpsr to spsr
`define		ALUPSRType_CPSR2SPSR		8'b0000_1001
//switch on and off Thumb state
`define		ALUPSRType_ModifyThumbState	8'b0000_1010


//if current alu operation write cpsr?
`define		ALUWriteCPSR			(out_ALUPSRType==`ALUPSRType_WriteCPSR || out_ALUPSRType==`ALUPSRType_SPSR2CPSR || out_ALUPSRType==`ALUPSRType_WriteConditionCode || out_ALUPSRType==`ALUPSRType_Right2CPSR || out_ALUPSRType==`ALUPSRType_ALUResultAsConditionCode2CPSR)
//if alu write spsr?
`define		ALUWriteSPSR			(out_ALUPSRType==`ALUPSRType_WriteSPSR || out_ALUPSRType==`ALUPSRType_Right2SPSR || out_ALUPSRType==`ALUPSRType_ALUResultAsConditionCode2SPSR || out_ALUPSRType==`ALUPSRType_CPSR2SPSR)

`define		MEMPSRType_Null			8'b0000_0000
//write whole cpsr
`define		MEMPSRType_WriteCPSR	8'b0000_0001
//put spsr to cpsr
`define		MEMPSRType_SPSR2CPSR		8'b0000_0010
//write condition code only ,for normal alu instruction to write to cpsr
//also use by MSR that write condition code only
`define		MEMPSRType_WriteConditionCode	8'b0000_0011
//write whole spsr
`define		MEMPSRType_WriteSPSR		8'b0000_0100
`define		MEMPSRType_WriteBoth		8'b0000_0101


`define		MEMWriteCPSR			(in_MEMPSRType2WB==`MEMPSRType_WriteCPSR || in_MEMPSRType2WB==`MEMPSRType_SPSR2CPSR || in_MEMPSRType2WB==`MEMPSRType_WriteConditionCode)
`define		MEMWriteSPSR			(in_MEMPSRType2WB==`MEMPSRType_WriteSPSR)


//change to what state?
`define		ChangeState_Null		5'b00000
`define		ChangeState_SVC			`MODE_SVC


//determine the the carry zero overflow and neg position in psr
`define		NegPos			31
`define		ZeroPos			30
`define		CarryPos		29
`define		OverflowPos		28
`define		ThumbPos		5
`define		FiqPos			6
`define		IrqPos			7