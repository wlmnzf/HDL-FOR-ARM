`include "Def_StructureParameter.v"

module	DataCacheMemory(	in_CacheMemoryAccessEnable,
			in_CacheMemoryAccessRW,
			in_CacheMemoryAccessBW,
			in_CacheMemoryAccessAddress,
			in_CacheMemoryWriteValue,
			out_CacheMemoryReadValue,
			clock,
			reset
);


//memory of the cache
reg	[`ByteWidth-1:0]	Memory [255:0];

always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
	end//reset==1'b0
	else
	begin
		if(in_CacheMemoryAccessEnable==1'b1)
		begin
			//can access memory
			if(in_CacheMemoryAccessRW==1'b1)
			begin
				//read
				if(in_CacheMemoryAccessBW==1'b1)
				begin
					//read a byte
					out_CacheMemoryReadValue={`ByteNumberInWord{Memory[in_CacheMemoryAccessAddress]}};
				end//in_CacheMemoryAccessBW==1'b1
				else
				begin
					//read a word
					out_CacheMemoryReadValue={Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b11}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b10}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b01}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b00}]};
				end//in_CacheMemoryAccessBW!=1'b1
			end//in_CacheMemoryAccessRW==1'b1
			else
			begin
				//write
				if(in_CacheMemoryAccessBW==1'b1)
				begin
					//write a byte
					Memory[in_CacheMemoryAccessAddress]=in_CacheMemoryWriteValue[`ByteWidth-1:0];
				end//in_CacheMemoryAccessBW==1'b1
				else
				begin
					//write a word
					{Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b11}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b10}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b01}],Memory[{in_CacheMemoryAccessAddress[`AddressBusWidth-1:ByteSelectWidthInWord],2'b00}]}=in_CacheMemoryWriteValue;
				end//in_CacheMemoryAccessBW!=1'b1
			end//in_CacheMemoryAccessRW!=1'b1
		end//in_CacheMemoryAccessEnable==1'b1
	end//reset!=1'b0
end

endmodule