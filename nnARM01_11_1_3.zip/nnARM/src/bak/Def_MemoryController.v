//////////////////////////////////////////////////////////////////////////
//			define memory controller parameter		//
//									//
//author:ShengYu Shen from national university of defense technology	//
//create time:2001 3 17							//
//////////////////////////////////////////////////////////////////////////

`include "Def_StructureParameter.v"

`define MemoryBusWidth		`WordWidth
`define	MemorySize		1024*1024
`define MemoryElementWidth	`ByteWidth
`define MemoryElementZero	`ByteZero


`define	MemoryNonSequentialDelay	6
`define	MemorySequentialDelay		2

//memory access status
`define	MemoryAccessStageWidth		3
`define	MemoryAccessStage0		3'b000
`define	MemoryAccessStage2		3'b010
`define	MemoryAccessStage6		3'b110
