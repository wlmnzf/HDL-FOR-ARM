module	PipeLineFollower(
		in_Instruction,		//input from instruction prefetched buffer
		in_InstructionWait,	//wait for the prefetch buffer 
		//current instruction in MEM stage
		out_Instruction,
		//global signal
		clock,
		reset
);

input	[`InstructionWidth-1:0]	in_Instruction;
input	in_InstructionWait;

//current instruction in MEM stage
output	[`InstructionWidth-1:0]	out_Instruction,

input	clock,reset;


reg	[`InstructionWidth-1:0]	PipeLine_IF,PipeLine_ALU,PipeLine_MEM;
reg	[`InstructionWidth-1:0]	Next_PipeLine_IF,Next_PipeLine_ALU,Next_PipeLine_MEM;

always	@(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		PipeLine_IF=`InstructionZero;
		PipeLine_ALU=`InstructionZero;
		PipeLine_MEM=`InstructionZero;
	end
	else
	begin
		PipeLine_IF=Next_PipeLine_IF;
		PipeLine_ALU=Next_PipeLine_ALU;
		PipeLine_MEM=Next_PipeLine_MEM;
	end
end

always	@(in_InstructionWait	or
	in_Instruction	or
	PipeLine_IF	or
	PipeLine_ALU	or
	PipeLine_MEM
)
begin
	if(in_InstructionWait==1'b0)
	begin
		Next_PipeLine_IF=in_Instruction;
		Next_PipeLine_ALU=PipeLine_IF;
		Next_PipeLine_MEM=PipeLine_ALU;
	end
	else
	begin
		Next_PipeLine_IF=PipeLine_IF;
		Next_PipeLine_ALU=PipeLine_ALU;
		Next_PipeLine_MEM=PipeLine_MEM;
	end
end

assign	out_Instruction=PipeLine_MEM;

endmodule