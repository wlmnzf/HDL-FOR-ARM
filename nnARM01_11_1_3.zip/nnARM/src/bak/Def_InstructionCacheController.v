//total instruction cache size in byte
`define InstructionCacheTotalSizeInByte		4096
`define InstructionCacheTotalSizeInWord		`InstructionCacheTotalSizeInByte/`ByteNumberInWord

//how many word in a line and how to select out
`define	InstructionCacheWordNumberInLine	4
`define InstructionCacheWordSelectBit		3:2

//how many section
`define InstructionSectionNumber		4
`define InstructionSectionSelectBits		5:4

//how many line in a section
`define InstructionCacheLineNumberInSection	(`InstructionCacheTotalSizeInWord/`InstructionSectionNumber)/`InstructionCacheWordNumberInLine

//how width a line
`define InstructionCacheLineWidth		`WordWidth*`InstructionCacheWordNumberInLine
`define InstructionCacheLineZero		128'h0000_0000_0000_0000_0000_0000_0000_0000

`define InstructionCacheMemoryAccess_Normal		8'b00000000
`define InstructionCacheMemoryAccess_Wait		8'b00000001