module		CanGoGen(out_IFCanGo,
					out_IDCanGo,
					out_EXECanGo,
					out_MEMCanGo,
					out_WBCanGo,
					in_IFOwnCanGo,
					in_IDOwnCanGo,
					in_EXEOwnCanGo,
					in_MEMOwnCanGo,
					in_WBOwnCanGo
);

input in_IFOwnCanGo,in_IDOwnCanGo,in_EXEOwnCanGo,in_MEMOwnCanGo,in_WBOwnCanGo;
output	out_IFCanGo,out_IDCanGo,out_EXECanGo,out_MEMCanGo,out_WBCanGo;

assign	out_WBCanGo=in_WBOwnCanGo;
assign	out_MEMCanGo=in_MEMOwnCanGo & out_WBCanGo;
assign	out_EXECanGo=in_EXEOwnCanGo & out_MEMCanGo;
assign	out_IDCanGo=in_IDOwnCanGo & out_EXECanGo;
assign	out_IFCanGo=in_IFOwnCanGo & out_IDCanGo;

endmodule
