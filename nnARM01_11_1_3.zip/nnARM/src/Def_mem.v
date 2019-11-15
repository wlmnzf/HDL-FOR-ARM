
// all support by main mem thread
//simple mem thread only support Null and Mov
`define	MEMType_Null	8'b0000_0000

`define	MEMType_MovMain	8'b0000_0001
`define	MEMType_MovSimple	8'b0000_0010



`define	MEMType_LoadMainWord	8'b0000_0100
`define	MEMType_StoreMainWord	8'b0000_0101

`define	MEMType_LoadSimpleWord	8'b0000_0110
`define	MEMType_StoreSimpleWord	8'b0000_0111

`define	MEMType_LoadMainByte	8'b0000_1100
`define	MEMType_StoreMainByte	8'b0000_1101

`define	MEMType_LoadSimpleByte	8'b0000_1110
`define	MEMType_StoreSimpleByte	8'b0000_1111

`define	MEMType_LoadMainHalfWord	8'b0001_0000
`define	MEMType_LoadSimpleHalfWord	8'b0001_0001

`define	MEMType_StoreMainHalfWord	8'b0001_0010
`define	MEMType_StoreSimpleHalfWord	8'b0001_0011

`define	MEMType_SWP			8'b0001_0100

`define	MEMType_BlankOp			8'b0001_0101


`define	MEMAccessState_Idel	8'b0000_0000
`define	MEMAccessState_WaitForOneCycle	8'b0000_0001
`define	MEMAccessState_WaitForFree	8'b0000_0010
