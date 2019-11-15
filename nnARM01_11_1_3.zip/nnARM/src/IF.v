module IF(//Instruction fetch
		in_Instruction,		//input from instruction prefetched buffer
		in_InstructionWait,	//wait for the prefetch buffer 
		out_InstructionAddress,	//output to instruction prefetched buffer,this address is always word align even in thumb state
		//use to read pc
		out_FourthReadRegisterEnable,
		out_FourthReadRegisterNumber,
		in_FourthReadBus,
		//use to write pc
		out_SecondWriteRegisterEnable,
		out_SecondWriteRegisterNumber,
		out_SecondWriteBus,
		//can decoder go
		in_IDCanGo,
		//fetched instruction
		out_Instruction,
		out_ValidInstruction,
		out_AddressGoWithInstruction,
		out_NextInstructionAddress,//it is just the current PC value
		//signal relate to pc change in branch instruction
		in_ChangePC,
		in_NewPC,
		//signal send out by mem to update pc
		in_MEMChangePC,
		in_MEMNewPC,
		//thumb state
		in_ThumbState,
		clock,
		reset
		);

//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//		input and output declaration			//
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
input [`InstructionWidth-1:0] in_Instruction;
input in_InstructionWait;

output [`AddressBusWidth-1:0] out_InstructionAddress;
output	[`AddressBusWidth-1:0]	out_NextInstructionAddress;

output out_FourthReadRegisterEnable,out_SecondWriteRegisterEnable;
output [`Def_RegisterSelectWidth-1:0] out_FourthReadRegisterNumber,out_SecondWriteRegisterNumber;
input [`WordWidth-1:0] in_FourthReadBus;
output [`WordWidth-1:0] out_SecondWriteBus;

output	[`InstructionWidth-1:0]	out_Instruction;
output					out_ValidInstruction;
output	[`AddressBusWidth-1:0]		out_AddressGoWithInstruction;
reg	[`AddressBusWidth-1:0]		out_AddressGoWithInstruction,Next_out_AddressGoWithInstruction;

input in_IDCanGo;

input					in_ChangePC;
input	[`AddressBusWidth-1:0]		in_NewPC;

input					in_MEMChangePC;
input	[`AddressBusWidth-1:0]		in_MEMNewPC;

input					in_ThumbState;

input clock,reset;

//pipeline register
//if current FetchedInstruction valid?
reg					ValidInstruction;
reg					Next_ValidInstruction;
//fetched back instruction
reg	[`InstructionWidth-1:0]		FetchedInstruction;
reg	[`InstructionWidth-1:0]		Next_FetchedInstruction;
//the address send out to prefetch buffer
reg	[`AddressBusWidth-1:0]		FetchAddress;
reg	[`AddressBusWidth-1:0]		Next_FetchAddress;

//wire that read in pc
wire	[`AddressBusWidth-1:0]		PC;
//the next pc out to register file
reg	[`AddressBusWidth-1:0]		Next_PC;
//the pc+4 value
wire	[`AddressBusWidth-1:0]		PCAdd4or2;
wire	[`AddressBusWidth-1:0]		PCInc;

//this is the fetch address, always word align even in thumb state
assign	out_InstructionAddress={FetchAddress[`AddressBusWidth-1:2],2'b00};

//always read pc
assign	out_FourthReadRegisterEnable=1'b1;
assign	out_FourthReadRegisterNumber=`Def_PCNumber;

//always write to pc 
assign	out_SecondWriteRegisterEnable=1'b1;
assign	out_SecondWriteRegisterNumber=`Def_PCNumber;
assign	out_SecondWriteBus=Next_PC;

//output the fetched instruction
assign	out_Instruction=FetchedInstruction;
assign	out_ValidInstruction=ValidInstruction;
assign	out_NextInstructionAddress=PC;

//the readed pc
assign	PC=in_FourthReadBus;

//the pc+4 or PC+2
assign	PCInc={29'b0000_0000_0000_0000_0000_0000_0000_0,~in_ThumbState,in_ThumbState,1'b0};
assign	PCAdd4or2=PC+PCInc;


//decide the next state
always @(in_MEMChangePC	or
	in_MEMNewPC	or
	in_ChangePC	or
	in_NewPC	or
	in_IDCanGo	or
	in_InstructionWait	or
	in_ThumbState	or
	FetchAddress	or
	PC		or
	in_Instruction	or
	PCAdd4or2		or
	ValidInstruction	or
	FetchedInstruction	or
	out_AddressGoWithInstruction
)
begin
	if(in_MEMChangePC==1'b1)
	begin
		//in this case,all computation between if and mem will be clear
		//so just fetch and go
		Next_ValidInstruction=1'b0;
		Next_FetchedInstruction=`InstructionZero;
		Next_FetchAddress={in_MEMNewPC[`AddressBusWidth-1:1],1'b0};
		Next_PC=Next_FetchAddress;
		Next_out_AddressGoWithInstruction=PC;
	end
	else if(in_ChangePC==1'b1)
	begin
		//in this case,all computation between if and alu will be clear
		//so just fetch
		Next_ValidInstruction=1'b0;
		Next_FetchedInstruction=`InstructionZero;
		Next_FetchAddress={in_NewPC[`AddressBusWidth-1:1],1'b0};
		Next_PC=Next_FetchAddress;
		Next_out_AddressGoWithInstruction=PC;
	end
	else
	begin
		//no jump,just a normal case
		//take account of the in_InstructionWait
		if(in_IDCanGo==1'b1)
		begin
			//id can go
			if(in_InstructionWait==1'b1)
			begin
				//id can go,but prefetch can not go
				//make a blank in if
				Next_ValidInstruction=1'b0;
				Next_FetchedInstruction=`InstructionZero;
				//but the two address must preserve to serve the prefetch
				Next_FetchAddress=FetchAddress;
				Next_PC=PC;
				Next_out_AddressGoWithInstruction=PC;
			end
			else
			begin
				//id can go,and prefetch can also go
				Next_ValidInstruction=1'b1;
				Next_FetchedInstruction=in_Instruction;
				Next_FetchAddress=PCAdd4or2;
				Next_PC=PCAdd4or2;
				Next_out_AddressGoWithInstruction=PC;
			end
		end
		else
		begin
			//id can not go,preserve current state
			Next_ValidInstruction=ValidInstruction;
			Next_FetchedInstruction=FetchedInstruction;
			Next_FetchAddress=FetchAddress;
			Next_PC=PC;
			Next_out_AddressGoWithInstruction=out_AddressGoWithInstruction;
		end
	end
end

always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		ValidInstruction=1'b0;
		FetchedInstruction=`InstructionZero;
		FetchAddress=PC;
		out_AddressGoWithInstruction=`AddressBusZero;

	end
	else
	begin
		ValidInstruction=Next_ValidInstruction;
		FetchedInstruction=Next_FetchedInstruction;
		FetchAddress=Next_FetchAddress;
		out_AddressGoWithInstruction=Next_out_AddressGoWithInstruction;
	end
end

endmodule