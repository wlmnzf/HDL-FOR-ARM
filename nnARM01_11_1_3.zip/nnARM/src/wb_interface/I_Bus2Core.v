module	I_Bus2Core(//signal between I_Bus2Core and IF
		IWait,			//if fetch ready?
		Instruction,		//fetch back instruction
		in_InstructionAddress,	//send out fetch address
		//signal goto wishbone
		wb_ack_i,
		wb_addr_o,
		wb_cyc_o,
		wb_data_i,
		wb_data_o,
		wb_err_i,
		wb_rty_i,
		wb_sel_o,
		wb_stb_o,
		wb_we_o,
		clk_i,
		rst_i
);
//input and output port
output	IWait;			//if fetch ready?
output	[`InstructionWidth-1:0]	Instruction;		//fetch back instruction
input	[`AddressBusWidth-1:0]	in_InstructionAddress;	//send out fetch address
//signal goto wishbone
input	wb_ack_i;
output	[`AddressBusWidth-1:0]	wb_addr_o;
output	wb_cyc_o;
input	[`WordWidth-1:0]	wb_data_i;
output	[`WordWidth-1:0]	wb_data_o;
input	wb_err_i;
input	wb_rty_i;
output	[7:0]	wb_sel_o;
output	wb_stb_o;
output	wb_we_o;
input	clk_i;
input	rst_i;

reg	IWait;			//if fetch ready?
reg	[`InstructionWidth-1:0]	Instruction;		//fetch back instruction
reg	[`AddressBusWidth-1:0]	wb_addr_o;
reg	wb_cyc_o;
reg	[`WordWidth-1:0]	wb_data_o;
reg	[7:0]	wb_sel_o;
reg	wb_stb_o;
reg	wb_we_o;


wire	IfCurrentAddressEquRequestAddress;
reg	[`AddressBusWidth-1:0]	CurrentAddress;
reg	[`InstructionWidth-1:0]	CurrentInstruction;

reg	[`AddressBusWidth-1:0]	Next_CurrentAddress;
reg	[`InstructionWidth-1:0]	Next_CurrentInstruction;

assign	IfCurrentAddressEquRequestAddress=(CurrentAddress[`AddressBusWidth-1:2]==in_InstructionAddress[`AddressBusWidth-1:2])?1'b1:1'b0;

always	@(IfCurrentAddressEquRequestAddress	or
	CurrentInstruction	or
	CurrentAddress	or
	in_InstructionAddress	or
	wb_ack_i	or
	wb_data_i
)
begin
	if(IfCurrentAddressEquRequestAddress==1'b1)	//request instruction is here
	begin
		IWait=1'b0;
		Instruction=CurrentInstruction;
		
		wb_addr_o=`AddressBusZero;
		wb_cyc_o=1'b0;
		wb_data_o=`WordZero;
		wb_sel_o=8'h0f;
		wb_stb_o=1'b0;
		wb_we_o=1'b0;
		
		Next_CurrentAddress=CurrentAddress;
		Next_CurrentInstruction=CurrentInstruction;
	end
	else						//request instruction is not here
	begin
		wb_addr_o=in_InstructionAddress;
		wb_cyc_o=1'b1;
		wb_data_o=`WordZero;
		wb_sel_o=8'h0f;
		wb_stb_o=1'b1;
		wb_we_o=1'b0;

		if(wb_ack_i==1'b0)	//no ack yet
		begin
			IWait=1'b1;
			Instruction=CurrentInstruction;
		
			Next_CurrentAddress=CurrentAddress;
			Next_CurrentInstruction=CurrentInstruction;
		end
		else			//ack come back
		begin
			IWait=1'b0;
			Instruction=wb_data_i;
		
			Next_CurrentAddress=in_InstructionAddress;
			Next_CurrentInstruction=wb_data_i;
		end
	end
end


always	@(posedge clk_i or posedge rst_i)
begin
	if(rst_i==1'b1)
	begin
		//this value can not be same as init PC
		CurrentAddress=32'hffffffff;
		CurrentInstruction=`InstructionZero;
	end
	else
	begin
		CurrentAddress=Next_CurrentAddress;
		CurrentInstruction=Next_CurrentInstruction;
	end
end
endmodule