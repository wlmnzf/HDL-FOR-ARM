module StatusRegisters(	//change of state
			in_IfChangeState,	//this port means only SWI or FIQ or IRQ or UND or ABT
			in_ChangeStateAction,
			//write to register
			in_CPSRWriteEnable,
			in_CPSRWriteValue,
			in_SPSRWriteEnable,
			in_SPSRWriteValue,
			//output of status register
			out_CPSR,
			out_SPSR,
			clock,
			reset			
);

input					in_IfChangeState;
input	[4:0]				in_ChangeStateAction;

input					in_CPSRWriteEnable;
input	[`WordWidth-1:0]		in_CPSRWriteValue;

input					in_SPSRWriteEnable;
input	[`WordWidth-1:0]		in_SPSRWriteValue;

output	[`WordWidth-1:0]		out_CPSR,out_SPSR;
reg	[`WordWidth-1:0]		out_CPSR,out_SPSR;

input	clock,reset;

//////////////////////////////////////////
//////////////////////////////////////////
// status register			//
//////////////////////////////////////////
//////////////////////////////////////////
reg	[`WordWidth-1:0]		CPSR,SPSR_FIQ,SPSR_SVC,SPSR_ABT,SPSR_IRQ,SPSR_UND;

reg	[`WordWidth-1:0]		Next_CPSR,Next_SPSR_FIQ,Next_SPSR_SVC,Next_SPSR_ABT,Next_SPSR_IRQ,Next_SPSR_UND;

reg	[4:0]				Mode2Use;

//decide the out_CPSR and out_SPSR
always @(CPSR or
	SPSR_FIQ or
	SPSR_SVC or
	SPSR_ABT or
	SPSR_IRQ or
	SPSR_UND
)
begin
	out_CPSR=CPSR;
	
	//decide out_SPSR
	out_SPSR=`WordZero;
	case (CPSR[4:0])
	`MODE_USER:
		out_SPSR=`WordZero;
	`MODE_FIQ:
		out_SPSR=SPSR_FIQ;
	`MODE_IRQ:
		out_SPSR=SPSR_IRQ;
	`MODE_SVC:
		out_SPSR=SPSR_SVC;
	`MODE_ABT:
		out_SPSR=SPSR_ABT;
	`MODE_UND:
		out_SPSR=SPSR_UND;
	endcase
end

always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		CPSR={24'h000000,3'b110,`MODE_SVC};
		SPSR_FIQ=32'h00000000;
		SPSR_SVC=32'h00000000;
		SPSR_ABT=32'h00000000;
		SPSR_IRQ=32'h00000000;
		SPSR_UND=32'h00000000;
	end
	else
	begin
		CPSR=Next_CPSR;
		SPSR_FIQ=Next_SPSR_FIQ;
		SPSR_SVC=Next_SPSR_SVC;
		SPSR_ABT=Next_SPSR_ABT;
		SPSR_IRQ=Next_SPSR_IRQ;
		SPSR_UND=Next_SPSR_UND;
	end
end

//decide the next state of varias psr register
always @(in_CPSRWriteEnable	or
	in_CPSRWriteValue	or
	in_SPSRWriteEnable	or
	in_SPSRWriteValue	or
	CPSR			or
	SPSR_FIQ		or
	SPSR_SVC		or
	SPSR_ABT		or
	SPSR_IRQ		or
	SPSR_UND		or
	in_IfChangeState	or
	in_ChangeStateAction
)
begin
	//write to cpsr
	if(in_IfChangeState==1'b1)
	begin
		//an exception arise
		Next_CPSR=in_CPSRWriteValue;
	end
	else if(in_CPSRWriteEnable==1'b1)
	begin
		//can write
		if(CPSR[4:0]==`MODE_USER)
		begin
			//can only modify condition code
			Next_CPSR={in_CPSRWriteValue[31:28],CPSR[27:0]};
		end
		else
		begin
			Next_CPSR=in_CPSRWriteValue;
		end
	end
	else
	begin
		//can not write
		Next_CPSR=CPSR;
	end
	
	//write to spsr
	//when i can access spsr,it is not at user mode,so i can access all bit of spsr
	if(in_SPSRWriteEnable==1'b1)
	begin
	   Next_SPSR_FIQ=SPSR_FIQ;
	   Next_SPSR_SVC=SPSR_SVC;
	   Next_SPSR_ABT=SPSR_ABT;
	   Next_SPSR_IRQ=SPSR_IRQ;
	   Next_SPSR_UND=SPSR_UND;
	   
	   
	   if(in_IfChangeState==1'b1)
	   begin
	   	//an exception, so just use input in_ChangeStateAction
	   	Mode2Use=in_ChangeStateAction;
	   end
	   else
	   begin
	   	//do not change state,just write spsr according to current cpsr
	   	Mode2Use=CPSR[4:0];
	   end
	   
	   case (Mode2Use)
	   //MODE_USER have no spsr
	   `MODE_FIQ:
			Next_SPSR_FIQ=in_SPSRWriteValue;
	   `MODE_IRQ:
			Next_SPSR_IRQ=in_SPSRWriteValue;
	   `MODE_SVC:
			Next_SPSR_SVC=in_SPSRWriteValue;
	   `MODE_ABT:
			Next_SPSR_ABT=in_SPSRWriteValue;
	   `MODE_UND:
			Next_SPSR_UND=in_SPSRWriteValue;
	   endcase
	
	end
	else
	begin
		//can not write
		Next_SPSR_FIQ=SPSR_FIQ;
		Next_SPSR_SVC=SPSR_SVC;
		Next_SPSR_ABT=SPSR_ABT;
		Next_SPSR_IRQ=SPSR_IRQ;
		Next_SPSR_UND=SPSR_UND;
	end
end
endmodule