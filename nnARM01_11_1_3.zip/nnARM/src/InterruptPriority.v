module	InterruptPriority(//interrupt signal
			Fiq,
			Irq,
			//interrupt mask
			FiqDisable,
			IrqDisable,
			//output interrupt signal
			TrueFiq,
			TrueIrq
			);
			
input	Fiq,Irq,FiqDisable,IrqDisable;
output	TrueFiq,TrueIrq;

reg	TrueIrq;

//decide TrueFiq
assign	TrueFiq=(FiqDisable==1'b1)?1'b0:Fiq;

//decide TrueIrq
always	@(Fiq	or
	Irq	or
	FiqDisable	or
	IrqDisable	or
	TrueFiq
	)
begin
	if(IrqDisable==1'b1)
		TrueIrq=1'b0;
	else if(TrueFiq==1'b1)
		TrueIrq=1'b0;
	else
		TrueIrq=Irq;
end

endmodule