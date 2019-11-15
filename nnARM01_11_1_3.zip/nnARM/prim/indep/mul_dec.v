module	mul_dec(parttmp,
		rest,
		bman3bit,
		aman
);

output	[33:0]	parttmp;
output		rest;
reg	[33:0]	parttmp;
reg		rest;

input	[2:0]	bman3bit;
input	[33:0]	aman;

always	@(bman3bit	or
	aman
)
begin
		parttmp=34'b0000_0000_0000_0000_0000_0000_0000_0000_00;
		rest=1'b0;
		case(bman3bit)
		3'b000,3'b111:	
			begin
				parttmp=34'b0000_0000_0000_0000_0000_0000_0000_0000_00;
				rest=1'b0;
			end
		3'b001,3'b010:	
			begin
				parttmp=aman;
				rest=1'b0;
			end
		3'b011:	
			begin
				parttmp={aman[32:0],1'b0};
				rest=1'b0;
			end
		3'b100:	
			begin
				parttmp={~aman[32:0],1'b1};
				rest=1'b1;
			end
		3'b101,3'b110:	
			begin
				parttmp=~aman;
				rest=1'b1;
			end
		endcase
end

endmodule