`include	"Def_ALUType.v"
`include	"Def_mem.v"
`include	"Def_BarrelShift.v"
`include	"Def_ConditionField.v"
`include	"Def_Exception.v"
`include	"Def_ARMALU.v"
`include	"Def_StructureParameter.v"
`include	"Def_Mode.v"
`include	"Def_psr.v"
`include	"Def_SimulationParameter.v"
`include	"Def_Decoder.v"
`include	"Def_RegisterFile.v"
`include	"Def_pic.v"

//primitive
`include	"BarrelShift.v"
`include	"complementary.v"
`include	"WordAdder.v"
`include	"mul.v"

`include	"CanGoGen.v"
`include	"InterruptPriority.v"
`include	"PSR_Fresh.v"
`include	"Thumb_2_nnARM.v"
`include	"ALUShell.v"
`include	"Decoder_ARM.v"
`include	"IF.v"
`include	"mem.v"
`include	"psr.v"
`include	"RegisterFile.v"
`include	"ThumbDecoderWarper.v"
`include	"ALUComb.v"

//top core
`include	"nnARMCore.v"

//wishbone conmax module
`include	"wb_conmax_master_if.v"
`include	"wb_conmax_rf.v"
`include	"wb_conmax_slave_if.v"
`include	"wb_conmax_arb.v"
`include	"wb_conmax_msel.v"
`include	"wb_conmax_pri_enc.v"
`include	"wb_conmax_pri_dec.v"
`include	"wb_conmax_top.v"

//master interface to wishbone
`include	"D_Bus2Core.v"
`include	"I_Bus2Core.v"

//interrupt controller
`include	"pic.v"
`include	"pic_wrapper.v"

`include	"timescalar.v"

//behavior level memory module
`include	"MemoryController_WB_Beh.v"

//top level simulation module
`include	"nnARM1.v"

module tb_system;

integer ssycnt;
reg clock,reset;
reg [`InstructionWidth-1:0] TestInstruction;
wire	[`PIC_INTS-1:0]	pic_int;

nnARM inst_nnARM(
		.pic_int(pic_int),
		.clock(clock),
		.reset(reset)
		);
		
initial
begin
	clock=1'b0;
	reset=1'b1;
	#10
	reset=1'b0;
	#500
	reset=1'b1;
	
end

initial
begin
	$readmemh("asc",inst_nnARM.inst_MemoryController_WB_Bhv.Memory);
	//$dumpfile("df");
	//$dumpvars;
	//#600000
	//$dumpflush;
	//$finish;
	//$stop;
end

always
begin
	#(`HalfClockCycle)
		clock=~clock;
end

assign	pic_int={(`PIC_INTS){1'b0}};

endmodule