`include "Def_StructureParameter.v"
`include "Def_DataCacheController.v"


module DataCacheController(	//signal between mem and DataCacheController
			in_DataCacheAddress,		//data address
			io_DataCacheBus,		//data value for write and read
			in_DataCacheAccessEnable,	//enable access
			in_DataCacheBW,			//1 means byte,0 means word
			in_DataCacheRW,			//1 means read,0 means write
			out_DataCacheWait,		//wait for free
			//signal between DataCacheController and MemoryCotroller
			out_DataMemoryAddress,		//address goto memory
			io_DataMemoryBus,	//data value for write to memory
			out_DataMemoryEnable,		//enable accesss
			out_DataMemoryRW,			//1 means read, 0 means write
			in_DataMemoryWait,		//wait for memory
			//signal for clock and reset
			clock,
			reset
			);
//signal between mem and DataCacheController
input	[`AddressBusWidth-1:0]			in_DataCacheAddress;
inout	[`WordWidth-1:0]			io_DataCacheBus;
input						in_DataCacheAccessEnable;
input						in_DataCacheBW;
input						in_DataCacheRW;
output						out_DataCacheWait;

reg						out_DataCacheWait;


//signal between DataCacheController and MemoryCotroller
output		[`AddressBusWidth-1:0]		out_DataMemoryAddress;
inout		[`WordWidth-1:0]		io_DataMemoryBus;
output						out_DataMemoryEnable;
output						out_DataMemoryRW;
input						in_DataMemoryWait;

reg		[`AddressBusWidth-1:0]		out_DataMemoryAddress;
reg						out_DataMemoryEnable;
reg						out_DataMemoryRW;

input		clock,
		reset;

//use to deal with inout port
reg	[`WordWidth-1:0]			DCacheOutTmp;
reg						DCacheOutTmp2Bus;
reg	[`WordWidth-1:0]			MemoryOutTmp;
reg						MemoryOutTmp2Bus;

//the memory of cache
reg	[`ByteWidth-1:0]	Mem	[255:0];

reg	[`AddressBusWidth-1:6]	Tag	[15:0];

reg	[15:0]	Dirty;

reg	[15:0]	Valid;

//state machine of cache controller
reg	[`ByteWidth-1:0]	State;

//this reg will not be infer
//just as a wire
//have a match in cam?
reg				CAMMatch;
//which entry match
reg	[1:0]			CAMEntry;
//what is the previous access line of each section
reg	[1:0]		PrevAccess [3:0];
//what is the current replacable line of each section
reg	[1:0]		ReplaceEntry [3:0];
//content of replacable CAM entry 
reg	[`AddressBusWidth-1:6]	ReplaceContent	[3:0];

//write back word count
reg	[1:0]			WBWordCount,Next_WBWordCount;
//read in word count
reg	[1:0]			RIWordCount,Next_RIWordCount;

//write back address
reg	[`AddressBusWidth-1:0]	WBAddress;

//read in address
reg	[`AddressBusWidth-1:0]	RIAddress;

//have see the wait signal from memory?
reg	HaveWait;

//just for debug
wire	[1:0] PrevAccess0,PrevAccess1,PrevAccess2,PrevAccess3;
wire	[1:0] ReplaceEntry0,ReplaceEntry1,ReplaceEntry2,ReplaceEntry3;
wire	[`AddressBusWidth-1:6] Tag0,Tag1,Tag2,Tag3,Tag4,Tag5,Tag6,Tag7,Tag8,Tag9,Tag10,Tag11,Tag12,Tag13,Tag14,Tag15;

assign	PrevAccess0=PrevAccess[0];
assign	PrevAccess1=PrevAccess[1];
assign	PrevAccess2=PrevAccess[2];
assign	PrevAccess3=PrevAccess[3];

assign	ReplaceEntry0=ReplaceEntry[0];
assign	ReplaceEntry1=ReplaceEntry[1];
assign	ReplaceEntry2=ReplaceEntry[2];
assign	ReplaceEntry3=ReplaceEntry[3];

assign	Tag0=Tag[0];
assign	Tag1=Tag[1];
assign	Tag2=Tag[2];
assign	Tag3=Tag[3];
assign	Tag4=Tag[4];
assign	Tag5=Tag[5];
assign	Tag6=Tag[6];
assign	Tag7=Tag[7];
assign	Tag8=Tag[8];
assign	Tag9=Tag[9];
assign	Tag10=Tag[10];
assign	Tag11=Tag[11];
assign	Tag12=Tag[12];
assign	Tag13=Tag[13];
assign	Tag14=Tag[14];
assign	Tag15=Tag[15];

//use to deal with io_DataCacheBus
assign	io_DataCacheBus=(DCacheOutTmp2Bus==1'b1)?DCacheOutTmp:`WordZ;

//use to deal with io_DataMemoryBus
assign	io_DataMemoryBus=(MemoryOutTmp2Bus==1'b1)?MemoryOutTmp:`WordZ;

integer ssycnt;
always @(posedge clock or negedge reset)
begin
	$monitor($time,"%x %x %x %x",Valid[ReplaceEntry[in_DataCacheAddress[5:4]]],ReplaceEntry[in_DataCacheAddress[5:4]],in_DataCacheAddress[5:4],Dirty[ReplaceEntry[in_DataCacheAddress[5:4]]]);
	if(reset==1'b0)
	begin
		//init memory
		for(ssycnt=0;ssycnt<=255;ssycnt=ssycnt+1)
		begin
			Mem[ssycnt]=`ByteZero;
		end

		for(ssycnt=0;ssycnt<=15;ssycnt=ssycnt+1)
		begin
			Tag[ssycnt]=26'b0000_0000_0000_0000_0000_0000_00;
			Dirty[ssycnt]=1'b0;
			Valid[ssycnt]=1'b0;
		end

		PrevAccess[2'b00]=2'b00;
		PrevAccess[2'b01]=2'b00;
		PrevAccess[2'b10]=2'b00;
		PrevAccess[2'b11]=2'b00;
		//$monitor($time,"%x",PrevAccess[2'b10]);

		//state machine
		State=`DCacheState_Idel;

		//inout manage
		DCacheOutTmp=`WordZ;
		DCacheOutTmp2Bus=1'b0;

		MemoryOutTmp=`WordZ;
		MemoryOutTmp2Bus=1'b0;

		//up to pipeline
		out_DataCacheWait=1'b0;

		//down to memory
		out_DataMemoryAddress=`WordZ;
		out_DataMemoryEnable=1'b0;
		out_DataMemoryRW=1'b0;

		//write and read word count
		WBWordCount=2'b00;
		RIWordCount=2'b00;

		//write back and read in address
		WBAddress=`AddressBusZero;
		RIAddress=`AddressBusZero;

		HaveWait=1'b0;
	end
	else
	begin
		//is not reset
		//normal operation
		case	(State)
		`DCacheState_Idel:
		begin
			if(in_DataCacheAccessEnable==1'b1)
			begin
				//a new access come
				if(CAMMatch==1'b1)
				begin
					//match up
					//state machine
					State=`DCacheState_Idel;
	
					if(in_DataCacheRW==1'b1)
					begin
						//read hit
						//inout manage
						if(in_DataCacheBW==1'b1)
						begin
							//read hit byte
							DCacheOutTmp={4{Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:0]}]}};
							DCacheOutTmp2Bus=1'b1;
						end
						else
						begin
							//read hit word
							DCacheOutTmp={Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b11}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b10}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b01}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b00}]};
							DCacheOutTmp2Bus=1'b1;
						end
					end
					else
					begin
						//write hit
						if(in_DataCacheBW==1'b1)
						begin
							//write hit byte
							DCacheOutTmp=`WordZ;
							DCacheOutTmp2Bus=1'b0;
							Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:0]}]=io_DataCacheBus[7:0];
						end
						else
						begin
							//write hit word
							DCacheOutTmp=`WordZ;
							DCacheOutTmp2Bus=1'b0;
							{Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b11}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b10}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b01}],Mem[{in_DataCacheAddress[5:4],CAMEntry,in_DataCacheAddress[3:2],2'b00}]}=io_DataCacheBus;
						end
						//set dirty bits
						Dirty[{in_DataCacheAddress[5:4],CAMEntry}]=1'b1;
					end

					MemoryOutTmp=`WordZ;
					MemoryOutTmp2Bus=1'b0;

					//up to pipeline
					out_DataCacheWait=1'b0;

					//down to memory
					out_DataMemoryAddress=`AddressBusZ;
					out_DataMemoryEnable=1'b0;
					out_DataMemoryRW=1'b0;

					//write and read word count
					WBWordCount=2'b00;
					RIWordCount=2'b00;

					//write back and read in address
					WBAddress=`AddressBusZero;
					RIAddress=`AddressBusZero;

					HaveWait=1'b0;
				end
				else
				begin
					//miss
					if(Valid[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]]}]==1'b0 || (Valid[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]]}]==1'b1 && Dirty[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]]}]==1'b0))
					begin
						//not valid or is not dirty
						//no need to write back
						//just go to read in
						State=`DCacheState_ReadIn;

						//inout manage
						DCacheOutTmp=`WordZ;
						DCacheOutTmp2Bus=1'b0;
					
						//write  word count
						WBWordCount=2'b00;
						
						//write back address
						WBAddress={Tag[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]]}],in_DataCacheAddress[5:4],WBWordCount,2'b00};

						//send out read address
						RIWordCount=2'b00;
						RIAddress={in_DataCacheAddress[`AddressBusWidth-1:4],RIWordCount,2'b00};

						//out put the first word to be write back
						MemoryOutTmp=`WordZero;
						MemoryOutTmp2Bus=1'b0;

						//up to pipeline
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress=RIAddress;
						out_DataMemoryEnable=1'b1;
						out_DataMemoryRW=1'b1;
					
						HaveWait=1'b0;
					end
					else
					begin
						//valid and dirty
						//must write back first
						State=`DCacheState_WriteBack;

						//inout manage
						DCacheOutTmp=`WordZero;
						DCacheOutTmp2Bus=1'b0;
					
						//write  word count
						WBWordCount=2'b00;
						
						//write back address
						WBAddress={Tag[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]]}],in_DataCacheAddress[5:4],WBWordCount,2'b00};

						//send out read address
						RIWordCount=2'b00;
						RIAddress={in_DataCacheAddress[`AddressBusWidth-1:4],RIWordCount,2'b00};

						//out put the first word to be write back
						MemoryOutTmp={Mem[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]],WBWordCount,2'b11}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]],WBWordCount,2'b10}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]],WBWordCount,2'b01}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[in_DataCacheAddress[5:4]],WBWordCount,2'b00}]};
						MemoryOutTmp2Bus=1'b1;

						//up to pipeline
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress=WBAddress;
						out_DataMemoryEnable=1'b1;
						out_DataMemoryRW=1'b0;
					
						HaveWait=1'b0;
					end
				end
			end
			else
			begin
				//no new access
				//state machine
				State=`DCacheState_Idel;

				//inout manage
				DCacheOutTmp=`WordZ;
				DCacheOutTmp2Bus=1'b0;

				MemoryOutTmp=`WordZ;
				MemoryOutTmp2Bus=1'b0;

				//up to pipeline
				out_DataCacheWait=1'b0;

				//down to memory
				out_DataMemoryAddress=`AddressBusZ;
				out_DataMemoryEnable=1'b0;
				out_DataMemoryRW=1'b0;

				//write and read word count
				WBWordCount=2'b00;
				RIWordCount=2'b00;

				//write back and read in address
				WBAddress=`AddressBusZero;
				RIAddress=`AddressBusZero;

				HaveWait=1'b0;
			end
		end//DCacheState_Idel

		`DCacheState_ReadIn:
		begin
			//miss and read in
			if(in_DataMemoryWait==1'b1)
			begin
				//memory is busy
				HaveWait=1'b1;
			end//in_DataMemoryWait==1'b1
			else
			begin
				//in_DataMemoryWait!=1'b1
				if(HaveWait==1'b1)
				begin
					//read in previous request memory element
					{Mem[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]],RIWordCount,2'b11}],Mem[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]],RIWordCount,2'b10}],Mem[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]],RIWordCount,2'b01}],Mem[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]],RIWordCount,2'b00}]}=io_DataMemoryBus;
					if(Next_RIWordCount==2'b00)
					begin
						//read in end
						//record the current accessed entry
						PrevAccess[RIAddress[5:4]]=ReplaceEntry[RIAddress[5:4]];
						Valid[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]]}]=1'b1;
						Dirty[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]]}]=1'b0;
						Tag[{RIAddress[5:4],ReplaceEntry[RIAddress[5:4]]}]=RIAddress[`AddressBusWidth-1:6];

						State=`DCacheState_Idel;

						DCacheOutTmp=`WordZ;
						DCacheOutTmp2Bus=1'b0;

						MemoryOutTmp=`WordZ;
						MemoryOutTmp2Bus=1'b0;

						//up to pipeline
						//now i will not release the cache
						//because if there have been a write miss
						//then at the next posedge there must be a write hit
						//if i release the cache now, then the pipeline will think that the write have finish
						//and pipeline will not continue to send the write request at next cycle,
						//so if i make the wait signal high will make the pipeline continue to send out write request next cycle
						//and the hold time of cache will be satisfy
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress=`AddressBusZ;
						out_DataMemoryEnable=1'b0;
						out_DataMemoryRW=1'b0;

						//write and read word count
						WBWordCount=2'b00;
						RIWordCount=2'b00;

						//write back and read in address
						WBAddress=`AddressBusZero;
						RIAddress=`AddressBusZero;

						HaveWait=1'b0;
					end
					else
					begin
						//read in not end yet
						//state machine
						State=`DCacheState_ReadIn;

						//inout manage
						DCacheOutTmp=`WordZ;
						DCacheOutTmp2Bus=1'b0;

						MemoryOutTmp=`WordZ;
						MemoryOutTmp2Bus=1'b0;

						//up to pipeline
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress={RIAddress[`AddressBusWidth-1:4],Next_RIWordCount,2'b00};
						out_DataMemoryEnable=1'b1;
						out_DataMemoryRW=1'b1;

						//write and read word count
						WBWordCount=2'b00;
						RIWordCount=Next_RIWordCount;

						//write back and read in address
						WBAddress=`AddressBusZero;

						HaveWait=1'b0;
					end
				end//HaveWait==1'b1
				else
				begin
					//nothing to do
					State=`DCacheState_ReadIn;
				end//HaveWait!=1'b1
			end//in_DataMemoryWait!=1'b1
		end//DCacheState_ReadIn

		`DCacheState_WriteBack:
		begin
			//miss and write back
			if(in_DataMemoryWait==1'b1)
			begin
				//memory is busy
				HaveWait=1'b1;
			end//in_DataMemoryWait==1'b1
			else
			begin
				//in_DataMemoryWait!=1'b1
				if(HaveWait==1'b1)
				begin
					if(Next_WBWordCount==2'b00)
					begin
						//write back end
						State=`DCacheState_Idel;
						Valid[{WBAddress[5:4],ReplaceEntry[WBAddress[5:4]]}]=1'b0;
						Tag[{WBAddress[5:4],ReplaceEntry[WBAddress[5:4]]}]=26'b0000_0000_0000_0000_0000_0000_00;

						DCacheOutTmp=`WordZ;
						DCacheOutTmp2Bus=1'b0;

						//out put the word to be write back
						MemoryOutTmp=`WordZ;
						MemoryOutTmp2Bus=1'b0;


						//up to pipeline
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress=`AddressBusZ;
						out_DataMemoryEnable=1'b0;
						out_DataMemoryRW=1'b0;

						//write and read word count
						WBWordCount=2'b00;
						RIWordCount=2'b00;

						//write back and read in address
						WBAddress=`AddressBusZero;
						RIAddress=`AddressBusZero;

						HaveWait=1'b0;
					end
					else
					begin
						//write back not end yet
						//state machine
						State=`DCacheState_WriteBack;

						//inout manage
						DCacheOutTmp=`WordZ;
						DCacheOutTmp2Bus=1'b0;

						//out put the word to be write back
						MemoryOutTmp={Mem[{WBAddress[5:4],ReplaceEntry[WBAddress[5:4]],Next_WBWordCount,2'b11}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[WBAddress[5:4]],WBWordCount,2'b10}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[WBAddress[5:4]],WBWordCount,2'b01}],Mem[{in_DataCacheAddress[5:4],ReplaceEntry[WBAddress[5:4]],WBWordCount,2'b00}]};
						MemoryOutTmp2Bus=1'b1;

						//up to pipeline
						out_DataCacheWait=1'b1;

						//down to memory
						out_DataMemoryAddress={WBAddress[`AddressBusWidth-1:4],Next_WBWordCount,2'b00};
						out_DataMemoryEnable=1'b1;
						out_DataMemoryRW=1'b0;

						//write and read word count
						WBWordCount=Next_WBWordCount;
						RIWordCount=2'b00;

						//write back and read in address
						RIAddress=`AddressBusZero;

						HaveWait=1'b0;
					end
				end//HaveWait==1'b1
				else
				begin
					//nothing to do
					State=`DCacheState_WriteBack;
				end//HaveWait!=1'b1
			end//in_DataMemoryWait!=1'b1
		end//DCacheState_WriteBack
		endcase
	end
end


//CAM compare
always @(in_DataCacheAddress or
	Tag[0]	or
	Tag[1]	or
	Tag[2]	or
	Tag[3]	or
	Tag[4]	or
	Tag[5]	or
	Tag[6]	or
	Tag[7]	or
	Tag[8]	or
	Tag[9]	or
	Tag[10]	or
	Tag[11]	or
	Tag[12]	or
	Tag[13]	or
	Tag[14]	or
	Tag[15]	or
	Valid[0]	or
	Valid[1]	or
	Valid[2]	or
	Valid[3]	or
	Valid[4]	or
	Valid[5]	or
	Valid[6]	or
	Valid[7]	or
	Valid[8]	or
	Valid[9]	or
	Valid[10]	or
	Valid[11]	or
	Valid[12]	or
	Valid[13]	or
	Valid[14]	or
	Valid[15]	or
	PrevAccess[0]	or
	PrevAccess[1]	or
	PrevAccess[2]	or
	PrevAccess[3]
)
begin
	ReplaceContent[2'b00]=Tag[0];
	ReplaceContent[2'b01]=Tag[4];
	ReplaceContent[2'b10]=Tag[8];
	ReplaceContent[2'b11]=Tag[12];

	if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[0]  && in_DataCacheAddress[5:4]==2'b00 && Valid[0]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b00;
		ReplaceContent[2'b00]=Tag[0];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[1]  && in_DataCacheAddress[5:4]==2'b00 && Valid[1]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b01;
		ReplaceContent[2'b00]=Tag[1];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[2]  && in_DataCacheAddress[5:4]==2'b00 && Valid[2]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b10;
		ReplaceContent[2'b00]=Tag[2];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[3]  && in_DataCacheAddress[5:4]==2'b00 && Valid[3]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b11;
		ReplaceContent[2'b00]=Tag[3];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[4]  && in_DataCacheAddress[5:4]==2'b01 && Valid[4]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b00;
		ReplaceContent[2'b01]=Tag[4];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[5]  && in_DataCacheAddress[5:4]==2'b01 && Valid[5]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b01;
		ReplaceContent[2'b01]=Tag[5];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[6]  && in_DataCacheAddress[5:4]==2'b01 && Valid[6]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b10;
		ReplaceContent[2'b01]=Tag[6];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[7]  && in_DataCacheAddress[5:4]==2'b01 && Valid[7]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b11;
		ReplaceContent[2'b01]=Tag[7];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[8]  && in_DataCacheAddress[5:4]==2'b10 && Valid[8]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b00;
		ReplaceContent[2'b10]=Tag[8];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[9]  && in_DataCacheAddress[5:4]==2'b10 && Valid[9]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b01;
		ReplaceContent[2'b10]=Tag[9];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[10]  && in_DataCacheAddress[5:4]==2'b10 && Valid[10]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b10;
		ReplaceContent[2'b10]=Tag[10];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[11]  && in_DataCacheAddress[5:4]==2'b10 && Valid[11]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b11;
		ReplaceContent[2'b10]=Tag[11];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[12]  && in_DataCacheAddress[5:4]==2'b11 && Valid[12]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b00;
		ReplaceContent[2'b11]=Tag[12];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[13]  && in_DataCacheAddress[5:4]==2'b11 && Valid[13]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b01;
		ReplaceContent[2'b11]=Tag[13];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[14]  && in_DataCacheAddress[5:4]==2'b11 && Valid[14]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b10;
		ReplaceContent[2'b11]=Tag[14];
	end
	else if(in_DataCacheAddress[`AddressBusWidth-1:6]==Tag[15]  && in_DataCacheAddress[5:4]==2'b11 && Valid[15]==1'b1)
	begin
		CAMMatch=1'b1;
		CAMEntry=2'b11;
		ReplaceContent[2'b11]=Tag[15];
	end
	else 
	begin
		CAMMatch=1'b0;
		CAMEntry=2'b00;
	end

	//decide which entry of section0 can be replace
	if(Valid[0]==1'b0)
	begin
		ReplaceEntry[0]=2'b00;
	end
	else if(Valid[1]==1'b0)
	begin
		ReplaceEntry[0]=2'b01;
	end
	else if(Valid[2]==1'b0)
	begin
		ReplaceEntry[0]=2'b10;
	end
	else if(Valid[3]==1'b0)
	begin
		ReplaceEntry[0]=2'b11;
	end
	else
	begin
		ReplaceEntry[0]=2'b00;
		case (PrevAccess[0])
		2'b00:
			ReplaceEntry[0]=2'b01;
		2'b01:
			ReplaceEntry[0]=2'b10;
		2'b10:
			ReplaceEntry[0]=2'b11;
		2'b11:
			ReplaceEntry[0]=2'b00;
		endcase
	end

	//decide which entry of section1 can be replace
	if(Valid[4]==1'b0)
	begin
		ReplaceEntry[1]=2'b00;
	end
	else if(Valid[5]==1'b0)
	begin
		ReplaceEntry[1]=2'b01;
	end
	else if(Valid[6]==1'b0)
	begin
		ReplaceEntry[1]=2'b10;
	end
	else if(Valid[7]==1'b0)
	begin
		ReplaceEntry[1]=2'b11;
	end
	else
	begin
		ReplaceEntry[1]=2'b00;
		case (PrevAccess[1])
		2'b00:
			ReplaceEntry[1]=2'b01;
		2'b01:
			ReplaceEntry[1]=2'b10;
		2'b10:
			ReplaceEntry[1]=2'b11;
		2'b11:
			ReplaceEntry[1]=2'b00;
		endcase
	end

	//decide which entry of section2 can be replace
	if(Valid[8]==1'b0)
	begin
		ReplaceEntry[2]=2'b00;
	end
	else if(Valid[9]==1'b0)
	begin
		ReplaceEntry[2]=2'b01;
	end
	else if(Valid[10]==1'b0)
	begin
		ReplaceEntry[2]=2'b10;
	end
	else if(Valid[11]==1'b0)
	begin
		ReplaceEntry[2]=2'b11;
	end
	else
	begin
		ReplaceEntry[2]=2'b00;
		case (PrevAccess[2])
		2'b00:
			ReplaceEntry[2]=2'b01;
		2'b01:
			ReplaceEntry[2]=2'b10;
		2'b10:
			ReplaceEntry[2]=2'b11;
		2'b11:
			ReplaceEntry[2]=2'b00;
		endcase
	end

	//decide which entry of section3 can be replace
	if(Valid[12]==1'b0)
	begin
		ReplaceEntry[3]=2'b00;
	end
	else if(Valid[13]==1'b0)
	begin
		ReplaceEntry[3]=2'b01;
	end
	else if(Valid[14]==1'b0)
	begin
		ReplaceEntry[3]=2'b10;
	end
	else if(Valid[15]==1'b0)
	begin
		ReplaceEntry[3]=2'b11;
	end
	else
	begin
		ReplaceEntry[3]=2'b00;
		case (PrevAccess[3])
		2'b00:
			ReplaceEntry[3]=2'b01;
		2'b01:
			ReplaceEntry[3]=2'b10;
		2'b10:
			ReplaceEntry[3]=2'b11;
		2'b11:
			ReplaceEntry[3]=2'b00;
		endcase
	end

end


//deal with word count increase
always @(WBWordCount)
begin
	Next_WBWordCount=2'b00;
	case (WBWordCount)
	2'b11:
		Next_WBWordCount=2'b00;
	2'b10:
		Next_WBWordCount=2'b11;
	2'b01:
		Next_WBWordCount=2'b10;
	2'b00:
		Next_WBWordCount=2'b01;
	endcase 
end

always @(RIWordCount)
begin
	Next_RIWordCount=2'b00;
	case (RIWordCount)
	2'b11:
		Next_RIWordCount=2'b00;
	2'b10:
		Next_RIWordCount=2'b11;
	2'b01:
		Next_RIWordCount=2'b10;
	2'b00:
		Next_RIWordCount=2'b01;
	endcase 
end

endmodule