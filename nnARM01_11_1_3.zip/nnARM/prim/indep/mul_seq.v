module	mul(out_MulResult,
		out_finish,
		in_a,
		in_b,
		in_LongMulSig,
		in_start,
		in_CanMEMGo;
		clock,
		reset
);

input	[31:0]	in_a,in_b;
input	in_LongMulSig,in_start;

output	[65:0]	out_MulResult;
output		out_finish;

reg	[4:0]	mul_state;
reg	[33:0]	amanadj;
reg	[32:0]	bmanadj;
reg	[31:0]	rest;
reg	[65:0]	resultman;


reg	[4:0]	Next_mul_state;
reg	[33:0]	Next_amanadj;
reg	[32:0]	Next_bmanadj;
reg	[31:0]	Next_rest;
reg	[65:0]	Next_resultman;

wire	[33:0]	parttmp;

always	@()
begin
	
	case(mul_state)
	endcase
end

endmodule