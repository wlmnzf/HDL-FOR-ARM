module	pic(
	spr_cs,		//chip select
	spr_write,	//write enable
	spr_addr,	//input address from cpu to read the interrupt source
	spr_dat_i,	//input data from cpu to write to certain register
	spr_dat_o,	//output data for cpu
	pic_wakeup,	//wake up signal
	irq2core,
	// external interrupt source
	pic_int,
	//clock and reset signal
	clock,
	reset		//reset is high active
);

input		spr_cs;		// SPR CS
input		spr_write;	// SPR Write
input	[31:0]	spr_addr;	// SPR Address
input	[31:0]	spr_dat_i;	// SPR Write Data
output	[31:0]	spr_dat_o;	// SPR Read Data
output		pic_wakeup;	// Wakeup to the PM
output		irq2core;	// High priority interrupt
				// exception request


input		clock;		// Clock
input		reset;		// Reset

// external interrupt source
input	[`PIC_INTS-1:0]	pic_int;// Interrupt inputs

// PIC Mask Register bits 
//interrupt 0 and 1 is unmaskable interrupt
//1 means enable and 0 means disable
reg	[`PIC_INTS-1:2]	picmr;	// PICMR bits for every interrupt

// PIC Status Register bits
reg	[`PIC_INTS-1:0]	picsr;	// PICSR bits

// Internal wires & regs
wire		picmr_sel;	// PICMR select
wire		picsr_sel;	// PICSR select
wire	[`PIC_INTS-1:0] um_ints;// Unmasked interrupts
reg	[31:0] 	spr_dat_o;	// SPR data out

//
// PIC registers address decoder
//
assign picmr_sel = (spr_cs && (spr_addr[`PICOFS_BITS] == `PIC_OFS_PICMR)) ? 1'b1 : 1'b0;
assign picsr_sel = (spr_cs && (spr_addr[`PICOFS_BITS] == `PIC_OFS_PICSR)) ? 1'b1 : 1'b0;

// Write to PICMR
always @(posedge clock or posedge reset)
begin
	if (reset)
		picmr <= {1'b1, {`PIC_INTS-3{1'b0}}};
	else if (picmr_sel && spr_write)
	begin
		picmr <= #1 spr_dat_i[`PIC_INTS-1:2];
	end
end


// Write to PICSR, both CPU and external ints
always @(posedge clock or posedge reset)
begin
	if (reset)
		picsr <= {`PIC_INTS-2{1'b0}};
	else if (picsr_sel && spr_write)
	begin
		//note that the value may not equal to the value you write, because some interrupt happen at the same time must be record in it
		picsr <= #1 spr_dat_i[`PIC_INTS-1:0] | um_ints;
	end
	else
		picsr <= #1 picsr | um_ints;
end

// Read PIC registers
always @(spr_addr or picmr or picsr)
begin
	case (spr_addr[`PICOFS_BITS])
		`PIC_OFS_PICMR: begin//read mask register
					spr_dat_o[`PIC_INTS-1:0] = {picmr, 2'b0};
					spr_dat_o[31:`PIC_INTS] = {32-`PIC_INTS{1'b0}};
				end
		default:	begin//read status register
					spr_dat_o[`PIC_INTS-1:0] = picsr;
					spr_dat_o[31:`PIC_INTS] = {32-`PIC_INTS{1'b0}};
				end
	endcase
end

//
// Unmasked interrupts
//
assign um_ints = pic_int & {picmr, 2'b11};


//
// Generate irq2core
//
assign irq2core = (um_ints) ? 1'b1 : 1'b0;

//
// Assert pic_wakeup when either  irq2core is asserted
//
assign pic_wakeup = irq2core;


endmodule
