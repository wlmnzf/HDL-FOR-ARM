module	PSR_Fresh(	//varies CPSR input
		in_CPSR_StatusRegisters,	//cpsr come from StatusRegisters
		in_CPSR_ALUShell,	//CPSR come from ALUShell stage
		in_ALUWriteEnable,	// if current alu have valid output
		in_CPSR_MEM,	//cpsr come from MEM stage
		in_MEMWriteEnable,	//if current mem have valid output
		in_CPSR_WB,
		in_WBWriteEnable,
		
		//output of fresh cpsr
		out_CPSR_Fresh,
		out_IsInPrivilegedMode
);

input	[`WordWidth-1:0]	in_CPSR_StatusRegisters,in_CPSR_ALUShell,in_CPSR_MEM,in_CPSR_WB;
input				in_ALUWriteEnable,in_MEMWriteEnable,in_WBWriteEnable;

output	[`WordWidth-1:0]	out_CPSR_Fresh;
output				out_IsInPrivilegedMode;

reg	[`WordWidth-1:0]	out_CPSR_Fresh;
reg				out_IsInPrivilegedMode;


always	@(in_CPSR_StatusRegisters	or
	in_CPSR_ALUShell	or
	in_CPSR_MEM	or
	in_CPSR_WB	or
	in_ALUWriteEnable	or
	in_MEMWriteEnable	or
	in_WBWriteEnable
	)
begin
	if(in_ALUWriteEnable==1'b1)
		out_CPSR_Fresh=in_CPSR_ALUShell;
	else if(in_MEMWriteEnable==1'b1)
		out_CPSR_Fresh=in_CPSR_MEM;
	else if(in_WBWriteEnable==1'b1)
		out_CPSR_Fresh=in_CPSR_WB;
	else
		out_CPSR_Fresh=in_CPSR_StatusRegisters;
		
end

always	@(out_CPSR_Fresh)
begin
	if(out_CPSR_Fresh[4:0]==`MODE_USER)
		out_IsInPrivilegedMode=1'b0;
	else
		out_IsInPrivilegedMode=1'b1;
end

endmodule