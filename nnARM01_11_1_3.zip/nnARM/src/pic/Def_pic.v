// Define number of interrupt inputs (2-31)
`define PIC_INTS 8

// Address offsets of PIC registers inside PIC group
`define PIC_OFS_PICMR 2'd0
`define PIC_OFS_PICSR 2'd2

// Position of offset bits inside SPR address
`define PICOFS_BITS 1:0
