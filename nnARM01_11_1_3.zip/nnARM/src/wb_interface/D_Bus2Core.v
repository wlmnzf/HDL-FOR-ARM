module	D_Bus2Core(//signal between mem and D_Bus2Core
		in_MEMAccessAddress,		//data address
		out_DataCacheBus,		//data value for write and read
		in_DataCacheBus,		//data value for write and read
		in_MEMAccessRequest,	//enable access
		in_MEMAccessBW,			//1 means byte,0 means word
		in_MEMAccessRW,			//1 means read,0 means write
		in_MEMAccessHalfWordTransfer,
		in_MEMAccessHalfWordType,
		out_DataCacheWait,		//wait for free	
		//signal goto wishbone
		wb_ack_i,
		wb_addr_o,//
		wb_cyc_o,//
		wb_data_i,
		wb_data_o,//
		wb_err_i,
		wb_rty_i,
		wb_sel_o,//
		wb_stb_o,//
		wb_we_o,//
		clk_i,
		rst_i
);

input	[`AddressBusWidth-1:0]	in_MEMAccessAddress;
input	[`WordWidth-1:0]	in_DataCacheBus;
output	[`WordWidth-1:0]	out_DataCacheBus;
input	in_MEMAccessRequest,in_MEMAccessBW,in_MEMAccessRW;
input	in_MEMAccessHalfWordTransfer;
input	[1:0]	in_MEMAccessHalfWordType;
output	out_DataCacheWait;

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

reg	[7:0]	wb_sel_o;
reg	[`WordWidth-1:0]	wb_data_o;
reg	[`WordWidth-1:0]	out_DataCacheBus;

input	clk_i,rst_i;

reg	[3:0]		tmpsel;
reg	[`WordWidth-1:0]	tmpword;

//assign	wb_sel_o=(in_MEMAccessBW==1'b1)?8'h01:8'h0f;
//assign	wb_data_o=in_DataCacheBus;
//assign	out_DataCacheBus=wb_data_i;
always	@(in_MEMAccessHalfWordTransfer	or
		in_MEMAccessHalfWordType	or
		tmpsel		or
		tmpword	or
		in_MEMAccessBW	or
		in_MEMAccessAddress	or
		in_DataCacheBus	or
		wb_data_i
)
begin
	if(in_MEMAccessHalfWordTransfer==1'b1)
	begin
		case(in_MEMAccessHalfWordType)
		2'b00:
		begin
			//swp
			wb_sel_o=(in_MEMAccessBW==1'b1)?{4'h0,tmpsel}:{4'h0,4'hf};
			wb_data_o=(in_MEMAccessBW==1'b1)?{4{in_DataCacheBus[7:0]}}:in_DataCacheBus;
			out_DataCacheBus=(in_MEMAccessBW==1'b1)?{24'h000000,tmpword[7:0]}:tmpword;
		end
		2'b01://can be load or store unsigned half word
		begin
			//unsigned half word
			wb_sel_o={4'h0,in_MEMAccessAddress[1],in_MEMAccessAddress[1],~in_MEMAccessAddress[1],~in_MEMAccessAddress[1]};
			wb_data_o={in_DataCacheBus[15:0],in_DataCacheBus[15:0]};
			out_DataCacheBus=(in_MEMAccessAddress[1]==1'b1)?{16'h0000,wb_data_i[`WordWidth-1:16]}:{16'h0000,wb_data_i[15:0]};
		end
		2'b10:
		begin
			//signed byte load
			wb_sel_o={4'h0,tmpsel};
			wb_data_o=`WordZero;
			out_DataCacheBus={{24{tmpword[`ByteWidth-1]}},tmpword[`ByteWidth-1:0]};
		end
		default://2'b11
		begin//signed half word
			wb_sel_o={4'h0,in_MEMAccessAddress[1],in_MEMAccessAddress[1],~in_MEMAccessAddress[1],~in_MEMAccessAddress[1]};
			wb_data_o=`WordZero;
			out_DataCacheBus=(in_MEMAccessAddress[1]==1'b1)?{{16{wb_data_i[`WordWidth-1]}},wb_data_i[`WordWidth-1:16]}:{{16{wb_data_i[15]}},wb_data_i[15:0]};
		end
		endcase
	end
	else
	begin//normal byte and word transfer
		if(in_MEMAccessBW==1'b1)
		begin//byte transfer
			wb_sel_o={4'h0,tmpsel};
			wb_data_o={4{in_DataCacheBus[7:0]}};
			out_DataCacheBus={24'h000000,tmpword[`ByteWidth-1:0]};
		end
		else
		begin
			wb_sel_o=8'b0000_1111;
			wb_data_o=in_DataCacheBus;
			out_DataCacheBus=tmpword;
		end
	end
end

always	@(in_MEMAccessAddress	or
	wb_data_i
)
begin
	case(in_MEMAccessAddress[1:0])
	2'b00:
	begin
		tmpsel=4'b0001;
		tmpword=wb_data_i;
	end
	2'b01:
	begin
		tmpsel=4'b0010;
		tmpword={wb_data_i[7:0],wb_data_i[`WordWidth-1:8]};
	end
	2'b10:
	begin
		tmpsel=4'b0100;
		tmpword={wb_data_i[15:0],wb_data_i[`WordWidth-1:16]};
	end
	default:
	begin
		tmpsel=4'b1000;
		tmpword={wb_data_i[23:0],wb_data_i[`WordWidth-1:24]};
	end
	endcase
end

//address signal align to word
assign	wb_addr_o={in_MEMAccessAddress[`AddressBusWidth-1:2],2'b00};

//control signals
assign	wb_cyc_o=in_MEMAccessRequest;

assign	wb_stb_o=in_MEMAccessRequest;

assign	wb_we_o=~in_MEMAccessRW;

assign	out_DataCacheWait=(~wb_ack_i) & wb_cyc_o;

endmodule