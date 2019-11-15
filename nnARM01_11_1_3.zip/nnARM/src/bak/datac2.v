//determine the next state of outstand access to memory
always @()
begin
	//these assignment is all save current state
	Next_OutStandAccessEnable=OutStandAccessEnable;
	Next_OutStandAccessAddress=OutStandAccessAddress;
	Next_OutStandAccessRW=OutStandAccessRW;
	Next_OutStandAccessValue=OutStandAccessValue;

	Next_OutStandWriteBackEnable=OutStandWriteBackEnable;
	Next_OutStandWriteBackAddress=OutStandWriteBackAddress;
	Next_OutStandWriteBackWordCount=OutStandWriteBackWordCount;

	Next_OutStandReadInEnable=OutStandReadInEnable;
	Next_OutStandReadInAddress=OutStandReadInAddress;
	Next_OutStandReadInWordCount=OutStandReadInWordCount;

	if(out_DataCacheWait==1'b1)
	begin
		//a new access
		if(OutStandAccessEnable==1'b1)
		begin
			//there is a outstanding access now
			if(OutStandWriteBackEnable)
			begin
			end
		end
		else
		begin
			//OutStandAccessEnable==1'b0
			//no outstanding access ,but a new access have come,
			//issue a new outstanding access
			Next_OutStandAccessEnable=1'b1;
			Next_OutStandAccessAddress=in_DataCacheAddress;
			Next_OutStandAccessRW=in_DataCacheRW;
			Next_OutStandAccessValue=DataCacheBus;

			if()
		end
	end
	else
	begin
		//	out_DataCacheWait==1'b0
		//nothing to do,just save current state
	end
end
