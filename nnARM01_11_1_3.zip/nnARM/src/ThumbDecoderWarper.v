module	ThumbDecoderWarper(//input 
			in_ValidInstruction_IFID,
			in_PipelineRegister_IFID,
			in_AddressGoWithInstruction,
			in_ThumbState,
			//output
			out_NewAddressGoWithInstruction,
			out_nnARMInstruction,
			//clear internal state
			in_ChangePC,
			in_MEMChangePC,
			clock,reset
			);
			
input	in_ValidInstruction_IFID;
input	[`InstructionWidth-1:0]	in_PipelineRegister_IFID;
input	[`AddressBusWidth-1:0]	in_AddressGoWithInstruction;
input	in_ThumbState;

input	in_ChangePC,in_MEMChangePC;

input clock,reset;

output	[`AddressBusWidth-1:0]	out_NewAddressGoWithInstruction;
output	[`InstructionWidth-1:0]	out_nnARMInstruction;


reg	[`AddressBusWidth-1:0]	out_NewAddressGoWithInstruction;

wire	[15:0] input2Thumb_2_nnARM;

wire	[`InstructionWidth-1:0]	nnARMInstruction;

wire	ClearBit1;

wire	[`AddressBusWidth-1:0] AddressOfFirstHalf;

reg	NewA1;

wire	in_A1;

assign	in_A1=in_AddressGoWithInstruction[1];

//select hi part or low part of input 32 bit instruction
assign	input2Thumb_2_nnARM=(in_A1==1'b1)?in_PipelineRegister_IFID[31:16]:in_PipelineRegister_IFID[15:0];

//decoder selected 16 bit instruction
thumb_2_nnarm	inst_thumb_2_nnarm(//INPUTS
				.in_AddressGoWithInstruction(in_AddressGoWithInstruction),
				.cti(input2Thumb_2_nnARM), //Current THUMB Instruction
				.reset(reset),
				.clock(clock), 
				//OUTPUTS
		                .out_ClearBit1(ClearBit1),	//ssy add 2001 7 19
		                .out_AddressOfFirstHalf(AddressOfFirstHalf),
				.arm_inst(nnARMInstruction),
				//clear internal state
				.in_ChangePC(in_ChangePC),
				.in_MEMChangePC(in_MEMChangePC)
				);

//if in arm state ,just pass in_PipelineRegister_IFID output
//if in thumb state , just send out decoded nnARMInstruction
assign	out_nnARMInstruction=(in_ThumbState==1'b1)?nnARMInstruction:in_PipelineRegister_IFID;

always @(in_ThumbState or
	ClearBit1	or
	in_A1)
begin
	if(in_ThumbState==1'b1)
	begin
		if(ClearBit1==1'b1)
			NewA1=1'b0;
		else
			NewA1=in_A1;
	end
	else
	begin
		NewA1=in_A1;
	end
end

always	@(AddressOfFirstHalf	or
	NewA1			or
	in_AddressGoWithInstruction
	)
begin
	if(AddressOfFirstHalf[0]==1'b1)	//a valid long branch with link
	begin
		out_NewAddressGoWithInstruction={AddressOfFirstHalf[`AddressBusWidth-1:1],1'b0};
	end
	else
	begin
		out_NewAddressGoWithInstruction={in_AddressGoWithInstruction[`AddressBusWidth-1:2],NewA1,1'b0};
	end
end
endmodule