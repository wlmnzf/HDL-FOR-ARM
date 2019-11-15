module MemoryController_WB_Bhv(//wishbone global signal
				clk_i,	//wishbone clock from syscon
				rst_i,	//wishbone reset from syscon
				//wishbone interface
				wb_addr_i,	//32 bit address input
				wb_data_i,	//32 bit data input
				wb_data_o,	//32 bit data output
				wb_sel_i,	//4 bits input Indicates which bytes are valid on the data bus
				wb_we_i,	//1 bit write enable
				wb_cyc_i,	// 1 bit Encapsulates a valid transfer cycle
				wb_stb_i,	//1 bit Indicates a valid transfer.
				wb_ack_o,	//1 bit Indicates a normal Cycle termina-tion
				wb_err_o,	//1 bit Indicates an abnormal cycle termination
				wb_rty_o
);
input clk_i,rst_i;

input	[31:0]	wb_addr_i,wb_data_i;

output	[31:0]	wb_data_o;

input	[7:0]	wb_sel_i;

input	wb_we_i,wb_cyc_i,wb_stb_i;

output	wb_ack_o,wb_err_o,wb_rty_o;


reg	[31:0]	wb_data_o;
reg	wb_ack_o,wb_err_o;


reg 	[7:0]	Memory	[1024*1024-1:0];

wire	[`ByteWidth-1:0]	test8024,test8025,test8026,test8027,test8034,test8035,test8036,test8037;

assign	test8024=Memory[32'h8024];
assign	test8025=Memory[32'h8025];
assign	test8026=Memory[32'h8026];
assign	test8027=Memory[32'h8027];
assign	test8034=Memory[32'h8034];
assign	test8035=Memory[32'h8035];
assign	test8036=Memory[32'h8036];
assign	test8037=Memory[32'h8037];

//read
always @(wb_cyc_i	or
	wb_stb_i	or
	wb_we_i	or
	wb_addr_i	or
	wb_data_i	or
	wb_sel_i
)
begin
	if(wb_cyc_i==1'b1 && wb_stb_i==1'b1)
	begin
	   if(wb_we_i==1'b0)	//read
	   begin
		if(wb_addr_i[31:20]==12'h000)	//address in my address space
		begin
			wb_data_o={Memory[{12'h000,wb_addr_i[19:2],2'b11}],Memory[{12'h000,wb_addr_i[19:2],2'b10}],Memory[{12'h000,wb_addr_i[19:2],2'b01}],Memory[{12'h000,wb_addr_i[19:2],2'b00}]};
				
			wb_ack_o=1'b1;
			wb_err_o=1'b0;
		end
		else				//address is not in my space
		begin
			wb_data_o=`WordZero;
			wb_ack_o=1'b0;
			wb_err_o=1'b0;
		end
	   end
	   else			//write
	   begin
		if(wb_addr_i[31:20]==12'h000)	//address in my address space
		begin
			wb_ack_o=1'b1;
			wb_err_o=1'b0;
			wb_data_o=`WordZero;
		end
		else				//address is not in my space
		begin
			wb_ack_o=1'b0;
			wb_err_o=1'b0;
			wb_data_o=`WordZero;
		end
	   end
	end
	else
	begin
		wb_data_o=`WordZero;
		wb_ack_o=1'b0;
		wb_err_o=1'b0;
	end
end

always	@(posedge clk_i or posedge rst_i)
begin
	if(wb_we_i==1'b1 && wb_addr_i[31:20]==12'h000 && wb_cyc_i==1'b1 && wb_stb_i==1'b1)
	begin
		if(wb_sel_i[0]==1'b1)
			Memory[{12'h000,wb_addr_i[19:2],2'b00}]=wb_data_i[7:0];
			
		if(wb_sel_i[1]==1'b1)
			Memory[{12'h000,wb_addr_i[19:2],2'b01}]=wb_data_i[15:8];

		if(wb_sel_i[2]==1'b1)
			Memory[{12'h000,wb_addr_i[19:2],2'b10}]=wb_data_i[23:16];

		if(wb_sel_i[3]==1'b1)
			Memory[{12'h000,wb_addr_i[19:2],2'b11}]=wb_data_i[31:24];
	end
end

assign	wb_rty_o=1'b0;
endmodule