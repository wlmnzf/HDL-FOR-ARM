module nnARM(
		pic_int,
		clock,
		reset
	);

input clock,reset;
input [`PIC_INTS-1:0] pic_int;

//signal between I_Bus2Core and IF
wire	I_Bus2Core_Wait;	//if fetch ready?
wire	[`InstructionWidth-1:0]	I_Bus2Core_Instruction;	//fetch back instruction
wire	[`AddressBusWidth-1:0]	I_Bus2Core_InstructionAddress;	//send out fetch address

//signal between mem and D_Bus2Core
wire	[`AddressBusWidth-1:0]	D_Bus2Core_Address;	//data address
wire	[`WordWidth-1:0]	D_Bus2Core_Bus_r,D_Bus2Core_Bus_f;	//data value for write and read
wire	D_Bus2Core_Request;	//enable access
wire	D_Bus2Core_BW;	//1 means byte,0 means word
wire	D_Bus2Core_RW;	//1 means read,0 means write
wire	D_Bus2Core_Wait;	//wait for free	

//signal of instruction wishbone interface
wire	I_wb_ack_i;
wire	[`AddressBusWidth-1:0]	I_wb_addr_o;
wire	I_wb_cyc_o;
wire	[`WordWidth-1:0]	I_wb_data_i;
wire	[`WordWidth-1:0]	I_wb_data_o;
wire	I_wb_err_i;
wire	I_wb_rty_i;
wire	[7:0]	I_wb_sel_o;
wire	I_wb_stb_o;
wire	I_wb_we_o;

//signal of data wishbone interface
wire	D_wb_ack_i;
wire	[`AddressBusWidth-1:0]	D_wb_addr_o;
wire	D_wb_cyc_o;
wire	[`WordWidth-1:0]	D_wb_data_i;
wire	[`WordWidth-1:0]	D_wb_data_o;
wire	D_wb_err_i;
wire	D_wb_rty_i;
wire	[7:0]	D_wb_sel_o;
wire	D_wb_stb_o;
wire	D_wb_we_o;

//grant signal for the two master
wire	D_wb_gnt,D_wb_gnt;

//wishbone clock and reset
wire	wb_clk_i,wb_rst_i;

//common signal
//forward signal that goto slave 0
wire	[`AddressBusWidth-1:0]	com_addr_f;
wire	com_cyc_f,com_stb_f,com_we_f;
wire	[`WordWidth-1:0]	com_data_f;
wire	[7:0]	com_sel_f;


//memory controller output signal
wire	[`WordWidth-1:0]	wb_data_o_memctl;
wire	wb_ack_o_memctl,wb_err_o_memctl,wb_rty_o_memctl;

wire	out_MEMAccessHalfWordTransfer;
wire	[1:0]	out_MEMAccessHalfWordType;

//programable interrupt controller's wishbone signal
wire	[`WordWidth-1:0]	wb_data_o_pic,wb_data_i_pic;
wire	[`AddressBusWidth-1:0]	wb_addr_i_pic;
wire	[7:0]		wb_sel_i_pic;
wire	wb_we_i_pic,wb_cyc_i_pic,wb_stb_i_pic,wb_ack_o_pic,wb_err_o_pic,wb_rty_o_pic;


nnARMCore	inst_nnARMCore(//signal between I_Bus2Core and IF
		.Wait(I_Bus2Core_Wait),			//if fetch ready?
		.Instruction(I_Bus2Core_Instruction),		//fetch back instruction
		.out_InstructionAddress(I_Bus2Core_InstructionAddress),	//send out fetch address
		//signal between mem and D_Bus2Core
		.out_MEMAccessAddress(D_Bus2Core_Address),		//data address
		.DataBus_r(D_Bus2Core_Bus_r),		//data value for write and read
		.DataBus_f(D_Bus2Core_Bus_f),
		.out_MEMAccessRequest(D_Bus2Core_Request),	//enable access
		.out_MEMAccessBW(D_Bus2Core_BW),			//1 means byte,0 means word
		.out_MEMAccessRW(D_Bus2Core_RW),			//1 means read,0 means write
		.out_DataCacheWait(D_Bus2Core_Wait),		//wait for free	
		.out_MEMAccessHalfWordTransfer(out_MEMAccessHalfWordTransfer),
		.out_MEMAccessHalfWordType(out_MEMAccessHalfWordType),
		//interrupt signal
		.Fiq(Fiq),
		.Irq(Irq),
		.clock(clock),
		.reset(reset)
		);


I_Bus2Core	inst_I_Bus2Core(//signal between I_Bus2Core and IF
		.IWait(I_Bus2Core_Wait),			//if fetch ready?
		.Instruction(I_Bus2Core_Instruction),		//fetch back instruction
		.in_InstructionAddress(I_Bus2Core_InstructionAddress),	//send out fetch address
		//signal goto wishbone
		.wb_ack_i(I_wb_ack_i),
		.wb_addr_o(I_wb_addr_o),
		.wb_cyc_o(I_wb_cyc_o),
		.wb_data_i(I_wb_data_i),
		.wb_data_o(I_wb_data_o),
		.wb_err_i(I_wb_err_i),
		.wb_rty_i(I_wb_rty_i),
		.wb_sel_o(I_wb_sel_o),
		.wb_stb_o(I_wb_stb_o),
		.wb_we_o(I_wb_we_o),
		.clk_i(clock),
		.rst_i(~reset)
);

D_Bus2Core	inst_D_Bus2Core(//signal between mem and D_Bus2Core
		.in_MEMAccessAddress(D_Bus2Core_Address),		//data address
		.out_DataCacheBus(D_Bus2Core_Bus_r),		//data value for write and read
		.in_DataCacheBus(D_Bus2Core_Bus_f),		//data value for write and read
		.in_MEMAccessRequest(D_Bus2Core_Request),	//enable access
		.in_MEMAccessBW(D_Bus2Core_BW),			//1 means byte,0 means word
		.in_MEMAccessRW(D_Bus2Core_RW),			//1 means read,0 means write
		.in_MEMAccessHalfWordTransfer(out_MEMAccessHalfWordTransfer),
		.in_MEMAccessHalfWordType(out_MEMAccessHalfWordType),
		.out_DataCacheWait(D_Bus2Core_Wait),		//wait for free	
		//signal goto wishbone
		.wb_ack_i(D_wb_ack_i),
		.wb_addr_o(D_wb_addr_o),
		.wb_cyc_o(D_wb_cyc_o),
		.wb_data_i(D_wb_data_i),
		.wb_data_o(D_wb_data_o),
		.wb_err_i(D_wb_err_i),
		.wb_rty_i(D_wb_rty_i),
		.wb_sel_o(D_wb_sel_o),
		.wb_stb_o(D_wb_stb_o),
		.wb_we_o(D_wb_we_o),
		.clk_i(clock),
		.rst_i(~reset)
);

wb_conmax_top	#(	32,	//data bus width
			32,	//address bus width
			4'hf,	//wishbone register file address
			2'h2,	//4 priority for slave 0
			2'h2	//4 priority for slave 1
		)
		inst_wb_conmax_top(
	clock, ~reset,

	// Master 0 Interface for data access
	D_wb_data_o, D_wb_data_i, D_wb_addr_o, D_wb_sel_o[3:0], D_wb_we_o, D_wb_cyc_o,
	D_wb_stb_o, D_wb_ack_i, D_wb_err_i, D_wb_rty_i,

	// Master 1 Interface for instruction access
	I_wb_data_o, I_wb_data_i, I_wb_addr_o, I_wb_sel_o[3:0], I_wb_we_o, I_wb_cyc_o,
	I_wb_stb_o, I_wb_ack_i, I_wb_err_i, I_wb_rty_i,

	// Master 2 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Master 3 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Master 4 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Master 5 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Master 6 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Master 7 Interface
	32'h0000_0000, , 32'h0000_0000, 4'h0, 1'b0, 1'b0,
	1'b0, , , ,

	// Slave 0 Interface for memory controller
	wb_data_o_memctl, com_data_f, com_addr_f, com_sel_f[3:0], com_we_f, com_cyc_f,
	com_stb_f, wb_ack_o_memctl, wb_err_o_memctl, wb_rty_o_memctl,

	// Slave 1 Interface for interrupt controller
	wb_data_o_pic, wb_data_i_pic, wb_addr_i_pic, wb_sel_i_pic[3:0], wb_we_i_pic, wb_cyc_i_pic,
	wb_stb_i_pic, wb_ack_o_pic, wb_err_o_pic, wb_rty_o_pic,

	// Slave 2 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 3 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 4 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 5 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 6 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 7 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 8 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 9 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 10 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 11 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 12 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 13 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 14 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0,

	// Slave 15 Interface
	32'h0000_0000, , , , , ,
	, 1'b0, 1'b0, 1'b0
				);

//programable interrupt controller
pic_wrapper	inst_pic_wrapper(//wishbone global signal
				.clk_i(clock),	//wishbone clock from syscon
				.rst_i(reset),	//wishbone reset from syscon
				//wishbone interface
				.wb_addr_i(wb_addr_i_pic),	//32 bit address input
				.wb_data_i(wb_data_i_pic),	//32 bit data input
				.wb_data_o(wb_data_o_pic),	//32 bit data output
				.wb_sel_i(wb_sel_i_pic),	//4 bits input Indicates which bytes are valid on the data bus
				.wb_we_i(wb_we_i_pic),	//1 bit write enable
				.wb_cyc_i(wb_cyc_i_pic),	// 1 bit Encapsulates a valid transfer cycle
				.wb_stb_i(wb_stb_i_pic),	//1 bit Indicates a valid transfer.
				.wb_ack_o(wb_ack_o_pic),	//1 bit Indicates a normal Cycle termina-tion
				.wb_err_o(wb_err_o_pic),	//1 bit Indicates an abnormal cycle termination
				.wb_rty_o(wb_rty_o_pic),
				//interrupt signal to core
				.Irq(Irq),
				//external interrupt source
				.pic_int(pic_int),
				//pic control the wakeup of the system
				.pic_wakeup()
);

MemoryController_WB_Bhv	inst_MemoryController_WB_Bhv(//wishbone global signal
				.clk_i(clock),	//wishbone clock from syscon
				.rst_i(~reset),	//wishbone reset from syscon
				//wishbone interface
				.wb_addr_i(com_addr_f),	//32 bit address input
				.wb_data_i(com_data_f),	//32 bit data input
				.wb_data_o(wb_data_o_memctl),	//32 bit data output
				.wb_sel_i(com_sel_f),	//4 bits input Indicates which bytes are valid on the data bus
				.wb_we_i(com_we_f),	//1 bit write enable
				.wb_cyc_i(com_cyc_f),	// 1 bit Encapsulates a valid transfer cycle
				.wb_stb_i(com_stb_f),	//1 bit Indicates a valid transfer.
				.wb_ack_o(wb_ack_o_memctl),	//1 bit Indicates a normal Cycle termina-tion
				.wb_err_o(wb_err_o_memctl),	//1 bit Indicates an abnormal cycle termination
				.wb_rty_o(wb_rty_o_memctl)
);
endmodule