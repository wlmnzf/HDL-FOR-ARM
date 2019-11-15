`define	Def_SectionSelectInDataCacheWidth		2
`define	Def_SectionNumberInDataCache		4
`define	Def_SectionSelectField			5:4

`define	Def_LineNumberInSectionOfDataCache		4
`define	Def_LineSelectInSectionWidth			2

`define	Def_WordSelectInLineOfDataCacheWidth		2
`define	Def_WordNumberInLineOfDataCache		4
`define	Def_WordSelectField				3:2



`define	Def_ByteNumberInCache	(`ByteNumberInWord)*(`Def_WordNumberInLineOfDataCache)*(`Def_LineNumberInSectionOfDataCache)*(`Def_SectionNumberInDataCache)




`define	DCacheState_Idel		8'b0000_0000
`define	DCacheState_Miss		8'b0000_0001
`define	DCacheState_ReadIn		8'b0000_0010
`define	DCacheState_WriteBack		8'b0000_0011