module	pic_wrapper(//wishbone global signal
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
				wb_rty_o,
				//interrupt signal to core
				Irq,
				//external interrupt source
				pic_int,
				//pic control the wakeup of the system
				pic_wakeup
);

input clk_i,rst_i;

input	[31:0]	wb_addr_i,wb_data_i;

output	[31:0]	wb_data_o;

input	[7:0]	wb_sel_i;

input	wb_we_i,wb_cyc_i,wb_stb_i;

output	wb_ack_o,wb_err_o,wb_rty_o;

output	Irq;

input	[`PIC_INTS-1:0] pic_int;

output	pic_wakeup;

pic	inst_pic(
	.spr_cs(wb_cyc_i),		//chip select
	.spr_write(wb_we_i),	//write enable
	.spr_addr(wb_addr_i),	//input address from cpu to read the interrupt source
	.spr_dat_i(wb_data_i),	//input data from cpu to write to certain register
	.spr_dat_o(wb_data_o),	//output data for cpu
	.pic_wakeup(pic_wakeup),	//wake up signal
	.irq2core(Irq),
	// external interrupt source
	.pic_int(pic_int),
	//clock and reset signal
	.clock(clk_i),
	.reset(rst_i)		//reset is high active
);


endmodule