//////////////////////////////////////////////////////////////////////////
//		instruction cache controller				//
//									//
//author:ShengYu Shen from National University of Defense Technology	//
//create time:2001 3 22							//
//Note:the instruction cache block is 128bit,the size is about 8k	//
//the InstructionOut is 128bit,and it can transmit a whole cache block	//
//one time.
//////////////////////////////////////////////////////////////////////////

`include "Def_InstructionCacheController.v"
`include "Def_StructureParameter.v"

module InstructionCacheController(InstructionOut,
			InstructionWait,
			InstructionAddress,
			InstructionRequest,
			//below is the memory access
			MemoryBus,
			MemoryAddress,
			MemoryRequest,
			nMemoryWait,
			clock,
			reset
			);

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//		the ports declaration			//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
output [`InstructionCacheLineWidth-1:0] InstructionOut;
output InstructionWait;

reg [`InstructionCacheLineWidth-1:0] InstructionOut;
reg InstructionWait;

input [`AddressBusWidth-1:0] InstructionAddress;
input InstructionRequest;

input [`MemoryBusWidth-1:0] MemoryBus;
input nMemoryWait;
output [`AddressBusWidth-1:0] MemoryAddress;
output MemoryRequest;

reg [`AddressBusWidth-1:0] MemoryAddress;
reg MemoryRequest;

input clock,reset;

reg [127:0] S0_L0,S0_L1,S0_L2,S0_L3;
reg [127:0] S1_L0,S1_L1,S1_L2,S1_L3;
reg [127:0] S2_L0,S2_L1,S2_L2,S2_L3;
reg [127:0] S3_L0,S3_L1,S3_L2,S3_L3;

//the tag for the correspone line
reg [`AddressBusWidth-1:0] tag00,tag01,tag02,tag03;
reg [`AddressBusWidth-1:0] tag10,tag11,tag12,tag13;
reg [`AddressBusWidth-1:0] tag20,tag21,tag22,tag23;
reg [`AddressBusWidth-1:0] tag30,tag31,tag32,tag33;

//if the correspone line valid?
reg V00,V01,V02,V03;
reg V10,V11,V12,V13;
reg V20,V21,V22,V23;
reg V30,V31,V32,V33;

//which line in this section have been previous access 
reg [1:0] PrevAccess0,PrevAccess1,PrevAccess2,PrevAccess3;


//memory request status
reg [`ByteWidth-1:0] Status;
reg [`ByteWidth-1:0] WordCount;
reg [`AddressBusWidth-1:0] AddressStore;
reg [127:0]	LineStore;


//the output to the prefetch buffer
always @(tag00 or tag01 or tag02 or tag03 
	or tag10 or tag11 or tag12 or tag13 
	or tag20 or tag21 or tag22 or tag23 
	or tag30 or tag31 or tag32 or tag33 
	or S0_L0 or S0_L1 or S0_L2 or S0_L3
	or S1_L0 or S1_L1 or S1_L2 or S1_L3
	or S2_L0 or S2_L1 or S2_L2 or S2_L3
	or S3_L0 or S3_L1 or S3_L2 or S3_L3
	or V00 or V01 or V02 or V03
	or V10 or V11 or V12 or V13
	or V20 or V21 or V22 or V23
	or V30 or V31 or V32 or V33
	or InstructionAddress
	or InstructionRequest
	)
begin
   if(InstructionRequest==1'b1)
   begin
	case(InstructionAddress[5:4])
	2'b00:
		//section 0
		if(V00==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag00[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S0_L0;
		end
		else if(V01==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag01[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S0_L1;
		end
		else if(V02==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag02[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S0_L2;
		end
		else if(V03==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag03[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S0_L3;
		end
		else
		begin
			InstructionWait=1'b1;
			InstructionOut=`InstructionZ;
		end
	2'b01:
		//section 1
		if(V10==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag10[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S1_L0;
		end
		else if(V11==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag11[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S1_L1;
		end
		else if(V12==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag12[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S1_L2;
		end
		else if(V13==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag13[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S1_L3;
		end
		else
		begin
			InstructionWait=1'b1;
			InstructionOut=`InstructionZ;
		end
	2'b10:
		//section 2
		if(V20==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag20[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S2_L0;
		end
		else if(V21==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag21[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S2_L1;
		end
		else if(V22==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag22[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S2_L2;
		end
		else if(V23==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag23[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S2_L3;
		end
		else
		begin
			InstructionWait=1'b1;
			InstructionOut=`InstructionZ;
		end
	2'b11:
		//section 3
		if(V30==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag30[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S3_L0;
		end
		else if(V31==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag31[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S3_L1;
		end
		else if(V32==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag32[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S3_L2;
		end
		else if(V33==1'b1 && InstructionAddress[`AddressBusWidth-1:6]==tag33[`AddressBusWidth-1:6])
		begin
			InstructionWait=1'b0;
			InstructionOut=S3_L3;
		end
		else
		begin
			InstructionWait=1'b1;
			InstructionOut=`InstructionZ;
		end
	endcase
   end
   else
   begin
   	InstructionWait=1'b0;
   	InstructionOut=`InstructionZ;
   end
end

//read from memory
always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		S0_L0=`InstructionCacheLineZero;
		S0_L1=`InstructionCacheLineZero;
		S0_L2=`InstructionCacheLineZero;
		S0_L3=`InstructionCacheLineZero;

		S1_L0=`InstructionCacheLineZero;
		S1_L1=`InstructionCacheLineZero;
		S1_L2=`InstructionCacheLineZero;
		S1_L3=`InstructionCacheLineZero;

		S2_L0=`InstructionCacheLineZero;
		S2_L1=`InstructionCacheLineZero;
		S2_L2=`InstructionCacheLineZero;
		S2_L3=`InstructionCacheLineZero;

		S3_L0=`InstructionCacheLineZero;
		S3_L1=`InstructionCacheLineZero;
		S3_L2=`InstructionCacheLineZero;
		S3_L3=`InstructionCacheLineZero;

		tag00=`AddressBusZero;
		tag01=`AddressBusZero;
		tag02=`AddressBusZero;
		tag03=`AddressBusZero;
		
		tag10=`AddressBusZero;
		tag11=`AddressBusZero;
		tag12=`AddressBusZero;
		tag13=`AddressBusZero;

		tag20=`AddressBusZero;
		tag21=`AddressBusZero;
		tag22=`AddressBusZero;
		tag23=`AddressBusZero;

		tag30=`AddressBusZero;
		tag31=`AddressBusZero;
		tag32=`AddressBusZero;
		tag33=`AddressBusZero;

		V00=1'b0;
		V01=1'b0;
		V02=1'b0;
		V03=1'b0;

		V10=1'b0;
		V11=1'b0;
		V12=1'b0;
		V13=1'b0;

		V20=1'b0;
		V21=1'b0;
		V22=1'b0;
		V23=1'b0;

		V30=1'b0;
		V31=1'b0;
		V32=1'b0;
		V33=1'b0;
		
		PrevAccess0=2'b00;
		PrevAccess1=2'b00;
		PrevAccess2=2'b00;
		PrevAccess3=2'b00;

		WordCount=`ByteZero;
		Status=`InstructionCacheMemoryAccess_Normal;
		AddressStore=`AddressBusZero;
		LineStore=128'h0000_0000_0000_0000_0000_0000_0000_0000;
	end
	else
	begin
		//deal with the read from memory
		case(Status)
		`InstructionCacheMemoryAccess_Normal:
			if(InstructionWait==1'b1)
			begin
				WordCount=8'b00000001;
				//send out the read request
				MemoryAddress={InstructionAddress[`AddressBusWidth-1:4],4'b0000};
				AddressStore=MemoryAddress;
				MemoryRequest=1'b1;
				Status=`InstructionCacheMemoryAccess_Wait;
				//$monitor($time,"		instruction cache miss at	%h",InstructionAddress);
			end
		`InstructionCacheMemoryAccess_Wait:
			if(nMemoryWait==1'b1)
			begin
				//now the result come
				case(WordCount)
				8'b0000_0001:
					begin
						WordCount=8'b0000_0010;
						LineStore[31:0]=MemoryBus;
						//continue to send out request
						MemoryAddress={InstructionAddress[`AddressBusWidth-1:4],4'b0100};
						MemoryRequest=1'b1;
					end
				8'b0000_0010:
					begin
						WordCount=8'b0000_0011;
						LineStore[63:32]=MemoryBus;
						//continue to send out request
						MemoryAddress={InstructionAddress[`AddressBusWidth-1:4],4'b1000};
						MemoryRequest=1'b1;
					end
				8'b0000_0011:
					begin
						WordCount=8'b0000_0100;
						LineStore[95:64]=MemoryBus;
						//continue to send out request
						MemoryAddress={InstructionAddress[`AddressBusWidth-1:4],4'b1100};
						MemoryRequest=1'b1;
					end
				8'b0000_0100:
					begin
						WordCount=`ByteZero;
						LineStore[127:96]=MemoryBus;
						//NOTE: store LineStore to cache line
						//enable the V and tag
						MemoryRequest=1'b0;
						Status=`InstructionCacheMemoryAccess_Normal;
						//$monitor($time,"		fetch back from memory at:	%h",AddressStore);
						case (AddressStore[5:4])
						2'b00:	//section0
							begin
								if(V00==1'b0)
								begin
									//line0 is blank
									V00=1'b1;
									tag00=AddressStore;
									S0_L0=LineStore;
									PrevAccess0=2'b00;
								end
								else if(V01==1'b0)
								begin
									//line1 is blank
									V01=1'b1;
									tag01=AddressStore;
									S0_L1=LineStore;
									PrevAccess0=2'b01;
								end
								else if(V02==1'b0)
								begin
									//line2 is blank
									V02=1'b1;
									tag02=AddressStore;
									S0_L2=LineStore;
									PrevAccess0=2'b10;
								end
								else if(V03==1'b0)
								begin
									//line3 is blank
									V03=1'b1;
									tag03=AddressStore;
									S0_L3=LineStore;
									PrevAccess0=2'b11;
								end
								else
								begin
									//none avilable
									case (PrevAccess0)
									2'b00:
										begin
											V01=1'b1;
											tag01=AddressStore;
											S0_L1=LineStore;
											PrevAccess0=2'b01;
										end
									2'b01:
										begin
											V02=1'b1;
											tag02=AddressStore;
											S0_L2=LineStore;
											PrevAccess0=2'b10;
										end
									2'b10:
										begin
											V03=1'b1;
											tag03=AddressStore;
											S0_L3=LineStore;
											PrevAccess0=2'b11;
										end
									2'b11:
										begin
											V00=1'b1;
											tag00=AddressStore;
											S0_L0=LineStore;
											PrevAccess0=2'b00;
										end
									endcase
								end
							end
						2'b01:	//section1
							begin
								if(V10==1'b0)
								begin
									//line0 is blank
									V10=1'b1;
									tag10=AddressStore;
									S1_L0=LineStore;
									PrevAccess1=2'b00;
								end
								else if(V11==1'b0)
								begin
									//line1 is blank
									V11=1'b1;
									tag11=AddressStore;
									S1_L1=LineStore;
									PrevAccess1=2'b01;
								end
								else if(V12==1'b0)
								begin
									//line2 is blank
									V12=1'b1;
									tag12=AddressStore;
									S1_L2=LineStore;
									PrevAccess1=2'b10;
								end
								else if(V13==1'b0)
								begin
									//line3 is blank
									V13=1'b1;
									tag13=AddressStore;
									S1_L3=LineStore;
									PrevAccess1=2'b11;
								end
								else
								begin
									//none avilable
									case (PrevAccess1)
									2'b00:
										begin
											V11=1'b1;
											tag11=AddressStore;
											S1_L1=LineStore;
											PrevAccess1=2'b01;
										end
									2'b01:
										begin
											V12=1'b1;
											tag12=AddressStore;
											S1_L2=LineStore;
											PrevAccess1=2'b10;
										end
									2'b10:
										begin
											V13=1'b1;
											tag13=AddressStore;
											S1_L3=LineStore;
											PrevAccess1=2'b11;
										end
									2'b11:
										begin
											V10=1'b1;
											tag10=AddressStore;
											S1_L0=LineStore;
											PrevAccess1=2'b00;
										end
									endcase
								end
							end

						2'b10:	//section2
							begin
								if(V20==1'b0)
								begin
									//line0 is blank
									V20=1'b1;
									tag20=AddressStore;
									S2_L0=LineStore;
									PrevAccess2=2'b00;
								end
								else if(V21==1'b0)
								begin
									//line1 is blank
									V21=1'b1;
									tag21=AddressStore;
									S2_L1=LineStore;
									PrevAccess2=2'b01;
								end
								else if(V22==1'b0)
								begin
									//line2 is blank
									V22=1'b1;
									tag22=AddressStore;
									S2_L2=LineStore;
									PrevAccess2=2'b10;
								end
								else if(V23==1'b0)
								begin
									//line3 is blank
									V23=1'b1;
									tag23=AddressStore;
									S2_L3=LineStore;
									PrevAccess2=2'b11;
								end
								else
								begin
									//none avilable
									case (PrevAccess2)
									2'b00:
										begin
											V21=1'b1;
											tag21=AddressStore;
											S2_L1=LineStore;
											PrevAccess2=2'b01;
										end
									2'b01:
										begin
											V22=1'b1;
											tag22=AddressStore;
											S2_L2=LineStore;
											PrevAccess2=2'b10;
										end
									2'b10:
										begin
											V23=1'b1;
											tag23=AddressStore;
											S2_L3=LineStore;
											PrevAccess2=2'b11;
										end
									2'b11:
										begin
											V20=1'b1;
											tag20=AddressStore;
											S2_L0=LineStore;
											PrevAccess2=2'b00;
										end
									endcase
								end
							end

						2'b11:	//section3
							begin
								if(V30==1'b0)
								begin
									//line0 is blank
									V30=1'b1;
									tag30=AddressStore;
									S3_L0=LineStore;
									PrevAccess3=2'b00;
								end
								else if(V31==1'b0)
								begin
									//line1 is blank
									V31=1'b1;
									tag31=AddressStore;
									S3_L1=LineStore;
									PrevAccess3=2'b01;
								end
								else if(V32==1'b0)
								begin
									//line2 is blank
									V32=1'b1;
									tag32=AddressStore;
									S3_L2=LineStore;
									PrevAccess3=2'b10;
								end
								else if(V33==1'b0)
								begin
									//line3 is blank
									V33=1'b1;
									tag33=AddressStore;
									S3_L3=LineStore;
									PrevAccess3=2'b11;
								end
								else
								begin
									//none avilable
									case (PrevAccess3)
									2'b00:
										begin
											V31=1'b1;
											tag31=AddressStore;
											S3_L1=LineStore;
											PrevAccess3=2'b01;
										end
									2'b01:
										begin
											V32=1'b1;
											tag32=AddressStore;
											S3_L2=LineStore;
											PrevAccess3=2'b10;
										end
									2'b10:
										begin
											V33=1'b1;
											tag33=AddressStore;
											S3_L3=LineStore;
											PrevAccess3=2'b11;
										end
									2'b11:
										begin
											V30=1'b1;
											tag30=AddressStore;
											S3_L0=LineStore;
											PrevAccess3=2'b00;
										end
									endcase
								end
							end

						endcase
					end
				endcase
			end
		endcase
	end
end


endmodule