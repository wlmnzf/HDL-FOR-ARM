//////////////////////////////////////////////////////////////////////////
//		memory controller					//
//									//
//author:ShengYu Shen from national unversity of defense echnology	//
//create time:2001 3 17							//
//////////////////////////////////////////////////////////////////////////


`include "Def_SimulationParameter.v"
`include "Def_StructureParameter.v"
`include "Def_MemoryController.v"

module MemoryController(DataBus,	//data bus ,bidirection
			nWAIT,		//wait for valid value,this signal can not be used directly by external device other than cpu,because after the CPU send out memory request ,the memory can disable this signal only after 1 cycle
			AddressBus,	//address bus
			nRW,		//0 is read,1 is write
			nBW,		//0 is read byte,1 is read word ,not support
			nMREQ,		//0 is memory request,1 is for other device(coprocessor)
			SEQ,		//1 is sequential access mode ,
			MCLK,		//main clock
			nRESET
			);
inout [`DataBusWidth-1:0] DataBus;
//bidir internal DATA buffer
reg   [`DataBusWidth-1:0] D_IN;

output nWAIT;
wire nWAIT;

input [`AddressBusWidth-1:0] AddressBus;
input nRW,nBW,nMREQ,SEQ,MCLK,nRESET;


//memory
reg [`MemoryElementWidth-1:0]	Memory	[`MemorySize-1:0];


//memory access status
reg   [`MemoryAccessStageWidth-1:0] MemoryAccessStage;
reg   nRWOutStand;
reg   SEQOutStand;
reg   [`AddressBusWidth-1:0] AddressBusOutStand;
reg   [`DataBusWidth-1:0]	DataBusOutStand;

//just for test
wire	[`WordWidth-1:0]	M00,M04,M08,M0C;

integer ssycnt;

//just for test
assign	M00={Memory[32'h00000003],Memory[32'h00000002],Memory[32'h00000001],Memory[32'h00000000]};
assign	M04={Memory[32'h00000007],Memory[32'h00000006],Memory[32'h00000005],Memory[32'h00000004]};
assign	M08={Memory[32'h0000000b],Memory[32'h0000000a],Memory[32'h00000009],Memory[32'h00000008]};
assign	M0C={Memory[32'h0000000f],Memory[32'h0000000e],Memory[32'h0000000d],Memory[32'h0000000c]};

assign nWAIT=((MemoryAccessStage==`MemoryAccessStage0 && nMREQ==1'b1) || MemoryAccessStage==`MemoryAccessStage6)?1'b1:1'b0;
assign DataBus=(nRESET==1'b1 && nRWOutStand==1'b0 && (SEQOutStand==1'b0 && MemoryAccessStage==`MemoryAccessStage6 || SEQOutStand==1'b1 && MemoryAccessStage==`MemoryAccessStage2))?D_IN:`DataBusZ;


always @(posedge MCLK or negedge nRESET)
begin
	if(nRESET==1'b0)
	begin
		//memory access stage
		MemoryAccessStage=`MemoryAccessStage0;
		nRWOutStand=1'b0;
		SEQOutStand=1'b0;
		AddressBusOutStand=`AddressBusZero;
		DataBusOutStand=`DataBusZero;

		D_IN=`DataBusZero;
	end
	else if(MemoryAccessStage==`MemoryAccessStage0)  //no outstand access now
	begin
	   if(nMREQ==1'b0)	//a new acess
	   begin
		MemoryAccessStage=MemoryAccessStage+1;
		nRWOutStand=nRW;
		SEQOutStand=SEQ;
		AddressBusOutStand=AddressBus;
		DataBusOutStand=DataBus;
	   end
	   else	//no access
	   begin
		nRWOutStand=1'bz;
		SEQOutStand=1'bz;
		AddressBusOutStand=`AddressBusZ;
		DataBusOutStand=`DataBusZ;

		MemoryAccessStage=`MemoryAccessStage0;
	   end
	end
	else	//there is one outstand access now
	begin
	   MemoryAccessStage=MemoryAccessStage+1;
	   if(SEQOutStand==1'b0)	//non sequential
	   begin
		if(MemoryAccessStage==`MemoryAccessStage6)
		begin
			//the nonsequential access is done,keep data stable for 1 cycle
			if(nRWOutStand==1'b0)	//read
			begin
				D_IN[7:0]=Memory[AddressBusOutStand];
				D_IN[15:8]=Memory[AddressBusOutStand+1];
				D_IN[23:16]=Memory[AddressBusOutStand+2];
				D_IN[31:24]=Memory[AddressBusOutStand+3];
		
				//$display("1 read value %h at address %h",D_IN,AddressBusOutStand);
			end
			else 	//write
			begin
				Memory[AddressBusOutStand]=DataBusOutStand[7:0];
				Memory[AddressBusOutStand+1]=DataBusOutStand[15:8];
				Memory[AddressBusOutStand+2]=DataBusOutStand[23:16];
				Memory[AddressBusOutStand+3]=DataBusOutStand[31:24];
		
				//$display("1 write value %h at address %h ",DataBusOutStand,AddressBusOutStand);
			end
		end
		else if(MemoryAccessStage==`MemoryNonSequentialDelay+1)
		begin
			//access end,data have been output at previous cycle
			MemoryAccessStage=`MemoryAccessStage0;
		end
		else
		begin
			//non sequential no end yet
		end
	   end
	   else//sequential access
	   begin
		if(MemoryAccessStage==`MemorySequentialDelay)
		begin
			//the sequential access is done,keep data stable for 1 cycle
			if(nRWOutStand==1'b0)	//read
			begin
				D_IN[7:0]=Memory[AddressBusOutStand];
				D_IN[15:8]=Memory[AddressBusOutStand+1];
				D_IN[23:16]=Memory[AddressBusOutStand+2];
				D_IN[31:24]=Memory[AddressBusOutStand+3];
		
				//$display("2 read value %h at address %h",D_IN,AddressBusOutStand);
			end
			else 	//write
			begin
				Memory[AddressBusOutStand]=DataBusOutStand[7:0];
				Memory[AddressBusOutStand+1]=DataBusOutStand[15:8];
				Memory[AddressBusOutStand+2]=DataBusOutStand[23:16];
				Memory[AddressBusOutStand+3]=DataBusOutStand[31:24];
		
				//$display("2 write value %h at address %h ",DataBusOutStand,AddressBusOutStand);
			end
		end
		else if(MemoryAccessStage==`MemorySequentialDelay+1)
		begin
			//access end,data have been output at previous cycle
			MemoryAccessStage=`MemoryAccessStage0;
		end
		else
		begin
			//sequential no end yet
		end
	   end
	end//end of one outstanding access

end//end of always
endmodule