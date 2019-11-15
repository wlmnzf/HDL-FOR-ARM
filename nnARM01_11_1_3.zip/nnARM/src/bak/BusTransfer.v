module BusTransfer(in_WriteBus,
			out_LeftReadBus,
			out_RightReadBus,
			out_ThirdReadBus,
			//above is the Buses
			//below is control signal
			in_WriteToLeftRead,
			in_WriteToRightRead,
			in_WriteToThirdRead
);
input [`WordWidth-1:0] in_WriteBus;
output [`WordWidth-1:0] out_LeftReadBus,out_RightReadBus,out_ThirdReadBus;
input in_WriteToLeftRead,in_WriteToRightRead,in_WriteToThirdRead;

assign out_LeftReadBus=in_WriteToLeftRead?in_WriteBus:`WordZ;
assign out_RightReadBus=in_WriteToRightRead?in_WriteBus:`WordZ;
assign out_ThirdReadBus=in_WriteToThirdRead?in_WriteBus:`WordZ;


endmodule