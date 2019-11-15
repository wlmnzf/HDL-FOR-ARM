//////////////////////////////////////////////////////////////////
//			the instruction prefetch buffer		//
//Note:the orgnization of the Instruction PreFetche buffer	//
//serious depend on the ASIC library you can obtain from	//
//manufatory,
//i have assume that the cache is 1 cycle delay,if you have the //
//other delay value you must change the fetch instruction 	//
//code 								//
//when the prefetched buffer is missed,the IF pipeline stage	//
//must wait until it fetch instruction back			//
//i assume a 4 word instruction cache line			//
//////////////////////////////////////////////////////////////////

`include "Def_StructureParameter.v"
`include "Def_InstructionPreFetch.v"
`include "Def_InstructionCacheController.v"

module InstructionPreFetch(Instruction,
				Wait,
				Address,
				//above is the fetched instruction go to pipeline
				//below is the prefetched instruction come from cache or memory
				PreFetchedInstructions,
				PreFetchedWait,
				PreFetchedAddress,
				PreFetchedRequest,
				clock,
				reset);

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//	input and output declaration			//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
output [`InstructionWidth-1:0] Instruction;
output Wait;
wire [`InstructionWidth-1:0] Instruction;
wire Wait;
input [`AddressBusWidth-1:0] Address;
input clock,reset;

input [`InstructionCacheLineWidth-1:0] PreFetchedInstructions;
input PreFetchedWait;
output [`AddressBusWidth-1:0] PreFetchedAddress;
output PreFetchedRequest;

reg [`AddressBusWidth-1:0] PreFetchedAddress;
reg PreFetchedRequest;
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//		memory of the prefetch buffer		//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
reg [`InstructionWidth-1:0] Instruction0;
reg [`InstructionWidth-1:0] Instruction1;
reg [`InstructionWidth-1:0] Instruction2;
reg [`InstructionWidth-1:0] Instruction3;
reg [`InstructionWidth-1:0] Instruction4;
reg [`InstructionWidth-1:0] Instruction5;
reg [`InstructionWidth-1:0] Instruction6;
reg [`InstructionWidth-1:0] Instruction7;

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//	address of the two block prefetch instruction	//
//	they store the address of first instruction 	//
//that is to say:their 3:0 is 4'b0000			//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
reg [`AddressBusWidth-1:0] Address0;
reg [`AddressBusWidth-1:0] Address1;
reg FirstHalfGot,SecondHalfGot;

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//		the selected instruction		//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
reg [`InstructionWidth-1:0] tmpInstruction;

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//		memory access status			//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

reg [`ByteWidth-1:0]  Status;
//store the address of first instruction of the fetched cache block
reg [`AddressBusWidth-1:0] AddressStore;

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//signal indicate that if i have desire instruction	//
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

wire NoThisInstruction,ForwardNoThisInstruction;
wire [`AddressBusWidth-1:0] ForwardAddress;

//select out the desire instruction
always @(Instruction0 
	or Instruction1 
	or Instruction2 
	or Instruction3  
	or Instruction4 
	or Instruction5 
	or Instruction6  
	or Instruction7 
	or Address0 
	or Address1 
	or Address)
begin
	//in the first half of cache block
	if(Address[`AddressBusWidth-1:4]==Address0[`AddressBusWidth-1:4])
	begin
		case (Address[3:2])
		2'b00:
			tmpInstruction=Instruction0;
		2'b01:
			tmpInstruction=Instruction1;
		2'b10:
			tmpInstruction=Instruction2;
		2'b11:
			tmpInstruction=Instruction3;
		default: begin tmpInstruction=`InstructionZero; end
		endcase
	end
	//in the second half
	else if(Address[`AddressBusWidth-1:4]==Address1[`AddressBusWidth-1:4])
	begin
		case (Address[3:2])
		2'b00:
			tmpInstruction=Instruction4;
		2'b01:
			tmpInstruction=Instruction5;
		2'b10:
			tmpInstruction=Instruction6;
		2'b11:
			tmpInstruction=Instruction7;
		default: begin tmpInstruction=`InstructionZero; end
		endcase
	end
	//not in prefetched buffer
	else
	begin
		//now i do not have your desired instruction
		tmpInstruction=`InstructionZero;
	end
end

//if i can output current selected instruction
assign NoThisInstruction=((Address[`AddressBusWidth-1:4]!=Address0[`AddressBusWidth-1:4] || FirstHalfGot==1'b0) && (Address[`AddressBusWidth-1:4]!=Address1[`AddressBusWidth-1:4] || SecondHalfGot==1'b0))?1'b1:1'b0;
assign Wait=NoThisInstruction;
assign Instruction=Wait?`InstructionZ:tmpInstruction;

assign ForwardAddress=Address+{32'b0000_0000_0000_0000_0000_0000_0001_0000};
assign ForwardNoThisInstruction=((ForwardAddress[`AddressBusWidth-1:4]!=Address0[`AddressBusWidth-1:4] || FirstHalfGot==1'b0) && (ForwardAddress[`AddressBusWidth-1:4]!=Address1[`AddressBusWidth-1:4] || SecondHalfGot==1'b0))?1'b1:1'b0;


//////////////////////////////////////////////////////////
//below is fetch instruction from cahce			//
//////////////////////////////////////////////////////////
always @(posedge clock or negedge reset)
begin
	if(reset==1'b0)
	begin
		Instruction0=0;
		Instruction1=1;
		Instruction2=2;
		Instruction3=3;
		Instruction4=4;
		Instruction5=5;
		Instruction6=6;
		Instruction7=7;
		
		Address0=`AddressBusZero;
		Address1=`AddressBusZero;
		
		Status=`PreFetchStatus_Normal;
		PreFetchedAddress=`AddressBusZero;
		PreFetchedRequest=1'b0;
		AddressStore=`AddressBusZero;
		
		FirstHalfGot=1'b0;
		SecondHalfGot=1'b0;
	end
	else
	begin
		case (Status)
		`PreFetchStatus_Normal:
			//only when the cache is free can you goto fetch instruction from cache
			if(PreFetchedWait==1'b0)
			begin
			   if(NoThisInstruction==1'b1)//no this instruction in buffer
			   begin
				Status=`PreFetchStatus_Wait;
				//fetch a whole instruction cache block
				PreFetchedAddress={Address[`AddressBusWidth-1:4],4'b0000};
				PreFetchedRequest=1'b1;
				AddressStore=PreFetchedAddress;
//				$monitor($time,"	instruction prefetch buffer miss address:	%h	and request for cache block address:	%h",Address,PreFetchedAddress);
			   end
			   else if(Address[4]==1'b0)//i am accessing the first half
			   begin
			   	if(ForwardNoThisInstruction)//fetch the second half
			   	begin
			  		//send out access for the second half
					Status=`PreFetchStatus_Wait;
					//fetch a whole instruction cache block
					PreFetchedAddress={ForwardAddress[`AddressBusWidth-1:4],4'b0000};
					PreFetchedRequest=1'b1;
					AddressStore=PreFetchedAddress;
//					$monitor($time,"forward fetch for the second half at:	%h",PreFetchedAddress);
			   	end
			   end
			   else if(Address[4]==1'b1)//i am accessing the second half
			   begin
			   	if(ForwardNoThisInstruction)//fetch the first half
			   	begin
			  		//send out access for the first half
					Status=`PreFetchStatus_Wait;
					//fetch a whole instruction cache block
					PreFetchedAddress={ForwardAddress[`AddressBusWidth-1:4],4'b0000};
					PreFetchedRequest=1'b1;
					AddressStore=PreFetchedAddress;
//					$monitor($time,"forward fetch for the first half at:	%h",PreFetchedAddress);
			   	end
			   end
			end
		`PreFetchStatus_Wait:
			//wait for the desire instruction
			if(PreFetchedWait==1'b0)
			begin
				Status=`PreFetchStatus_Normal;
				//just preserve previous address
				//PreFetchedAddress=`AddressBusZ;
				PreFetchedRequest=1'b0;
//				$monitor($time,"	fetch back from instruction cache address:	%h",AddressStore);
				//write the read back instruction to buffer
				if(AddressStore[4]==1'b1)//now is store to the second half of prefetch buffer
				begin
					Instruction4=PreFetchedInstructions[31:0];
					Instruction5=PreFetchedInstructions[63:32];
					Instruction6=PreFetchedInstructions[95:64];
					Instruction7=PreFetchedInstructions[127:96];
					
					Address1=AddressStore;
					SecondHalfGot=1'b1;
				end
				else if(AddressStore[4]==1'b0)
				begin
					Instruction0=PreFetchedInstructions[31:0];
					Instruction1=PreFetchedInstructions[63:32];
					Instruction2=PreFetchedInstructions[95:64];
					Instruction3=PreFetchedInstructions[127:96];
					
					Address0=AddressStore;
					FirstHalfGot=1'b1;
				end
			end
		endcase
	end
end

endmodule
