module Arbitrator(in_ALUWriteRequest,
		out_ALUWriteEnable);
input in_ALUWriteRequest;
output out_ALUWriteEnable;
reg out_ALUWriteEnable;

always @(in_ALUWriteRequest)
begin
	if(in_ALUWriteRequest==1'b1)
	begin
		out_ALUWriteEnable=1'b1;
	end
	else
	begin
		out_ALUWriteEnable=1'b0;
	end
end

endmodule