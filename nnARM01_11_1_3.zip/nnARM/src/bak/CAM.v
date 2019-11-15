//when in_CAMWriteEnable==1'b0,CAM will behave as a comparator 
//if one of its entry match to the in_CAMInput,it will make out_CAMMatchUp=1'b1 and out_CAMMatchResult=entry number
//when in_CAMWriteEnable==1'b1,it will write in_CAMInput to the entry specify by in_CAMWriteEntry

//the address of the memory space is make up of the following part
//Byte Select in word bits
//word select in line bits
//section select bits
//higher bits
//at the same time ,the address of CAM is make up of following bits
//section select bits
//line select bits
//the content of CAM entry is make up of 
//higher bits
module	CAM(in_CAMInput,
			in_CAMWriteEntry,
			in_CAMWriteEnable,
			out_CAMMatchResult,
			out_CAMMatchUp,
			);
//the address of each line will be store
//so the lowest bits that use to identify byte in word will not store
//and the bits that used to identify word in line will also not store
//
parameter	PARAM_EntryWidth=`AddressBusWidth-`Def_WordSelectInLineOfDataCacheWidth-`ByteSelectWidthInWord;

input [`PARAM_EntryWidth-1:0]	in_CAMInput;
input	
endmodule