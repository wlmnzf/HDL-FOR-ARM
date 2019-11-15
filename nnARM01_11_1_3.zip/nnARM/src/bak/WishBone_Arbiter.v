module	WishBone_Arbiter(//some cyc signal from mater,1 with the highest right
		wb_cyc_1,
		wb_cyc_2,
		//who can access
		wb_gnt_1,
		wb_gnt_2,
		//if the second have finish access
		wb_ack_2,
		clk_i,
		rst_i
);

input	wb_cyc_1,wb_cyc_2,wb_ack_2;

output	wb_gnt_1,wb_gnt_2;

input	clk_i,rst_i;

reg	[1:0]	State;
reg	[1:0]	Next_State;

always	@(State	or
	wb_cyc_2	or
	wb_cyc_1	or
	wb_ack_2
)
begin
	case({wb_cyc_2,wb_cyc_1})
	2'b00:
		Next_State=2'b00;
	2'b10:
		Next_State=2'b10;
	2'b01:
		Next_State=2'b01;
	default:
	begin
		//both want
		case(State)
		2'b10:
		begin
			//only low right have access
			if(wb_ack_2==1'b1)	//ack come back,
				Next_State=2'b01;
			else			//ack have not come back
				Next_State=2'b10;
		end			
		default:
			Next_State=2'b01;
		endcase
	end
	endcase
end

always	@(posedge clk_i or posedge rst_i)
begin
	if(rst_i==1'b1)	//wishbone reset active high
		State=2'b00;
	else
		State=Next_State;
end

assign	{wb_gnt_2,wb_gnt_1}=State;
endmodule