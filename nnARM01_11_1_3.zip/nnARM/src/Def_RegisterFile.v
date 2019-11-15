
`define Def_RegisterNumber		32
`define Def_RegisterSelectWidth	`ByteWidth
`define Def_RegisterSelectZero	`ByteZero
`define Def_RegisterSelectAllOne	8'b1111_1111
`define Def_RegisterSelectZ		`ByteZ

`define Def_PCNumber			8'b0000_1111

//false link register
`define Def_LinkRegister		8'b0001_1111

//true link register
`define	Def_SBLRegister			8'b0000_1110

`define Def_PCInitValue			32'h0000_8000

//this register use in LDM/STM without write back to forwarding base value
`define	Def_LocalForwardRegister	8'b1001_1111